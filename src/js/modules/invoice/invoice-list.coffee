# 下拉选择框 SelectBox
define ['./tpl-invoice-list.hbs','NewInvoice','Checkbox'], (invoiceListTpl, NewInvoice, Checkbox)->
    #API
    host = SP.config.host
    #host = 'http://admin.sipin.benny:8000'

    Api =
        getInvoiceList: 'member/invoice'
        deleteInvoice: 'member/invoice/delete'

    Action =
        baseUrl: host + '/api/'
        path: Api
        fn: (res)->
            #console.log res

        getInvoiceList: (id)->
            param = ''
            SP.get @baseUrl + @path.getInvoiceList + param, {}, @fn, @fn

        deleteInvoice: (data)->
            SP.post @baseUrl + @path.deleteInvoice, data, @fn, @fn

    class InvoiceList
        constructor: (options)->
            if !options.el
                return false
            @options = $.extend {}, @defaults, @options, options
            @_init() if !@_invoiceList


        defaults:
            el: null
            name: name
            callback: (id)->
                #console.log 'defaults.callback ' + 'selected id : ' + id


        _init: ()->
            @$container = $ @options.el
            @_getInvoiceList()
            .done (res)=>
                if res.code is 0 then @_renderInvoiceList res.data
            @_invoiceList = @
            @

        #获取列表
        _getInvoiceList: ()->
            Action.getInvoiceList()
        _renderInvoiceList: (data)->
            @data = data
            tpl = invoiceListTpl data
            @$container.append tpl
            @_initElements()
            @_bindEvt()

        _initElements: ()->
            @$el = @$container.find '.address-list'
            @$items = @$el.find '.address-list__item'
            @$checkboxs = @$items.find '.address-list__checkbox'
            @$delBtn = @$items.find '.j-invoice-del'
            @$updateBtn = @$items.find '.j-invoice-update'
            @createInvoiceBtn = @$el.find '.j-invoice-create'
            @

        _bindEvt: ()->
            _this = @
            @$checkboxs.on 'click', (e)->
                $el = $ @

                if $el.data 'checked'
                    _this.$checkboxs.removeClass '_active'
                    _this._onCallback ''
                    $el.data 'checked', false
                    return

                _this.$checkboxs.data 'checked', false
                $el.data 'checked', true
                _this.$checkboxs.removeClass '_active'
                $el.addClass '_active'
                id = $el.closest('.address-list__item').data('id')
                title = $el.find('.invoice-title').text().trim()
                _this._onCallback id, title

            #del
            @$delBtn.on 'click', (e)->
                $el = $ @
                $parent = $el.closest '.address-list__item'
                id = $parent.data 'id'
                Action.deleteInvoice id: id
                .done (res)->
                    $parent.remove()

            #update
            @$updateBtn.on 'click', (e)->
                $el = $ @
                $parent = $el.closest '.address-list__item'
                $origin = $parent.children().hide()
                id = $parent.data 'id'
                $.each _this.data, (i,item)->
                    if item.id is id
                        $parent.newInvoice
                            type: 'update'
                            data: item
                            callback: (data)->
                                _this.$container.empty()
                                _this._renderInvoiceList data
                            cancelCallback: ()=>
                                $origin.show()

            #增加新发票btn
            @createInvoiceBtn.on 'click', (e)=>
                @createInvoiceBtn.hide()
                @$container.newInvoice
                    callback: (data)->
                        _this.$container.empty()
                        _this._renderInvoiceList data
                    cancelCallback: ()=>
                        @createInvoiceBtn.show()


            @

        _offEvt: ()->

            @

        _onCallback: (id, title)->
            @options.callback.call(@$container, id, title) if typeof @options.callback is 'function'

        _destroy: ()->
            @$el.empty().remove()
            if @options.el._invoiceList
                delete @options.el._invoiceList


    #export to JQ
    $.fn.invoiceList = (options, options2)->
        ret = @
        @each ()->
            if typeof options is 'string' && @_invoiceList
                switch options
                    when 'off' then @_invoiceList._offEvt()
            else
                opts = $.extend {},options,{el: @}
                invoiceList = @_invoiceList
                if !invoiceList
                    invoiceList = new InvoiceList(opts)
                else
                    #@_invoiceList.reset(opts)
                @_invoiceList = invoiceList
        return ret



    Fn = (options)->
        if options.el
            $el = $ options.el
            return $el.each ()->
                opts = $.extend {},options,{el: @}
                invoiceList = @_invoiceList
                if !invoiceList
                    invoiceList = new InvoiceList(opts)
#                else
#                    @_invoiceList.reset(opts)
                @_invoiceList = invoiceList
        else
            SP.log 'el is null'
            return false

    Fn
