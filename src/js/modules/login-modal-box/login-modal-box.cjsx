# 模态框
define ['ModalBox','./tpl-layout.hbs','modules/components/loginbox'], (ModalBox,loginModalBox_tpl,Loginbox)->
    class loginModalBox extends ModalBox
        constructor: (@options)->
            @options.template = @options.template || loginModalBox_tpl({})
            @options.width = @options.width || 440
            super
            @_initModal()

        _initModal: ()->
            _this = @
            ReactDom.render <Loginbox pageType="pop" success={_this.options.loginSuccessCallback||()->} />, @modal.find('#loginbox-pop-wrap')[0]

    return  loginModalBox
