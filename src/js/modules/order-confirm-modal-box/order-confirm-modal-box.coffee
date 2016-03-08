# 模态框
tpl = require './tpl-layout.hbs'

module.exports = (options)->
    title = '还原订单'
    content = '该订单即将被还原，还原成功后，您可以在“我的订单”中查看。'

    modal = $.Modal
        title: title
        content: tpl content: content

    modal.on 'click', '.confirm', ->
        options.confirmCallback.call modal if typeof options.confirmCallback is 'function'
        modal.hide()

    return modal
