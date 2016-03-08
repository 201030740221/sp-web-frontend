# 商品详情页面逻辑
# @tofishes modify

goodsApi = require('goodsApi')
# goodListHover = require('goodListHover')
PlaceSelector = require('PlaceSelector')
require('modules/subject/entry')

$doc = $(document)

# 地区选择
new PlaceSelector
    target: "#stock-btn"
    closeBtn: ".close"
    callback: (data) ->
        console.log arguments

$doc.on "click", ".btn-shopping-cart", (e)->
    e.preventDefault()
    skuid = $(this).data 'skuid'
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

$doc.on 'click', ".btn-favorite", ()->
    $this = $ @
    goodid = $this.data "goodid"
    isFavorite = $this.hasClass 'favorited'

    if isFavorite
        goodsApi.dislike goodid, (ok)->
            if ok
                $this.removeClass 'favorited'
    else
        goodsApi.like goodid, (ok)->
            if ok
                $this.addClass 'favorited'

    return false

#跳转页面
$pageForm = $("#jump-page-form")
$pageForm.find('.paging-go').on "click", (e)->
    e.stopPropagation()
    e.preventDefault()
    jump_page = $pageForm.find("[name='page']").val()
    max_page = $pageForm.find("#max-page").val()
    if $.trim(jump_page) and parseInt($.trim(jump_page)) <= parseInt($.trim(max_page))
        $pageForm.submit()
