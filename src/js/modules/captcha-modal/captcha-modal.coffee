# 模态框
# 警告提示框
template = require './tpl-layout.hbs'

getCaptchaSrc = ->
    time = +new Date
    api = sipinConfig.apiHost + "/captcha?#{time}"

    return api

module.exports = (callback, showCallback)->
    showCallback = showCallback or ->
        
    options =
        title: '请输入图形验证码'
        maskClose: false
        width: 400

    options.content = template captcha: getCaptchaSrc()

    modal = $.Modal options
    $modal = modal.getContainer()

    $error = $modal.find '.error'
    $input = $modal.find '.captcha-inputer'

    showCallback($modal);

    $input.on 'focus', ->
        $error.hide()
    .on 'keyup', (e)->
        if e.keyCode == 13
            $modal.find '.confirm'
            .trigger 'click'
        return false

    modal.on 'click', '.confirm', ->
        captcha = $.trim $input.val()

        if !captcha
            $error.show().html '请输入验证码'
            return

        $error.hide()

        callback.call $input, captcha, $error

    modal.on 'click', '.captcha-image', ->
        $(this).attr 'src', getCaptchaSrc()

    return modal
