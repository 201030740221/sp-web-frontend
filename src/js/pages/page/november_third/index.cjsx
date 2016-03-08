Lottery = require './lottery-section'
Navigator = require 'pages/page/navigator/navigator.coffee'
$doc = $ document

initLottery = ->
    ReactDom.render <Lottery />, $('.p4-one .wraper')[0]

buy = ->
    $doc.on 'click', '.p4-two .final-4', ->
        $target = $(@)
        $ipt = $target.closest('.final').find('input')
        data = {}

        $ipt.each ->
            $item = $(@)
            data[$item.attr('name')] = $item.val()

        webapi.cart.add(data)
        .then (res) ->
            if res && res.code is 0
                SP.notice.success '商品已经成功加入购物车'
                SP.trigger SP.events.cart_goods_quantity_update, res.data.total_quantity
            else
                SP.notice.error "添加失败"

initSidebar = ->
    new Navigator
        trigger: '#sidebar li, #sidebar .goto-top'


initLottery()
buy()
initSidebar()
