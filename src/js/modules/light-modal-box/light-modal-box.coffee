# 模态框
define ['./tpl-layout.hbs'], (lightModalBox_layout)->
    class LightModalBox
        constructor: (@options)->
            this.options.closedCallback = @options.closedCallback || ->
            this.options.init = @options.init || ->
            this.id = "modal-" + new Date().getTime()
            this.modal = null
            this.render()
        show: ->
            $content = this.modal.find(".ui-modal__content>div")
            $dialog = this.modal
            this.modal.show()
            _width = this.options.width or $content.outerWidth()
            _height = this.options.height or $content.outerHeight()

            _width = Math.max(180, _width)

            $dialog.css
                width: _width
                opacity: 0.1
                top: 150

            $dialog.animate
                top: 200
                opacity: 1

            setTimeout ()=>
                this.close()
            , this.options.delay or 2000

        close: ->
            this.modal.remove()
            this.options.closedCallback()

        render: ->
            tpl = lightModalBox_layout({
                success: @options.status == "success"
                error: @options.status == "error"
                text: @options.text
            })
            tpl = $(tpl).attr("id", this.id )
            $("body").append(tpl)
            this.modal = $("#"+this.id)
            this.options.init()

    return LightModalBox
