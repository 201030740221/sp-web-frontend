# 模态框
agreementModalBox_tpl = require './tpl-layout.hbs'

module.exports = ->
    $.Modal
        'width': 820
        'title': '斯品用户注册协议'
        'content': agreementModalBox_tpl()

