# 模态框
# 警告提示框
require 'modules/plugins/jquery.modal'
alertTpl = require './tpl-layout.hbs'

module.exports = (options)->
    options = $.extend
        title: '操作提示'
        content: '您当前的操作无法继续!'
        closeBtn: false
        maskClose: false
        width: 400
        confirm: -> # 确认的回调
    , options

    options.content = alertTpl options

    alertModal = $.Modal options

    alertModal.on 'click', '.modal-confirm-footer a', ->
        actionName = $(this).data 'action'
        closing = options[actionName].call alertModal

        if closing isnt false
            alertModal.remove()

    return alertModal