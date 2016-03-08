# Coupon

CouponActivate = require 'modules/coupon/coupon-activate'

cx = SP.classSet

###
# CouponList.
# @author remiel.
# @module CouponList
# @example CouponList
#
#   jsx:
#   <CouponList extClass></CouponList>
#
# @param options {Object} the options
# @option extClass {String} add a class to the wrapper for style
#
###

CouponList = React.createClass
    onClick: (thisItem, i, e) ->
        return null if @props.type isnt 'usable'
        callback = @props.callback;
        callback.call @, thisItem, i if typeof callback is 'function'

    list: () ->
        items = @props.data.map (item, i) =>
            task = item.task
            classes  = cx
                '_disable': @props.type isnt 'usable'
                '_active': item._activeState
                'ui-lg-checkbox': true

            requirement = ''
            switch task.requirement
                when 0
                    requirement = '无条件'
                when 1
                    requirement = '满' + task.threshold + '元'

            couponValue = 0
            switch task.discount_type
                when 0
                    couponValue = '￥' + task.value
                when 1
                    couponValue = SP.Math.Mul(task.value, 10) + '折'
                when 2
                    couponValue = '安装服务卡'

            validity = item.valid_time_start_at.split(' ')[0] + ' ~ ' + item.valid_time_end_at.split(' ')[0]

            <li className={classes} key={i} onClick={@onClick.bind null, item, i}>
                <span className="item-name u-ellipse">{task.name}</span>
                <span className="item-value u-ellipse u-fr">{couponValue}</span>
                <span className="item-req">{requirement}</span>
                <span className="item-vd">有效期：{validity}</span>
            </li>

    render: ->
        <ul className="order-coupon__list u-clearfix">
            {@list()}
        </ul>



###
# Coupon.
# @author remiel.
# @module Coupon
# @example Coupon
#
#   jsx:
#   <Coupon extClass></Coupon>
#
# @param options {Object} the options
# @option extClass {String} add a class to the wrapper for style
#
###
Coupon = React.createClass
    getInitialState: ->
        keyMap: ['usable', 'unusable', 'outdated']
        active: 0
        selectedItem: {}
        isListShowing: false
        data:
            outdated: []
            unusable: []
            usable: []

    getDefaultProps: ->
        type: 'coupon'
        id: 0
        category_ids: ''
        goods_ids: ''

    compoentWillMount: ->

    componentDidMount: ->

    handleCouponList: ->
        _this = @
        if not @state.isListShowing
            data =
                total_price: _this.props.total_price
                filter: if @props.type is 'coupon' then 'coupon' else 'installation-card'
                category_ids: _this.props.category_ids.split ','
                goods_ids: _this.props.goods_ids.split ','
            webapi.coupon.getCheckoutCouponList(data).then (res) ->
                if res.code is 0
                    data = res.data
                    data.usable.map (item, i) ->
                        if item.id is _this.state.selectedItem.id
                            item._activeState = 1
                        else
                            item._activeState = 0
                    _this.setState data: data

        @setState isListShowing: not @state.isListShowing

    handleTabClick: (index, e) ->
        @setState active: index

    handleSelect: (thisItem, index) ->
        _this = @
        datas = @state.data
        data = @getActiveData()

        if thisItem._activeState is 1
            @cancelCoupon()
            data.map (item, i) ->
                item._activeState = 0
            @setState
                selectedItem: {}
        else
            data.map (item, i) ->
                if item.id is thisItem.id
                    item._activeState = 1
                    _this.setState
                        selectedItem: item
                else
                    item._activeState = 0
            @couponCallback thisItem.id

        @setState
            data: datas



    # 取消优惠券
    cancelCoupon: () ->
        @couponCallback ''
        @setState selectedItem: {}

    getActiveType: () ->
        @state.keyMap[@state.active]

    getActiveData: () ->
        @state.data[@getActiveType()]

    setTabClass: (index) ->
        cx
            'ui-tab__item':true
            '_active': index is @state.active

    #handleExchange
    handleExchange: () ->
        _this = @
        _this.cancelCoupon()
        data =
            total_price: _this.props.total_price
            filter: if @props.type is 'coupon' then 'coupon' else 'installation-card'
            category_ids: _this.props.category_ids.split ','
            goods_ids: _this.props.goods_ids.split ','
        webapi.coupon.getCheckoutCouponList data
        .then (res) ->
            _this.setState data: res.data if res.code is 0

    couponCallback: (ids) ->
        callback = @props.callback
        callback.call @, ids if typeof callback is 'function'


    render: ->
        type = @getActiveType()
        data = @getActiveData()
        tip = if @state.selectedItem.id then 'tip _active' else 'tip'
        collapse = if @state.isListShowing then 'ui-collapse _active' else 'ui-collapse'
        text = if @props.type is 'coupon' then '优惠券' else '安装服务卡'
        selected = if @state.selectedItem.id then '已使用' + @state.selectedItem.task.name else '未使用' + text

        <div>
            <div className="order-cart-table__options-hd form form-horizontal">
                <span className={collapse} onClick={@handleCouponList}> 使用{text}</span>
                <span className={tip}>{selected}</span>
            </div>
            <div className="order-coupon" id="j-order-coupon-box" style={{display: if @state.isListShowing then 'block' else 'none'}}>
                <div className="order-coupon__hd">
                    <div className="ui-tab u-clearfix">
                        <a className={@setTabClass(0)} href="javascript:;" onClick={@handleTabClick.bind null, 0}>可用{text} ( <span className="u-color_red">{@state.data[@state.keyMap[0]].length}</span> )</a>
                        <a className={@setTabClass(1)} href="javascript:;" onClick={@handleTabClick.bind null, 1}>不可用{text} ( <span className="u-color_red">{@state.data[@state.keyMap[1]].length}</span> )</a>
                    </div>
                </div>
                <div className="order-coupon__bd" id="j-coupon-list">
                    <CouponList data={data} type={type} callback={@handleSelect}></CouponList>
                </div>
                <div className="order-coupon__ft" style={{display: if @props.type is 'coupon' then 'block' else 'none'}}>
                    <CouponActivate type={text} successCallback={@handleExchange}></CouponActivate>
                </div>
            </div>
        </div>

module.exports = Coupon
