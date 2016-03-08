# 模态框
define ['ModalBox', './tpl-layout.hbs',
        './tpl-confirm.hbs'], (ModalBox, payOrderResultModalBox_tpl, payOrderResultConfirmModalBox_tpl)->
    class PayOrderResultModalBox extends ModalBox
        constructor: (@options)->
            @options.template = @options.template || payOrderResultModalBox_tpl({})
            super

            _this = @
            @order_no = $('.order-info-compete').data 'order-no'

            $(document).on "click", "#j-finish-pay", ->
                SP.get '/api/order/getOrderStatus', {
                    order_no: _this.order_no
                }, (res)->
                    # 支付成功
                    if res.code is 0 and res.data.status_id is 2
                        _this.jump()
                    else
                        time = 5
                        $this = $("#" + _this.id)

                        $this.find(".ui-modal__box").remove()
                        $this.find(".ui-modal__content").append(payOrderResultConfirmModalBox_tpl({'time': time}))

                        timeElement = $this.find(".u-color_darkred")
                        timer = setInterval ->
                            if(time<=1)
                                clearInterval timer
                                _this.jump()
                            timeElement.text --time
                        ,1000

                return false;
        jump: ->
            window.location.href = '/order/detail?order_no=' + this.order_no
    return  PayOrderResultModalBox
