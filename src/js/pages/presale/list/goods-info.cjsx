SkuSelector = require 'sipin-frontend-components/components/sku-selector'
classnames = require 'classnames'
PlaceSelector = require 'PlaceSelector'
Amount = require 'Amount'
liteFlux = require 'lite-flux'

Coupon = require './coupon'
SetMessageBtn = require './set-message-btn'
Store = require './_stores/presales-home'
Action = Store.getAction()
storeName = 'presales-home'

goodsApi = require 'goodsApi'

SkuCheckbox = React.createClass
    render: ->

        classMap = {
            "_active": this.props.status,
            "_disable": this.props.disabled,
            "sku-attr": true,
            "good-detail-summary__type-item": !this.props.color,
            "good-detail-summary__color-item": this.props.color
        };

        classes = classnames(classMap, this.props.className);
        <div {...@props} className={classes}>{@props.children}</div>

Icon = React.createClass
    render: ->
        <span className="u-icon" onClick={@props.onClick}>
            <img src={@props.url} />
            <span className="u-icon-title">{@props.title}</span>
        </span>

Line = React.createClass
    render: ->
        classMap = {
            "u-line-gray": this.props.gray
        };

        classes = classnames(classMap, this.props.className);
        <span {...@props} className={classes} >|</span>



GoodsInfo = React.createClass
    mixins: [liteFlux.mixins.storeMixin(storeName)]

    componentDidMount: ->
        store = @state[storeName]
        current = store.current_detail
        server_time = store.server_time
        skuPicker = store.skuPicker
        sku = skuPicker.selected_sku
        # 查询物流费
        getDelivery = (id,callback)->
            SP.get SP.config.host + "/api/price/getDelivery",{
                goods_sku_id: sku.id,
                region_id: id
            },(dilivery)->
                if callback
                    callback(dilivery)


        # 默认物流费
        _regionId = parseInt $("._place_area").data("id") || parseInt $("._place_city").data("id")

        # 处理cookie
        if parseInt(SP.storage.get('region_district_id' ))!=-1
            _regionCookieId = parseInt SP.storage.get('region_district_id' )
        else
            _regionCookieId = parseInt SP.storage.get('region_city_id')

        if _regionCookieId
            _regionId = _regionCookieId;

        if _regionId
            getDelivery _regionId,(dilivery)->
                if dilivery and dilivery.code ==0
                    dilivery = dilivery.data
                    if(dilivery == -1)
                        SP.log("此地区暂时不支持配送.")
                    else
                        $("#j-delivery").text(dilivery+".00")
                else
                    SP.log("没有获取到配送信息.")

        # 地区选择
        placeSelect = new PlaceSelector
            target: "#stock-btn .btn"
            closeBtn: ".close"
            callback: (res)->
                regionId = if parseInt(res.district.id)!=-1 then res.district.id else if parseInt(res.city.id) !=-1 then res.city.id
                if regionId
                    #查询物流费
                    getDelivery regionId,(dilivery)->
                        if dilivery and dilivery.code ==0
                            dilivery = dilivery.data
                            if(dilivery == -1)
                                SP.alert '很抱歉！您所选的区域暂不支持配送。'
                            else
                                $("#j-delivery").text(dilivery+".00")
                        else
                            SP.log("没有获取到配送信息.")

                else
                    SP.log "获取地区信息失败"

        #初始化 Amount
        amount = @refs['amount']
        if typeof amount is 'object'
            $amount = $(amount)
            if $amount.length
                $amount.amount
                    callback: (value)=>
                        console.log value
                        @refs['quantity'].value = value
    skuChange: (data) ->
        if @refs['sku_sn']
            @refs['sku_sn'].value = data.skuSn
        Action.setSelectedSku data

    checkout: () ->
        $form = $(@refs['form'])

        if SP.isLogined()
            # $form.submit()
            @ajaxBuy()
        else
            # 登录框
            SP.login =>
                # $form.submit()
                @ajaxBuy

    ajaxBuy: () ->
        data =
            presale_batch_id: @refs['presale_batch_id'].value
            sku_sn: @refs['sku_sn'].value
            quantity: @refs['quantity'].value
        webapi.presales.presalesBuy(data).then (res) =>

            if res.code is 50014
                # console.log res.data
                @buy res.data
            else if res.code is 50015
                window.location.href = '/payment?order_no=' + res.data.order_no
            else if res.code is 1 and res.msg is '请先登录'
                SP.login()
            else if res.code isnt 0
                SP.notice.error res.msg




    buy: (data) ->
        $form = $(@refs['form-buy'])
        $ipt = $('<input type="hidden" />')
        $ipt[0].name = 'data'
        $ipt[0].value = JSON.stringify data
        $form.append $ipt
        # for key, value of data
        #     console.log 'buy', key, value
        #     $ipt = $('<input type="hidden" />')
        #     $ipt[0].name = key
        #     $ipt[0].value = value
        #     console.log $ipt[0]
        #     $form.append $ipt

        $form.submit()




    like: () ->
        store = @state[storeName]
        current = store.current_detail

        if SP.isLogined()
            goodsApi.like current.goods_id, (res)->
        else
            # 登录框
            SP.login()

    meqia: () ->
        console.log 'meqia'
        if typeof mechatClick != 'undefined'
            mechatClick()


    render: ->
        store = @state[storeName]
        current = store.current_detail
        if current is null
            return <div></div>
        server_time = store.server_time
        skuPicker = store.skuPicker
        sku = skuPicker.selected_sku
        batches = current.batches
        hasCurrentBatches = no
        presale_price = ''
        earnest_money = ''
        price_name = '预售价'

        time = ''
        node = ''

        sku_sn = sku.sku_sn

        tags = []


        skuPickerData =
            itemComponent: (item, parentComponent ) ->
                renderChildItem = (children)->

                    children.map (child, i)->

                        value = child.attribute_value
                        if child.mainSku
                            value = <img src={child.url} alt={child.attribute_value} title={child.attribute_value} width="40" height="40" />

                        disabled = parentComponent.isDisabled.call(parentComponent, child)
                        status = parentComponent.isChecked.call(parentComponent, child)

                        <SkuCheckbox key={child.id} color={child.mainSku} disabled={disabled} status={status} onClick={parentComponent.selectItem.bind(parentComponent, child, disabled, status)} key={i}>{value}</SkuCheckbox>

                <li className="good-detail-summary__type sku-group u-clearfix" key={item.id}>
                    <div className="dt">
                        {item.name}：
                    </div>
                    <div className="dd">
                        {renderChildItem(item.value)}
                    </div>
                </li>
            data: skuPicker.optional
            list: skuPicker.skuData
            active_attribute: skuPicker.attribute_key


        if current.batches and current.batches.length
            current.batches.map (batches, j) =>
                # 找到当前批次
                if batches.id is current.next_valid_batch_id
                    hasCurrentBatches = yes
                    batches.skus.map (item, i) =>
                        if +sku.id is item.goods_sku_id
                            presale_price = item.presale_price
                            earnest_money = item.earnest_money

                    if batches.is_preferential
                        tags.push <span key={0}>{'首发优惠'}</span>

                    if batches.is_quick
                        tags.push <span key={1}>{'闪电发货'}</span>


                    # 开售前
                    if DATE.diff(server_time, batches.begin_at) < 0
                        console.log '开售前'
                        time =
                            <div className="u-color_gray">
                                （注：首发预定时间：<span className="u-color_red">{batches.begin_at}</span>）
                            </div>
                    
                        presale_price = current.presale_price_tip
                        earnest_money = current.earnest_money_tip
                    # 开售ing
                    else if DATE.diff(server_time, batches.end_at) < 0
                        time =
                            <div className="u-color_gray">
                                （注：尾款需在{current.batches.pay_deadline}内进行支付）
                            </div>
            if not hasCurrentBatches
                current.batches[current.batches.length - 1].skus.map (item, i) =>
                    if +sku.id is item.goods_sku_id
                        presale_price = item.presale_price
                        earnest_money = item.earnest_money

            # 第一批开售前
            if DATE.diff(server_time, current.batches[0].begin_at) < 0
                console.log '第一批开售前'
                time =
                    <div className="u-color_gray">
                        （注：首发预定时间：<span className="u-color_red">{current.batches[0].begin_at}</span>）
                    </div>

        batches.map (item, i) =>
            # 找到当前批次
            if item.id is current.next_valid_batch_id
                # hasCurrentBatches = yes
                # 开售前
                if DATE.diff(server_time, item.begin_at) < 0
                    console.log '开售前'
                    node =
                        <div>
                            <div className="u-mb_15">
                                <SetMessageBtn id={current.id} />
                            </div>
                            {time}
                        </div>
                # 开售ing
                else if DATE.diff(server_time, item.end_at) < 0
                    console.log '开售ing'
                    node =
                        <div>

                            <div className="good-detail-summary u-clearfix">
                                <ul>
                                    <li className="good-detail-summary__stock u-clearfix">
                                        <div className="dt">
                                            数量：
                                        </div>
                                        <div className="dd">
                                            <div className="amount-box u-clearfix" ref="amount">
                                                <div className="amount-box__input">
                                                    <input data-max="99" type="text" defaultValue="1"/>
                                                </div>
                                                <div className="amount-box__btns">
                                                    <a href="javascript:;" className="amount-box__btn amount-box__btns-up"><span className="iconfont icon-jia"></span></a>
                                                    <a href="javascript:;" className="amount-box__btn amount-box__btns-down"><span className="iconfont icon-jian"></span></a>
                                                </div>
                                            </div>
                                        </div>
                                    </li>
                                </ul>
                            </div>
                            <div className="u-mb_15 u-mt_25">
                                <form id="j-buy-now-form" className="u-none" action="/presale/buy" method="POST" ref="form">
                                    <input type="hidden" name="presale_batch_id" defaultValue={item.id} ref="presale_batch_id" />
                                    <input type="hidden" name="sku_sn" defaultValue={sku.sku_sn} ref="sku_sn" />
                                    <input type="hidden" name="quantity" defaultValue={1} ref="quantity" />
                                </form>
                                <form className="u-none" action="/presale/buy" method="POST" ref="form-buy">
                                </form>
                                <span className="btn btn-larger-big btn-color-red" onClick={@checkout}>定金￥ {earnest_money} 抢先预定</span>
                                <span className="u-ml_20">已经有<span className="u-color_red">{current.total_booking}</span>人预定</span>
                            </div>
                            {time}
                        </div>
                    # 开售ing, 缺货
                    if +current.out_of_stock is -1
                        console.log '开售ing, 缺货'
                        node =
                            <div>
                                <div className="u-mb_15 u-mt_25">
                                    <span className="btn btn-larger-big btn-color-red disabled" >太抢手了  暂时缺货</span>
                                    <span className="u-ml_20">已经有<span className="u-color_red">{current.total_booking}</span>人预定</span>
                                </div>
                                {time}
                            </div>
            # 没有当前批次, 应该是最后一个批次和活动结束之间这段时间
            # if not hasCurrentBatches and moment(server_time).isBefore(current.end_at)
            if (not current.next_valid_batch_id > 0) and DATE.diff(server_time, current.end_at) < 0
                console.log '没有当前批次'
                node =
                    <div>
                        <div className="u-mb_15 u-mt_25">
                            <span className="btn btn-larger-big btn-color-red disabled" >太抢手了  暂时缺货</span>
                            <span className="u-ml_20">已经有<span className="u-color_red">{current.total_booking}</span>人预定</span>
                        </div>
                        {time}
                    </div>

        # 预售完毕
        if DATE.diff(current.end_at, server_time) < 0
            console.log '预售完毕'
            node =
                <div>
                    <div className="u-mb_15 u-mt_25">
                        <a href="/item/#{sku_sn}.html" className="btn btn-larger-big btn-color-red">免预约直接购买</a>
                    </div>
                    {time}
                </div>

            price_name = '折扣价'
            presale_price = sku.price
            earnest_money = sku.price


        # 第一批开售前
        if DATE.diff(server_time, batches[0].begin_at) < 0
            console.log '第一批开售前'
            node =
                <div>
                    <div className="u-mb_15">
                        <SetMessageBtn />
                    </div>
                    {time}
                    <Coupon />
                </div>


        kefuImg = require('images/kefu.png')
        favImg = require('images/fav.png')

        classMap = {
            "rt-goods-info": true
        };

        classes = classnames(classMap, this.props.className);

        <aside {...this.props} ref="aside" className={classes}>
            <div className="title u-clearfix">
                <h2>{sku.goods.title}</h2>
                <div className="dotted-label">{tags}</div>
            </div>
            <div className="presales-block-1-price u-clearfix">
                <span className="u-fl u-color_red u-f18">{price_name}：￥ {presale_price}</span>
                <span className="u-fl u-color_gray u-f14 u-ml_10">／</span>
                <span className="u-fl u-color_gray u-del u-ml_5 u-f12">市场价：￥ {sku.basic_price}</span>
                <span className="u-fl u-ml_20">预售规则</span>
                <a className="u-ml_5 help-link" href="/article/#{current.article_id}"></a>
            </div>
            <div className="good-detail-box__main">
                <div className="good-detail-summary u-clearfix">
                    <ul>
                        <li className="good-detail-summary__stock u-clearfix">
                            <div className="dt">
                                配送至：
                            </div>
                            <div className="dd">
                                <div className="stock-btn" id="stock-btn">
                                    <a className="btn" href="#">
                                        <i className="_place_province" data-id="6">广东</i>
                                        <i className="_place_city" data-id="76">广州</i>
                                        <i className="_place_area" data-id="692">从化市</i>
                                        <i className="_place_town" data-id=""></i>
                                        <span className="iconfont icon-fanhui4"></span>
                                    </a>
                                </div>
                            </div>
                        </li>
                        <li className="good-detail-summary__logistic u-clearfix">
                            <div className="dt">
                                物流费：
                            </div>
                            <div className="dd u-mr_20">
                                ¥ <span id="j-delivery">{skuPicker.delivery || '0.00'}</span>
                            </div>
                            <div className="dt">
                                安装费：
                            </div>
                            <div className="dd">
                                ¥ <span id="j-delivery">{sku.installation || '0.00'}</span>
                            </div>
                        </li>
                    </ul>
                </div>
                <div className="good-detail-summary u-clearfix u-mt_15">
                    <ul>
                        <SkuSelector data={skuPickerData} onChange={@skuChange} />
                    </ul>
                </div>
            </div>
            {node}
            <div className="u-mt_10 u-mb_20">
                <Icon url={kefuImg} title="在线客服" onClick={@meqia} />
                <Line gray direction="vertical" className="u-ml_30 u-mr_20" />
                <Icon url={favImg} title="收藏" onClick={@like}/>
            </div>
        </aside>

module.exports = GoodsInfo;
