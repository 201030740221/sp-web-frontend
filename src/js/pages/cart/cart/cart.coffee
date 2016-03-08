# cart
define ['Checkbox', 'CheckAll', 'Amount_v2', 'PlaceSelector', './cart-layout.hbs', './cart-empty.hbs'], ( Checkbox, CheckAll, Amount_v2, PlaceSelector, cartTpl, cartEmptyTpl)->
    Fn = ->

    Fn.init = ()->
        #初始化
        cart = new Cart();

        #登录
        SP.helloed.add ->
            $ '#cart-login-entry'
            .toggle !SP.isLogined()

    class Cart
        constructor: (options)->
            @getCart()

        getCart: ()->
            webapi.cart.get()
            .then (res)=>
                if res.code is 0 && res.data.items
                    @renderCart res.data
                else
                    @renderEmptyCart()
            .fail (res)=>
                @renderEmptyCart()

        deleteSku: (id)->
            _this = this

            SP.confirm
                'content': '确定要删除该商品吗？'
                'confirm': ->
                    data =
                        'item_keys': id

                    webapi.cart.remove data
                    .then (res) ->
                        if res.code is 0
                            SP.trigger SP.events.cart_goods_quantity_update, res.data.total_quantity

                            if res.data.items and res.data.items.length
                                _this.renderCart res.data
                            else
                                _this.renderEmptyCart()
                        else
                            SP.notice.error '删除失败'
                    .fail (res) ->
                        SP.notice.error '删除失败'

        updateSku: (data)->
            webapi.cart.update data
            .then (res)=>
                if res.code is 0
                    SP.trigger SP.events.cart_goods_quantity_update, res.data.total_quantity
                    if res.data.items.length
                        @renderCart res.data
                    else
                        @renderEmptyCart()
                else
                    SP.notice.error '请求失败'
            .fail (res) ->
                SP.notice.error '请求失败'

        setCartTotalValue: (sku, price)->
            $ '#j-total-price'
            .html '¥ ' + price
            $ '#j-total-sku'
            .html sku

        checkedSku: ($cartBd)->
            _this = @
            @price = 0
            @quantity = 0

            $checked = $cartBd.find '.cart-table__col-01'
            .find '.ui-checkbox input:checked'
            if $checked.length
                $checked.each ()->
                    $item = $(@).closest '[data-item-id]'
                    _this.price = SP.Math.Add(_this.price, $item.data 'total-price').toFixed(2)
                    _this.quantity = SP.Math.Add(_this.quantity, $item.data 'quantity')
                    _this.setCartTotalValue _this.quantity, _this.price
                    $ '.j-cart-submit'
                        .removeClass '_disable'
            else
                _this.setCartTotalValue 0, '0.00'
                $ '.j-cart-submit'
                .addClass '_disable'

        #套餐单价
        getCollocationUnitPrice: (data) ->
            data.items.map (item) ->
                if item.is_multiple
                    item.unit_price = SP.Math.Div item.price, item.quantity, 2
            return data

        #商品是否下架
        handleCollocationState: (data) ->
            data.items.map (item) ->
                if item.is_multiple
                    item.items.map (item2) ->
                        unless item2.on_sale
                            item.on_sale = 0
                            return null
                        else
                            item.on_sale = 1
            return data

        renderCart: (data)->
            _this = @
            $cart = $ '.cart-table'
            data = @getCollocationUnitPrice data
            data = @handleCollocationState data
            tpl = cartTpl data
            $cart.empty().html tpl
            $cartBd = $cart.find '.cart-table__bd'
            #初始化 checkbox
            $cart[0]._checkAll = null
            $cart.checkAll
                checkboxClass: '.ui-checkbox'
                callback: (checked, $el)->
                    _this.checkedSku($cartBd)
            @checkedSku($cartBd)

            #初始化 Amount
            $ '.amount-box'
            .amount
                    callback: (value)->
                        $el = $ @
                        postData =
                            item_key: $el.closest('[data-item-id]').data 'item-id'
                            quantity: value
                        #修改数量
                        _this.updateSku postData
                        .then (res)->
                            if res.code is 1
                                SP.alert res.msg
                                return
                            SP.trigger SP.events.cart_goods_quantity_update, res.data.total_quantity

            #单个删除
            $cart
            .find '.j-sku-delete'
            .on 'click', ()->
                $el = $ @
                id = $el.closest('[data-item-id]').data 'item-id'
                _this.deleteSku [id]

            #删除选中
            $cart
            .find '.j-delete-checked-sku'
            .on 'click', ()->
                $item = $cartBd.find '[data-item-id]'
                ids =[]

                $item.each (i, item) ->
                    $el = $ @
                    $checked = $el.find '.ui-checkbox input:checked'

                    if $checked.length
                        ids.push $el.data 'item-id'

                _this.deleteSku ids

            # 地区选择
            placeSelect = new PlaceSelector
                target: "#stock-btn .btn"
                closeBtn: ".close"

            #提交
            $cart
            .find '.j-cart-submit'
            .on 'click', (e)->
                $el = $ @
                if $el.hasClass '_disable'
                    return null
                else if !SP.isLogined()
                    SP.login ->
                        _this.checkout($cartBd)
                else
                    _this.checkout($cartBd)

        checkout: ($cartBd)->
            $checked = $cartBd.find '.ui-checkbox input:checked'
            $form = $ '<form action="/checkout" method="POST"></form>'
            invalid = false

            $checked.each (i, item)->
                $parent = $(@).closest('[data-item-id]')
                id = $parent.data 'item-id'
                invalid = true unless $parent.data 'on-sale'
                $ipt = $ '<input type="hidden" name="item_keys[]">'
                $ipt.val id
                $form.append $ipt

            if invalid
                SP.notice.error('抱歉，无法选购已下架商品！')
                return null

            $form.appendTo 'body'
            $form.submit()

        renderEmptyCart: ()->
            tpl = cartEmptyTpl {}
            $ '.cart-table'
            .html tpl


    Fn.init()
