# for order-settlement Page
define ['PayOrderResultModalBox', 'modules/countdown/countdown'], (PayOrderResultModalBox, countdown)->
    require 'plugins'

    Fn = ->

    Fn.init = ->
        $payBtn = $("#j-pay-btn")
        active = '_active'
        $countdownTarget = $ '#j-countdown'

        $('[data-validity-end]').countdown
            onend: () ->
                $countdownTarget.html '订单状态：订单已取消'
                $payBtn.disable()

        # 支付弹窗
        payOrderResultModalBox= null
        $payBtn.on 'click', ->
            if $payBtn.isDisabled()
                return false

            if !payOrderResultModalBox
                payOrderResultModalBox = new PayOrderResultModalBox
                    top: 250
                    width: 400
                    mask: true
                    maskClose: true
                    closeBtn: true
            payOrderResultModalBox.show()


        $payType = $("#j-pay-type a")
        $payType.on "click", (e)->
            $this = $ @

            if $this.hasClass active
                return false

            href = $this.attr 'href'

            $payType.removeClass active
            $this.addClass active

            $payBtn.attr 'href', href

            return false


    Fn.init()
