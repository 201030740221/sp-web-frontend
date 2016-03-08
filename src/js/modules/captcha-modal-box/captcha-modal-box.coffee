# 模态框
# 警告提示框
define ['ModalBox','./tpl-layout'], (ModalBox,tpl)->
    class CaptchaModalBox extends ModalBox
        constructor: (@options)->
            @options = $.extend {
                title: '操作提示'
                content: '您当前的操作无法继续！'
                width: 400
                top: 200
                mask: true
                closeBtn: false
                time: +new Date
            }, @options;

            @options.template = @options.template || tpl(@options)

            super @options
        render: ()->
            super
            $ok = this.modal.find '.confirm-modal-box__ok'

            $input = this.modal.find 'input'

            $captcha = this.modal.find '.captcha-modal-updater'
            $captcha.on 'click', ->
                api = $captcha.data 'src'
                api += '?' + new Date

                $captcha.attr 'src', api

            $error = this.modal.find '.captcha-error-show'
            $input.focus ->
                $error.empty()

            $ok.on 'click', ()=>
                captcha = $.trim($input.val())

                if !captcha
                    $error.html '请输入验证码'
                    return false

                @options.callback.call $input, captcha, $error
                return false

    return CaptchaModalBox
