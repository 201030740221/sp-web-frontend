# 订单详情页面逻辑
define ['NewAddress','DatePicker','./edit-order-info-modal-box.hbs', 'modules/countdown/countdown'], (NewAddress, DatePicker, editOrderInfoTpl, countdown)->

    require 'plugins'

    #API
    host = SP.config.host

    Api =
        updateOrderDelivery: '/order/updateOrderDelivery'
        cancelOrder: '/order/cancelOrder'

    Action =
        baseUrl: host + '/api'
        path: Api
        fn: (res)->
            #console.log res

        updateOrderDelivery: (data)->
            SP.post @baseUrl + @path.updateOrderDelivery, data, @fn, @fn
        cancelOrder: (data)->
            SP.post @baseUrl + @path.cancelOrder, data, @fn, @fn



    orderData = {}
    initData = null
    init_reserve_delivery_time = $('#j-predict-date-start').val()
    delivery_time_end = $('#j-predict-date-end').val()
    init_reserve_delivery_time = init_reserve_delivery_time.split(' ')[0]

    page = ->

    # 初始化页面
    page.init = ->
        order = null
        $edit = $ "#j-edit-order"
        $cancel = $ "#j-cancel-order"
        $print = $ "#j-print-order"
        $countdownTarget = $ '#j-countdown'
        $payBtn = $ '#j-pay-btn'
        setOrderData()
        if $edit.length
            $edit.on "click", =>
                order = new Order() if !order
                order.showWin()

        $('[data-validity-end]').countdown
            onend: () ->
                $countdownTarget.html '订单状态：订单已取消'
                $payBtn.disable()
                
        $payBtn.on 'click', ->
            return !$payBtn.isDisabled()

        $cancel.on "click", =>
            if initData.order_no && !$cancel.hasClass '_disable'
                SP.confirm
                    content: '您确定要取消该订单吗？'
                    confirm: ->
                        $cancel.addClass '_disable'
                        SP.notice '正在取消订单'

                        Action.cancelOrder order_no: initData.order_no, reason_id: 1 #暂时用默认值，以后需要做成可选取消订单原因
                        .done (res)->
                            if res.code == 0
                                SP.notice.success '取消订单成功'
                                reloadPage()

        $print.on "click", =>
            window.print()

        $deliveryTime = $ '#delivery-time-show'
        $installTime = $ '#install-time-show'
        deliveryTime = $deliveryTime.data 'date'
        installTime = $installTime.data 'date'

        if deliveryTime
            $deliveryTime.html DATE.format deliveryTime, 'yyyy-MM-dd 星期W'
        if installTime
            $installTime.html DATE.format installTime, 'yyyy-MM-dd 星期W'

    setOrderData = ()->
        $el = $ '#j-order-json'
        initData = JSON.parse $el.val()
        #orderData.delivery_id = initData.delivery_id
        orderData.order_no = initData.order_no

    reloadPage = ()->
        setTimeout ()->
            window.location.reload()
        , 1000


    #order
    class Order
        constructor: (options)->
            @options = $.extend {}, @defaults, options
            @_setOrderData()
            @_initElements()
            @

        defaults:
            name: 'Order'

        _initElements: ()->

        _bindEvt: ()->



        _setOrderData: ()->
            $el = $ '#j-order-json'
            data = JSON.parse $el.val()
            if !data.order_no 
                return false
                
            @data = data
            delivery = @data.delivery
            @address = delivery.member_address
            @date =
                reserve_delivery_time: delivery.reserve_delivery_time.split(' ')[0]
                reserve_installation_time: delivery.reserve_installation_time.split(' ')[0]
            orderData = $.extend orderData, @date
            orderData.member_address_id = delivery.member_address_id
            orderData.delivery_id = @data.delivery_id

        showWin: ()->
            _this = @

            if !@editOrderInfoModalBox
                $.Modal
                    title: '修改订单信息'
                    content: editOrderInfoTpl()
                    width: 635
                    onshow: ->
                        _this.editOrderInfoModalBox = this
                        _this.afterInitModal()
            else
                @editOrderInfoModalBox.show()
                #@newAddress.

        afterInitModal: ()->
            _this = @

            @$address = $ '.j-order-address-modified'
            @$save = $ '.j-order-save'
            @$address.newAddress
                data: @address
                type: 'updateOrder'
                order_no: @data.order_no
                saveSuccessThenDestroy: false
                validateFalseCallback: ()->
                    _this.$save.show().siblings().hide()
                callback: (data)->
                    orderData.member_address_id = data.id
                    Action.updateOrderDelivery orderData
                    .done (res)->
                        if res.code == 0
                            SP.notice.success '修改成功'
                            reloadPage()
                        else
                            SP.notice.error '系统错误，请稍后再试'
                            _this.$save.show().siblings().hide()
                    .fail (res)->
                        SP.notice.error '系统错误，请稍后再试'

                        _this.editOrderInfoModalBox.close()
                        _this.$save.show().siblings().hide()


                cancelCallback: ()=>
            @newAddress = @$address[0]._newAddress
            @$save.on 'click', ()=>
                @$save.hide().parent().append '<div>正在保存...</div>'
                @newAddress.save()

            if $('#j-not-only-textile').val() == '0'
                $('#order-edit-date-picker').hide()
                return false

            @initDatePicker()

        initDatePicker: ()->
            _this = @
            @$date = $ '.j-order-info-date'
            $deliver = @$date.find '#j-date-deliver'
            $install = @$date.find '#j-date-install'

            #console.log @date
            reserve_delivery_time = @date.reserve_delivery_time
            reserve_installation_time = @date.reserve_installation_time



            $install.on 'focus', ()->
                $(@).blur()

            if reserve_delivery_time is '0000-00-00'
                reserve_delivery_time = init_reserve_delivery_time
                orderData.reserve_delivery_time = ''
                orderData.reserve_installation_time = ''
            else
                $deliver.val reserve_delivery_time
                $install.val reserve_installation_time
                $install.datePicker(
                    parent: _this.editOrderInfoModalBox.getContainer()
                    initDate: SP.date.parse reserve_delivery_time
                    delay: 0
                    callback: (date)->
                        orderData.reserve_installation_time = date
                )


            # 计算可选结束时间
            oneDay = 1000 * 60 * 60 * 24
            endDate = DATE.parse delivery_time_end
            diffDay = (endDate - DATE.parse(init_reserve_delivery_time)) / oneDay

            $deliver.datePicker(
                parent: _this.editOrderInfoModalBox.getContainer()
                initDate: DATE.parse init_reserve_delivery_time
                lastDate: diffDay
                delay: 0
                callback: (date)->
                    disabled = {}
                    $install.val date
                    $install.off 'focus'

                    installDiffDay = (endDate - DATE.parse(date)) / oneDay

                    $install.datePicker(
                        parent: _this.editOrderInfoModalBox.getContainer()
                        initDate: date
                        lastDate: installDiffDay
                        delay: 0
                        disabled: disabled
                        callback: (date)->
                            orderData.reserve_installation_time = date
                    )

                    orderData.reserve_delivery_time = date
                    orderData.reserve_installation_time = date
            )
            $install.datePicker(
                parent: _this.editOrderInfoModalBox.getContainer()
                initDate: DATE.parse init_reserve_delivery_time
                lastDate: diffDay
                delay: 0
                callback: (date)->
                    orderData.reserve_installation_time = date
            )

    page.init()
