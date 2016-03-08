# 模态框
ModalBox = require('ModalBox');

class reactModalBox extends ModalBox
    constructor: (@options)->
        self = this
        @options.template = '<div class="ui-modal__content-main"></div>'
        @options.init = =>
            component = @options.component
            ReactDom.render(component, $('#'+self.id).find('.ui-modal__content-main')[0]);
        super
    destroy: () ->
        ReactDom.unmountComponentAtNode(@modal.find('.ui-modal__content-main')[0]);
        super


module.exports = reactModalBox
