tpl_cart = require './tpl-sidebar-cart.hbs'
getCartEmpty = require './cart-empty'
Amount_v2 = require 'Amount_v2'
CheckAll = require 'CheckAll'
Checkbox = require 'Checkbox'

renderCart = (data)->
    if  data.items and data.items.length
        data = handleCollocationState data
        tpl = tpl_cart data
        this.html tpl

        init.call this

        if !SP.isLogined()
            $('#sidebar-tip-cart').show()
    else
        renderEmptyCart.call this

handleCollocationState = (data) ->
    data.items.map (item) ->
        if item.is_multiple
            item.items.map (item2) ->
                unless item2.on_sale
                    item.on_sale = 0
                    return null
                else
                    item.on_sale = 1
    return data

renderEmptyCart = ->
    this.html(getCartEmpty())

loading = ->
    this.html '<p class="ui-loading"></p>'

loaded = ->
    this.find 'p.ui-loading'
    .remove()

setCartTotalValue = (quantity, price)->
    $ '#sidebar-goods-total-price'
    .html '¥ ' + price
    $ '#sidebar-goods-total-pieces'
    .html quantity

checkedSku = ($cartBd)->
    price = 0
    quantity = 0
    $checked = $cartBd.find '.ui-checkbox input:checked'
    if $checked.length
        $checked.each (i, item)->
            $el = $ @
            $parent = $el.closest '.item'
            pieces = $parent.data 'total-quantity' || 0
            _price = $parent.data 'price'

            price = SP.Math.Add(price, _price, 2)
            quantity = SP.Math.Add(quantity, pieces)

            setCartTotalValue quantity, price
        $ '#sidebar-cart-checkout'
        .removeClass 'disabled'
    else
        setCartTotalValue 0, 0
        $ '#sidebar-cart-checkout'
        .addClass 'disabled'

init = ->
    $container = this
    $cart = $ '#global-sidebar-cart'
    $cartBd = $cart.find '.cart-goods-items'
    $cart.checkAll
        checkboxClass: '.ui-checkbox'
        callback: (checked, $el)->
            checkedSku($cartBd)
    checkedSku($cartBd)

    $cartBd.find '.amount'
    .on 'click', '.amount__up, .amount__down', (e)->
        $target = $ @
        $item = $target.closest '.item'
        quantity = $item.data 'quantity'

        if $target.hasClass 'amount__up'
            if quantity > 98
                return null
            else
                quantity += 1
        else if $target.hasClass 'amount__down'
            if quantity is 1
                return null
            else
                quantity -= 1

        postData =
            item_key: $item.data 'item-id'
            quantity: quantity

        webapi.cart.update postData
        .then (res)->
            renderCart.call $container, res.data
            SP.trigger SP.events.cart_goods_quantity_update, res.data.total_quantity

    $cart.on 'click', '#sidebar-cart-checkout', ()->
        if $(this).hasClass('disabled')
            return

        if !SP.isLogined()
            SP.login()
            return

        $checked = $cartBd.find '.ui-checkbox input:checked'
        invalid = false

        $form = $ '<form action="/checkout" target="_blank" method="POST"></form>'

        $checked.each (i, item)->
            $item = $(item).closest('.item')
            invalid = true unless $item.data 'on-sale'
            $ipt = $ '<input type="hidden" name="item_keys[]">'
            $ipt.val $item.data 'item-id'
            $form.append $ipt

        if invalid
            SP.notice.error '抱歉，无法选购已下架商品！'
            return null

        $form.appendTo 'body'
        $form.submit()

    $cart.on 'click', '.delete-item', ()->
        $item = $(this).closest '.item'
        id = $item.data 'item-id'

        postData =
            "item_keys": [id]
        webapi.cart.remove postData
        .then (res)=>
            if res.code is 0
                $item.remove()
                SP.trigger SP.events.cart_goods_quantity_update, res.data.total_quantity

                if !res.data.items or !res.data.items.length
                    renderEmptyCart.call $container
                else
                    checkedSku($cartBd)
            else
                SP.notice.error '删除失败'
        .fail (res) ->
            SP.notice.error '删除失败'

render = ($container)->
    loading.call $container
    webapi.cart.get()
    .then (res)=>
        loaded.call $container
        if res.code is 0
            renderCart.call $container, res.data
        else
            renderEmptyCart.call $container
    .fail (res)=>
        renderEmptyCart.call $container

module.exports = render
