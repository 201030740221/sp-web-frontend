module.exports = ->
    SP = this

    SP.member =
        'id': null
        'name': null
        'token': null
        'location': null
        'email': null


    SP.setMember = (data)->
        # $.extend SP.member, data
        SP.member = data.member or {}
        SP.member.location = data.location
        SP.member.total_quantity = data.total_quantity
        SP.trigger SP.events.member_update, SP.member
        # 每次获取用户信息，更新一下购物车数量
        SP.trigger SP.events.cart_goods_quantity_update, SP.member.total_quantity

    # 购物车商品数量的更新
    SP.on SP.events.cart_goods_quantity_update, (e, quantity)->
        $cartBtn = $ '#j-cart-btn'
        $cartBtn.cart 'setShouldUpdate' if $cartBtn.length

        $ '.cart-goods-quantity sup'
        .html quantity
        .toggle(quantity > 0)

    SP.helloed = $.Callbacks()

    webapi.member.hello().then (resp)->
        if resp.code == 0
            SP.setMember resp.data
            window.csrf_token = resp.data.token
            SP.helloed.fire()

    # 判断登录
    SP.isLogined = ->
        return !!SP.member.name
