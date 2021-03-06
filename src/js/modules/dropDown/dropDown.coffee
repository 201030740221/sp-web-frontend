# 下拉菜单
define ['./tpl_layout.hbs'], (dropDown_layout)->
    dropdownObj = []
    class DropDown
        constructor: (@options)->
            self = this
            #this.options.$target = $(options.target)
            this.clickTarget = if @options.event == 'mouseenter' then "mouseenter" else "click"
            this.leaveTarget = if @options.event == 'mouseenter' then "mouseleave" else "click"
            this._isover = false
            $(@options.target).each ->
                $(this).on self.clickTarget, ->
                    this._isover = false
                    self.options.$target = $(this)
                    self.render_layout()
                    return false
                if self.options.event == 'mouseenter'
                    $(self.options.target).on "mouseleave",->
                        setTimeout ->
                            if !self._isover
                                self.hide()
                        ,100

        render_layout: ->
            _this = this
            if(!this.dropDownBox)
                this.id = "dropDown-" + new Date().getTime()
                this.dropDownBox = null
                tpl = dropDown_layout({})
                if this.options.template
                    tpl = $(tpl).find(".ui-drop-down-box__inner").append(this.options.template).closest('.ui-drop-down-box').attr("id", this.id )
                else
                    tpl = $(tpl).closest('.ui-drop-down-box').attr("id", this.id )
                $("body").append(tpl)
                this.dropDownBox = $("#"+this.id)
                dropdownObj.push(this)
                this.options.render()
            this.show()
            $(window).off('.dropdown').on "resize.dropdown", this.resizeHander
            this.dropDownBox.find(".close").on "click", _this.hide

            this.dropDownBox.on "mouseover",=>
                this._isover = true
            this.dropDownBox.on "mouseleave",=>
                this._isover = false
                if this.options.event == 'mouseenter'
                    this.hide()

            $(document).off('.dropdown').on 'click.dropdown', (e)->
                $target = $ e.target
                $trigger = $target.closest _this.options.target
                $dropdown = $target.closest '.ui-drop-down-box'
                if !$dropdown.length && !$trigger.length
                    _this.hide()

        resizeHander: =>
            if(this.dropDownBox)
                this.dropDownBox.css
                    top:  this.options.$target.offset().top + this.options.$target.outerHeight()-1
                    left: this.options.$target.offset().left - 1
        show: =>
            self = this
            left = this.options.$target.offset().left
            ml = $(window).width()-left-this.options.$target.width()
            if(this.dropDownBox.width()+this.options.$target.offset().left>$(window).width())
                left = this.options.$target.offset().left - this.dropDownBox.width() + this.options.$target.outerWidth()

            if(this.dropDownBox.is(":hidden"))
                this.dropDownBox.css
                    left: left
                    top: this.options.$target.offset().top + this.options.$target.outerHeight()-1
                .addClass 'layer-show'
                .show()
                for dropdownObj_item in dropdownObj
                    if self != dropdownObj_item
                        dropdownObj_item.hide()
                #this.options.showFn?this.options.showFn()
            else
                this.hide()
                #this.options.hideFn?this.options.hideFn()
        hide: =>
            this.dropDownBox.hide().removeClass 'layer-show'
            #this.options.hideFn?this.options.hideFn()


    return  DropDown
