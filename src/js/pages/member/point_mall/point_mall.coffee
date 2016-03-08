require('modules/plugins/jquery.radio')
require('modules/plugins/jquery.amount')
require('modules/plugins/jquery.form')

liteModalBox = require 'liteModalBox'
exchage_tip_tmpl = require './exchange-tip.hbs'

$point = $('#usable-point')
usablePoint = $point.data('point')

$('.amount-box').amount {
    'onchange': (value)->
        price = this.data 'price'
        total = SP.Math.Mul(price, value)
        console.log total, usablePoint, '----'
        if total > usablePoint
            SP.notice.error('超出了可用积分！')
            return false
}

$('.sku-select').radio()

$('#gift-list').on 'click', '.exchange', ->
    $this = $(this)
    $item = $this.closest 'li'
    param = $item.serializeMap()

    if !param.item
        SP.notice.error '请选择兑换礼品的型号'
        return;

    amount = $item.find('.amount-box').amountVal()
    price = $item.data 'price'
    gift_point = SP.Math.Mul(amount, price)

    if gift_point > usablePoint
        SP.notice.error('超出了可用积分！')
        return

    $ipt = $item.find 'input'
    $form = $ '<form action="/exchange" method="POST"></form>'
    $form.append $ipt
    $form.appendTo 'body'
    $form.submit()

    # webapi.cart.exchange(param).then (res)->
    #     if res.code != 0
    #         SP.notice.error '兑换失败，请稍后再试。'
    #         return
    #
    #     SP.trigger SP.events.cart_goods_quantity_update, res.data.total_quantity
    #     usablePoint -= gift_point
    #
    #     SP.notice.success '礼品已经成功加入购物车'
