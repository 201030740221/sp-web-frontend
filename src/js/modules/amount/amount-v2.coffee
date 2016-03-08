# 下拉选择框 SelectBox
define [], ()->
#    sass = require './sass_amount'

    name = 'Amount'
    class Amount
        constructor: (options)->
            if !options.el
                #console.log 'el is null'
                return false
            @options = $.extend {}, @defaults, @options, options
            @_init() if !@_amount


        defaults:
            el: null
            name: name
            #beforeChange: (value, newValue)->
                ##console.log 'defaults.callback.' + 'value:' + value + ' newValue:' + newValue
            callback: (value)->
                #console.log 'defaults.callback.' + 'value:' + value


        _init: ()->
            @_initElements()
            @_bindEvt()
            @_amount = @
            @

        _initElements: ()->
            @$el = $ @options.el
            @$up = @$el.find '.amount-box__btns-up'
            @$down = @$el.find '.amount-box__btns-down'
            @$ipt = @$el.find '.amount-box__input input'
            @value = @$ipt.val()|0
            @$ipt.val @value
            @max = (@$ipt.data 'max')|0
            @min = (@$ipt.data 'min')|0
            @


        _bindEvt: ()->
            @$up.on 'click.' + @options.name, ()=>
                @_onChangeValue '+'

            @$down.on 'click.' + @options.name, ()=>
                @_onChangeValue '-'

#            http://stackoverflow.com/questions/469357/html-text-input-allow-only-numeric-input
            @$ipt.on 'keydown.' + @options.name, (e)=>
                console.log e.keyCode
                if $.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) isnt -1 or
                    (e.keyCode == 65 and e.ctrlKey is true) or
                    (e.keyCode == 67 and e.ctrlKey is true) or
                    (e.keyCode == 88 and e.ctrlKey is true) or
                    (e.keyCode >= 35 and e.keyCode <= 39)
                        return

                if (e.shiftKey or (e.keyCode < 48 or e.keyCode > 57)) and (e.keyCode < 96 or e.keyCode > 105)
                    e.preventDefault()
                    console.log '!'

            @$ipt.on 'blur.' + @options.name, ()=>
                @_onChangeValue 'input'

            @

        _offEvt: ()->
            @$up.off 'click.' + @options.name

            @$down.off 'click.' + @options.name

            @$ipt.off 'keydown.' + @options.name

            @$ipt.off 'blur.' + @options.name

            @

        _onCallback: (value)->
            @options.callback.call(@$el, value) if typeof @options.callback is 'function'


        _onChangeValue: (type)->
            value = @value
            iptValue = @$ipt.val()|0
            switch type
                when '+' then value = @value + 1 if @value < @max - 1
                when '-' then value = @value - 1 if @value > @min + 1
                when 'input'
                    if iptValue < @min
                        value = @min
                    else if iptValue > @max
                        value = @max
                    else
                        value = iptValue
            @_setValue(value, @value)

        _setValue: (value, oldValue)->
            @value = value
            @$ipt.val value
            @_onCallback value if value isnt oldValue




    #export to JQ
    $.fn.amount = (options, options2)->
        ret = @
        @each ()->
            if typeof options is 'string' && @_amount
                switch options
                    when '+' then @_amount._onChangeValue '+'
                    when '_' then @_amount._onChangeValue '-'
                    when 'off' then @_amount._offEvt()
                    when 'on' then @_amount._bindEvt()
            else
                opts = $.extend {},options,{el: @}
                amount = @_amount
                if !amount
                    amount = new Amount(opts)
                else
                    @_amount.reset(opts)
                @_amount = amount
        return ret



    Fn = (options)->
        if options.el
            $el = $ options.el
            return $el.each ()->
                opts = $.extend {},options,{el: @}
                amount = @_amount
                if !amount
                    amount = new Amount(opts)
#                else
#                    @_amount.reset(opts)
                @_amount = amount
        else
            SP.log 'el is null'
            return false

    Fn
