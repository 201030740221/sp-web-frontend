require 'modules/plugins/jquery.modal'
confirmTpl = require './tpl-layout.hbs'

module.exports = (options)->
    options = $.extend
        title: '操作提示'
        content: '您确认执行该操作吗?'
        closeBtn: false
        maskClose: false
        width: 400
        confirm: -> # 确认的回调
        cancel: -> # 取消的回调
    , options

    $doc = $ document
    name = 'is-confirm-opening'
    # confirm只弹出一次
    # 曽出现链接触发confirm，连续enter键，会不断弹出
    if $doc.data name
        return

    $doc.data name, 1

    options.content = confirmTpl options

    confirmModal = $.Modal options

    confirmModal.on 'click', '.modal-confirm-footer a', ->
        actionName = $(this).data 'action'
        closing = options[actionName].call confirmModal

        if closing isnt false
            confirmModal.close()
            $doc.removeData name

    return confirmModal

