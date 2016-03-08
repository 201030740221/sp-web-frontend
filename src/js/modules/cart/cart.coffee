# 下拉选择框 SelectBox
define ['./tpl-layout.hbs','./tpl-empty.hbs'], (cartTpl, cartEmptyTpl)->
    name = 'cart'

    class Cart
        constructor: (options)->
            if !options.el
                #console.log 'el is null'
                return false
            @options = $.extend {}, @defaults, @options, options
            @_init() if !@_cart
            @


        defaults:
            el: null
            name: name
            callback: (value)->
                #console.log 'defaults.callback ' + 'value: ' + value


        _init: ()->
            @$el = $ @options.el
            @$container = @$el.parent()
            @$content = @$container.find '.header-cart__content'
            @shouldUpdate = 1
            # @_renderEmptyCart()
            @$content.html '<p class="ui-loading"></p>'

            @$container.on 'mouseenter', '#j-cart-btn', ()=>
                @_getCart()
            @_cart = @
            SP.Cart = @

            @_bindEvt()

            @

        _getTotalPrice: (data) ->
            totalPrice = 0
            data.items.map (item) ->
                totalPrice = SP.Math.Add totalPrice, item.price, 2
            totalPrice

        #获取列表
        _renderCart: (data)->
            _this = @
            @data = data
            if  data.items and data.items.length
                data.total_price = @_getTotalPrice(data)
                tpl = cartTpl data
                @$content.html tpl
                @_initElements()

            else
                @_renderEmptyCart()

        _renderEmptyCart: ()->
            tpl = cartEmptyTpl {}
            @$content.html tpl

        _getCart: ()->
            if  !@data or @shouldUpdate
                @shouldUpdate = 0
                webapi.cart.get()
                .then (res)=>
                    if res.code is 0
                        @_renderCart res.data
                    else
                        @_renderEmptyCart()
                .fail (res)=>
                    @_renderEmptyCart()
            # else
            #     @_renderCart @data

        _deleteSku: (id)->
            postData =
                "item_keys": [id]
            webapi.cart.remove postData
            .then (res)=>
                if res.code is 0
                    @_renderCart res.data
                    SP.notice.success '删除成功'
                    SP.trigger SP.events.cart_goods_quantity_update, res.data.total_quantity
                else
                    SP.notice.error '删除失败'
            .fail (res) ->
                SP.notice.error '删除失败'

        _initElements: ()->
            @$item = @$container.find '.header-cart__item'
            @

        _bindEvt: ()->
            _this = @

            @$container.on 'click', '.header-cart__item-del, .item-del', (e)->
                $el = $ @
                id = $el.data 'item-id'
                _this._deleteSku id
            @

        _offEvt: ()->

            @

        _onCallback: (value)->
            @options.callback.call(@$container, value) if typeof @options.callback is 'function'

        _destroy: ()->
            @$el.empty().remove()
            if @options.el._cart
                delete @options.el._cart

        setShouldUpdate: ()->
            #console.log 'cart will update'
            @shouldUpdate = 1


    #export to JQ
    $.fn.cart = (options, options2)->
        ret = @
        @each ()->
            if typeof options is 'string' && @_cart
                switch options
                    when 'off' then @_cart._offEvt()
                    when 'setShouldUpdate' then @_cart.setShouldUpdate()
            else
                opts = $.extend {},options,{el: @}
                cart = @_cart
                if !cart
                    cart = new Cart(opts)
                else
                    #@_cart.reset(opts)
                @_cart = cart
        return ret



    Fn = (options)->
        if options.el
            $el = $ options.el
            return $el.each ()->
                opts = $.extend {},options,{el: @}
                cart = @_cart
                if !cart
                    cart = new Cart(opts)
#                else
#                    @_cart.reset(opts)
                @_cart = cart
        else
            SP.log 'el is null'
            return false

    Fn
