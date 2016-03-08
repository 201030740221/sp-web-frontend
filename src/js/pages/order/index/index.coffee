# order-list
define ['Checkbox','CheckAll','SelectBox' ,'modules/order-confirm-modal-box/order-confirm-modal-box'], ( Checkbox, CheckAll, SelectBox,orderConfirmModalBox)->
    countdown = require 'modules/countdown/countdown'


    #API
    host = SP.config.host

    Api =
        cancelOrder: '/order/cancelOrder'
        deleteOrder: '/order/deleteOrder'
        resetOrder: '/order/restoreOrder'

    Action =
        baseUrl: host + '/api'
        path: Api
        fn: (res)->
            #console.log res

        cancelOrder: (data)->
            SP.post @baseUrl + @path.cancelOrder, data, @fn, @fn
        deleteOrder: (data)->
            SP.post @baseUrl + @path.deleteOrder, data, @fn, @fn
        resetOrder: (data)->
            SP.post @baseUrl + @path.resetOrder, data, @fn, @fn


    Fn = ->

    Fn.init = ->
        initCheckbox $ '.order-list-table'
        initSelectBox()
        initSearch()
        bindEvt()
        $('[data-validity-end]').countdown({
                onend: (target)->
                    target.closest('div').html '订单已取消'
            })

    initCheckbox = ($el)->
        #多选
        $el.checkAll(
            checkboxClass: '.ui-checkbox'
            callback: (checked, $el)->
                #console.log(checked, $el)
        )
        #单选
        ###$checkbox = $el.find('.ui-checkbox')
        $checkbox.checkbox(
            callback: (checked, $el)->
                #console.log(checked, $el)
                action = if checked then 'on' else 'off'
                $checkbox.checkbox 'off',true
                $el.checkbox action,true
        )###
        #$el.find('.ui-checkbox').hide()
    initSelectBox = ()->
        selectBox = new SelectBox
            el: $ '.ui-select-box'
            callback: (value, text)->
                getQuery = SP.getQuery

                path = location.pathname
                params = getQuery()

                # 算时间
                now = new Date().getTime()
                half_year = 1000 * 60 * 60 * 24 * 182.5
                times =
                    'half_year': half_year
                    'one_year': half_year * 2

                begin_at_type = $('#j-select-time input').val()
                status_id = $('#j-select-status input').val()

                if begin_at_type != 'all'
                    params.begin_at_type = begin_at_type #SP.date.format(new Date(now - times[begin_at]))
                else
                    delete params.begin_at_type
                if status_id != 'all'
                    params.status_id = status_id
                else
                    delete params.status_id

                params = $.param params

                path += '?' + params
                console.log('filter path: ', path)
                location.href = path

    bindEvt = ()->
        $bd = $ '.cart-table__bd'
        $item = $bd.find '.cart-table__item'
        $cancel = $item.find '.j-order-cancel'
        $reset = $item.find '.j-order-restore'
        $delete = $item.find '.j-order-delete'
        $buy = $item.find '.j-order-buy'
        $rebuy = $item.find '.j-order-rebuy'

        $pay = $ '#j-order-pay'
        $go = $ '#j-page-go'
        $number = $ '#j-page-number'

        $cancel.on 'click', ()->
            $el = $ @
            $parent = $el.closest '.cart-table__item'
            order_no = $parent.data 'order-no'

            SP.confirm
                confirm: ->
                    Action.cancelOrder
                        order_no: order_no
                        reason_id: 1 #暂时用默认值，以后需要做成可选取消订单原因
                    .done (res)->
                        if res.code is 0
                            window.location.reload()

        $reset.on 'click', ()->
            $el = $ @
            $parent = $el.closest '.cart-table__item'
            order_no = $parent.data 'order-no'

            orderConfirmModalBox
                confirmCallback: ()->
                    Action.resetOrder
                        order_no: order_no
                    .done (res)->
                        if res.code is 0
                            window.location.reload()

        $item.on 'click', '.j-order-delete', ()->
            $this = $ @
            $item = $this.closest '.cart-table__item'
            order_no = $item.data 'order-no'
            SP.confirm
                confirm: ->
                    Action.deleteOrder
                        order_no: order_no
                    .done (res)->
                        if res.code is 0
                            $item.remove()

        $pay.on 'click', ()->
            order_nos = []
            $checkbox = $bd.find '.ui-checkbox'
            $.each $checkbox, ()->
                $el = $ @
                $parent = $el.closest '.cart-table__item'
                order_no = $parent.data 'order-no'
                order_nos.push order_no if $el.checkbox 'check'

            if !order_nos.length
                SP.alert '您未选择需要合并付款的订单！'
                return false

            $('#j-order-pay-nos').val order_nos.join ','
            $('#j-order-pay-form').submit()

        $(document).on 'mouseenter', '.j-order-tracking', ()->
            $el = $ @
            $parent = $el.closest '.cart-table__item'
            $log = $parent.find '.order-list-log'
            $log.show()
            $log.offset
                top:  $el.offset().top
        .on 'mouseleave', '.order-list-log', ()->
            $el = $ @
            $parent = $el.closest '.cart-table__item'
            $log = $parent.find '.order-list-log'
            $log.hide()

        # $go.on 'click', ()->
        #     $el = $ @
        # $number.on 'blur', (e)->
        #     $el = $ @
        #     value = $el.val()|0
        #     max = $el.data 'max'
        #     max = max|0
        #     if value > max then value = max
        #     $el.val value
        #
        #     url = $go.attr 'href'
        #
        #     reg = /page=([0-9])*/g
        #
        #     url = url.replace reg, 'page='+value
        #
        #     $go.attr 'href', url



    initSearch = ()->
        $el = $ '.ui-search'
        $ipt = $el.find '.ui-search__ipt'
        $ipt.on 'focus', (e)->
            $el.addClass '_active'
        .on 'blur', (e)->
            $el.removeClass '_active'


    Fn.init()
