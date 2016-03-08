# for order-settlement Page
define ['DatePicker','AddressList','InvoiceList','Checkbox'], (DatePicker, AddressList, InvoiceList, Checkbox)->

    require 'modules/plugins/jquery.amount'
    require 'modules/plugins/jquery.form'
    validator = new (require('Validator'))
    Coupon = require './coupon'

    total_price = 0

    orderData =
        member_address_id: ''
        reserve_delivery_time: ''
        reserve_installation_time: ''
        invoice_id: ''
        note: ''
        coupon_ids: ''
        service_card_ids: ''

    orderData = $.extend orderData, $('#param-filed').serializeMap separator: null

    submitState =
        priceState: false

    Fn = ->

    Fn.init = ->
        new AddressList
            el:'#j-order-info-address'
            callback: (address_id, region_id, type)->
                if type is 2 #新增地址放到前面并选中
                    $addressList = $('#j-order-info-address').find('.address-list')
                    $addressList
                    .find('.address-list__item')
                    .last()
                    .prependTo($addressList)
                    .find('.address-list__checkbox')
                    .trigger('click')
                    return null

                # 给优惠券使用
                SP.checkout_region_id = region_id
                orderData.region_id = SP.checkout_region_id
                orderData.member_address_id = address_id
                # 更新价格
                updatePrice region_id : region_id
                # 更新送装时间
                data =
                    region_id: region_id
                    quickbuy: orderData.quickbuy or orderData.presale or orderData.flashsale or 0
                webapi.checkout.getPredictDelivery data
                .then (res)->
                    initDate = null
                    if res.code is 0
                        initDate = res.data
                    initDatePicker initDate, false

        initDatePicker({})
        initInvoice()
        initPoint()
        initSubmit()
        initNote()
        initEarnest()

    handleSubmitable = (options)->
        $.extend submitState, options if options
        $submit = $ '#j-order-submit'

        for key, value of submitState
            unless value
                $submit.addClass '_disable'
                return false

        $submit.removeClass '_disable'
        return true


    updatePrice = (params, callback)->
        params = $.extend orderData, params

        if !params.region_id
            SP.notice.error('请先选择收货地址!')
            return false

        webapi.checkout.getCheckoutPrice params
        .then (res)->
            $used = $ '#point-used'
            if res.code is 0 and res.data and res.data isnt -1
                total_price = res.data.total_price

                if orderData.order_type isnt '1' # 预售商品订单定金支付不需要更新价格
                    $('#j-total-price').html res.data.total_price
                    $('#j-total-delivery').html res.data.total_delivery
                    $('#j-total-installation').html res.data.total_installation
                    $('#j-total-amount').html res.data.total_amount
                    $('#j-total').html res.data.total
                    $('#income-point').html Math.ceil(res.data.total)

                derate = SP.Math.Add(res.data.delivery_abatement, res.data.installation_abatement)
                $derate = $('#j-total-delivery-installation-abatement').html derate.toFixed(2)
                $coupon = $('#j-total-coupon').html res.data.coupon_abatement

                # 积分
                pointCount = SP.Math.Mul(res.data.point_abatement, 100)
                pointTotal = SP.Math.Add(pointCount, res.data.total_point) # total_point 积分商品
                pointText = "#{pointTotal}积分"
                pointText += "(-￥#{res.data.point_abatement})" if res.data.point_abatement
                orderData.point = pointCount || 0
                $used.html pointText
                $('#j-point-box').amountVal pointCount # 重新赋值给使用积分

                # 减免，优惠券，消耗积分的显示或隐藏
                $derate.closest('li').toggle !!derate
                $coupon.closest('li').toggle !!Number(res.data.coupon_abatement)
                $used.closest('li').toggle !!pointTotal

                # 更新优惠券
                initCoupon(total_price)
                initService(total_price)

                handleSubmitable priceState: true
            else
                $('#j-total-price').html '-'
                $('#j-total-delivery').html '-'
                $('#j-total-installation').html '-'
                $('#j-total-coupon').html '-'
                $('#j-total-delivery-installation-abatement').html '-'
                $('#j-total-amount').html '-'
                $('#j-total').html '-'
                $('#income-point').html '-'
                $used.html '-'

                orderData.member_address_id = ''
                handleSubmitable priceState: false
                SP.notice.error '价格计算错误，请联系客服！'

            callback(res) if typeof callback is 'function'

    initNote = ()->
        $box = $ '#j-order-comment-box'
        $note = $box.find '.form-textarea'
        $info = $ '<div>还可以输入<span class="ui-emphasis">200</span>字</div>'
        $info.css 'width',$note.outerWidth()
        $box.append $info
        $num = $info.find 'span'
        $note.on 'input', ()->
            val = $(@).val()
            $num.html 200 - val.length
            if val.length > 200
                $(@).val val.slice 0,200
                $num.html 0

    initInvoice = ()->
        $section = $ '#j-invoice-option'
        $tip = $section.find '.tip'
        $el = $ '#j-show-invoice'
        $box = $ '#j-order-invoice-box'
        new InvoiceList
            el:'#j-order-invoice-box'
            callback: (id, title)->
                orderData.invoice_id = id
                if title
                    $tip.text title
                    .addClass '_active'
                else
                    $tip.text '未选择发票'
                    .removeClass '_active'
        $el.checkbox
            callback: (value)->
                if value
                    $box.show()
                else
                    $box.hide()

    initPoint = ()->
        $el = $ '#j-point-show'
        $box = $ '#j-point-box'
        $pointUsed = $ '#j-point-used'
        $pointToMoney = $ '#point-to-money'
        $save = $ '#point-use-save'
        $cancel = $ '#point-use-cancel'

        $el.checkbox
            callback: (value)->
                if value
                    $box.show()
                else
                    $box.hide()

        $box.amount
            'onchange': (value)->
                max = this.data 'max'
                return (newNum, oldNum)->
                    if isNaN(newNum)
                        newNum = ''
                    else if newNum > max
                        SP.notice.error '超出可使用积分'
                        newNum = max
                    else
                        yuan = SP.Math.Div newNum, 100, 2
                        $pointToMoney.html "-￥#{yuan}"
                    this.val newNum

        $save.on 'click', ->
            pointCount = $box.amountVal() || 0

            if !SP.checkout_region_id
                SP.notice.error '请先选择收货地址'
                return

            updatePrice
                point: pointCount
                , ->
                    updatedPoint = $box.amountVal()
                    if +updatedPoint < +pointCount
                        yuan = SP.Math.Div updatedPoint, 100, 2
                        $pointUsed.html "本次最多能使用积分#{updatedPoint}，折合人民币￥#{yuan}元"
                    else
                        yuan = SP.Math.Div pointCount, 100, 2
                        $pointUsed.html "使用积分#{pointCount}，折合人民币￥#{yuan}元"

                    if updatedPoint > 0
                        $pointUsed.addClass '_active'
                    else
                        $pointUsed.html '未使用积分'
                        .removeClass '_active'

        $cancel.on 'click', ->
            $box.amountVal ''
            $pointUsed.html '未使用积分'
            .removeClass '_active'
            orderData.point = 0

            updatePrice
                point: 0

    initDatePicker = (initDate, reset)->
        $deliver = $ '#j-date-deliver'
        $install = $ '#j-date-install'

        cb = (e) ->
            SP.notice.error '请先选择或填写配送地址！' unless orderData.region_id
        $deliver.on 'click', cb
        $install.on 'click', cb

        startDate = initDate.start
        endDate = initDate.end

        if !startDate
            # window.console && console.error '无法获取初始送装时间'
            return

        earliestDate =  DATE.parse startDate
        earliestDateFormated = SP.date.format earliestDate

        oneDay = 1000 * 60 * 60 * 24
        endDate = DATE.parse endDate
        diffDay = (endDate - earliestDate) / oneDay

        # 未选择日期，设置默认送装日期
        orderData.reserve_delivery_time = startDate
        orderData.reserve_installation_time = startDate
        $deliver.val earliestDateFormated
        $install.val earliestDateFormated

        if reset
            $deliver.val ''
            $install.val ''

        $deliver.datePicker(
            initDate: earliestDate
            lastDate: diffDay
            callback: (date_value)->
                date = DATE.parse date_value

                if date > DATE.parse(orderData.reserve_installation_time)
                    $install.val date_value
                    orderData.reserve_installation_time = date_value

                orderData.reserve_delivery_time = date_value

                $install.datePicker(
                    initDate: date_value
                    lastDate: (endDate - date) / oneDay
                    disabled: {}
                    callback: (date_value)->
                        orderData.reserve_installation_time = date_value
                )
        )

        $install.datePicker(
            initDate: earliestDate
            lastDate: (endDate - DATE.parse(orderData.reserve_delivery_time)) / oneDay
            disabled: {}
            callback: (date_value)->
                orderData.reserve_installation_time = date_value
        )

    initCoupon = (total_price) ->
        $coupon = $ '#j-coupon-option'
        if !$coupon.length
            return false

        ReactDom.render(React.createElement(Coupon, {
            type: 'coupon'
            total_price: total_price
            category_ids: orderData.category_ids
            goods_ids: orderData.goods_ids
            callback: (ids) ->
                orderData.coupon_ids = ids
                if ids and orderData.service_card_ids
                    ids = ids + ',' + orderData.service_card_ids
                else if orderData.service_card_ids
                    ids = orderData.service_card_ids
                updatePrice coupon_ids: ids
        }), $coupon[0]);

    initService = (total_price) ->
        $serviceCard = $ '#j-service-option'
        if !$serviceCard.length
            return false

        ReactDom.render(React.createElement(Coupon, {
            type: 'service'
            total_price: total_price
            category_ids: orderData.category_ids
            goods_ids: orderData.goods_ids
            callback: (ids) ->
                orderData.service_card_ids = ids
                if ids and orderData.coupon_ids
                    ids = ids + ',' + orderData.coupon_ids
                else if orderData.coupon_ids
                    ids = orderData.coupon_ids
                updatePrice coupon_ids: ids
        }), $serviceCard[0]);

    initEarnest = ->
        $input = $ '#j-presale-notice'
        $checkbox = $ '#j-presale-agree'
        $submit = $ '#j-order-submit'

        # SP.helloed.add ->
        #     $input.val SP.member.mobile or '' if $input.length

        return null unless $input.length

        phoneVerify = ->
            unless validator.verify 'phone', $input.val()
                handleSubmitable phoneState: false
                $submit.on 'click.phone_error', ->
                    SP.notice.error '请填写正确的手机号码！'
                return false
            else
                handleSubmitable phoneState: true
                $submit.off 'click.phone_error'
                return true

        phoneVerify()

        $input.on 'blur', ->
            unless phoneVerify()
                SP.notice.error '请填写正确的手机号码！'

        $checkbox.checkbox
            callback: (value) ->
                if value
                    handleSubmitable earnestState: true
                    $submit.off 'click.presale_earnest'
                else
                    handleSubmitable earnestState: false
                    $submit.on 'click.presale_earnest', ->
                        SP.notice.error '请选择同意支付定金'

    setData = ()->
        $note = $ '#j-order-comment-box .form-textarea'
        $presaleNotice = $ '#j-presale-notice'
        orderData.note = $note.val()
        orderData[$presaleNotice.attr('name')] = $presaleNotice.val() if $presaleNotice.length
        orderData

    initSubmit = ()->
        $el = $ '#j-order-submit'
        $el.on 'click', ()->
            if $el.hasClass '_disable'
                return false
            else
                postData = setData()
                $el.addClass '_disable'
                if postData.member_address_id
                    $form = $ '<form action="/order/create" method="POST"></form>'

                    for key of postData
                        if postData[key] instanceof Array
                            postData[key].map (item)->
                                $ipt = $ '<input type="hidden">'
                                $ipt.attr 'name', key
                                $ipt.val item
                                $form.append $ipt
                        else
                            $ipt = $ '<input type="hidden">'
                            $ipt.attr 'name', key
                            $ipt.val postData[key]
                            $form.append $ipt

                    $form.appendTo 'body'
                    $form.submit()
                else
                    return false

    Fn.init()
