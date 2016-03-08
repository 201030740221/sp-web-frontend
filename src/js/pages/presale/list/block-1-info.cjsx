React = require 'react'
liteFlux = require 'lite-flux'

PresalesGoodsInfo = require './presales-goods-info.cjsx';
PresalesGoodsInfoModalBox = require 'modules/react-modal-box/index.cjsx'
Coupon = require './coupon'
SetMessageBtn = require './set-message-btn'
Store = require './_stores/presales-home'
Action = Store.getAction()
storeName = 'presales-home'

View = React.createClass
    mixins: [liteFlux.mixins.storeMixin(storeName)]

    showGoodsInfo: (event)->
        event.preventDefault()

        presalesGoodsInfoModalBox = new PresalesGoodsInfoModalBox
            width: 1024
            top: 100
            mask: true
            closeBtn: true
            component: <PresalesGoodsInfo />

        presalesGoodsInfoModalBox.show()

    render: ->
        store = @state[storeName]
        list = store.list
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

        if current.batches and current.batches.length
            current.batches.map (batches, j) =>
                # 找到当前批次
                if batches.id is current.next_valid_batch_id
                    hasCurrentBatches = yes
                    batches.skus.map (item, i) =>
                        if +sku.id is item.goods_sku_id
                            presale_price = item.presale_price
                            earnest_money = item.earnest_money


                    # 开售前
                    if DATE.diff(server_time, batches.begin_at) < 0
                        console.log '开售前'
                        time =
                            <div className="u-color_gray">
                                （注：首发预定时间：<span className="u-color_red">{batches.begin_at}</span>）
                            </div>
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

        # <div className="u-color_gray">
        #     （注：尾款需在2016-08-09 10:00内进行支付）
        # </div>
        # <div className="u-color_gray">
        #     （注：首发预定时间：<span className="u-color_red">2015-09-23 10:00</span>）
        # </div>
        # <div className="u-color_gray">
        #     （注：下批预定时间：<span className="u-color_red">2015-09-23 10:00</span>）
        # </div>



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
                                <SetMessageBtn requesterid={item.id} />
                            </div>
                            {time}
                        </div>
                
                    presale_price = current.presale_price_tip
                    earnest_money = current.earnest_money_tip
                # 开售ing
                else if DATE.diff(server_time, item.end_at) < 0
                    console.log '开售ing'
                    node =
                        <div>
                            <div className="u-mb_15 u-mt_25">
                                <a href="#" className="btn btn-larger-big btn-color-red" onClick={@showGoodsInfo}>定金￥ {earnest_money} 抢先预定</a>
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


        # 第一批开售前
        if DATE.diff(server_time, batches[0].begin_at) < 0
            console.log '第一批开售前'
            node =
                <div>
                    <div className="u-mb_15">
                        <SetMessageBtn  requesterid={batches[0].id}/>
                    </div>
                    {time}
                    <Coupon />
                </div>

        earnest_money_node =
            <div className="u-color_black u-f14">
                预付定金：￥ {earnest_money}
            </div>
        # 预售结束
        if DATE.diff(server_time, current.end_at) > 0
            price_name = '折扣价'
            presale_price = sku.price
            earnest_money = sku.price
            earnest_money_node = ''
            # if +sku.price is +sku.basic_price
            #     basic_price

        price_node =
            <div className="presales-block-1-price u-clearfix">
                <span className="u-fl u-color_red u-f18">{price_name}：￥ {presale_price}</span>
                <span className="u-fl u-color_gray u-f14 u-ml_10">／</span>
                <span className="u-fl u-color_gray u-del u-ml_5 u-f12">市场价：￥ {sku.basic_price}</span>
            </div>

        <div>
            <h2>{current.name}</h2>
            <div>{current.description}</div>
            <div className="u-mb_30">
                <a href="/presale/#{current.id}.html" className="detail-link">观看详情</a>
            </div>
            {price_node}
            {earnest_money_node}
            {node}
        </div>

module.exports = View
