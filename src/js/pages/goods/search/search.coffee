# 商品详情页面逻辑
define ['goodListHover', 'goodsApi'], (goodListHover,goodsApi)->
    goodListHover.init()

    $(document).on "click", ".btn-addcart", (e)->
        skuid = $(this).data("skuid")
        data =
            is_multiple: 0
            item: skuid
            quantity: 1

        webapi.cart.add(data)
        .then (res) ->
            if res && res.code is 0
                SP.notice.success '商品已经成功加入购物车'
                SP.trigger SP.events.cart_goods_quantity_update, res.data.total_quantity
            else
                SP.notice.error "添加失败"

        e.preventDefault()

    $(document).on 'click', ".btn-addlike", (e)->
        goodid = $(this).data("goodid");
        goodsApi.like(goodid);

        e.preventDefault()
