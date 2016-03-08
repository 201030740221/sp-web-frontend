
# 商品详情页面逻辑
Tab = require 'Tab'
Amount = require 'Amount'
GoodTypeSelect = require 'goodTypeSelect'
PlaceSelector = require 'PlaceSelector'
goodsApi = require 'goodsApi'
Swipe = require 'Swipe'
SliderList = require 'modules/sliderList/sliderList'
goodSlider = require 'goodSlider'
fixedNavScroll = require './detail-nav-fixed-scroll'
Comment = require './comment'
Collocation = require '../collocation/index'
require('modules/subject/entry')
require('../../article/article/article.coffee') # 引用了售后说明的功能

$document = $(document)

page = ->

# 初始化页面
page.init = (page_type)->
    page.page_type = page_type
    # SKU选择
    try
      GoodTypeSelect()
    catch error
      console.log error

    page.initSliderList()
    sliderResizeTimer = null
    $(window).on 'resize.initSliderList', ->
        clearTimeout sliderResizeTimer if sliderResizeTimer isnt null
        sliderResizeTimer = setTimeout page.initSliderList, 480

    page.initPlaceSelect()
    page.initBuy()
    page.initLike()
    page.initExtendInfo()
    page.getCollocation()

# 图片切换
# goodSlider.init();
# 图片切换 V2
page.initSliderList = ->
    $slierList = $ '#j-slider-list'
    goodsPhotos = pageData.goodsPhotos
    imgParam = '?imageView2/1/h/80/w/80'
    speed = 100
    if $slierList.length
        $win = $ window
        winWidth = $win.width()
        $wrapper = $ '.goods-photos'

        if winWidth > 1200
            layout = 'vertical'
            $wrapper.removeClass '_small'
        else
            $wrapper.addClass '_small'
            layout = 'horizontal'

        ReactDom.render(
            React.createElement(SliderList, {
                layout: layout
                imgs: goodsPhotos
                imgParam: imgParam
                speed: speed
                callback: _sliderListCallback
            }),
            $slierList[0]
        )

_sliderListCallback = (index, imgs)->
    $img = $ '#j-goods-photos__preview'
    $img[0].src = imgs[index]+'?imageView2/1/w/800'
    # console.log index, imgs[index]


# 查询物流费
_getDelivery = (id, callback)->
    SP.get SP.config.host + '/api/price/getDelivery', {
        goods_sku_id: pageData.skuid,
        region_id: id
    }, (dilivery)->
        if callback
            callback(dilivery)

# 获取物流费
page.getDelivery = ->
    # 默认物流费
    _regionId = parseInt $('._place_area').data('id') || parseInt $('._place_city').data('id')

    # 处理cookie
    if parseInt(SP.storage.get('region_district_id' ))!=-1
        _regionCookieId = parseInt SP.storage.get('region_district_id' )
    else
        _regionCookieId = parseInt SP.storage.get('region_city_id')

    if _regionCookieId
        _regionId = _regionCookieId;

    if _regionId and page.page_type isnt 'flash-sale-detail'
        _getDelivery _regionId,(dilivery)->
            if dilivery and dilivery.code ==0
                dilivery = dilivery.data
                if(dilivery == -1)
                    SP.log('此地区暂时不支持配送.')
                else
                    $('#j-delivery').text(dilivery+'.00')
            else
                SP.log('没有获取到配送信息.')

# 地区选择
page.initPlaceSelect = ->
    $stockBtn = $ '#stock-btn'
    $stockBtn.show()
    placeSelect = new PlaceSelector
        target: '#stock-btn .btn'
        closeBtn: '.close'
        callback: (res)->
            regionId = if parseInt(res.district.id)!=-1 then res.district.id else if parseInt(res.city.id) !=-1 then res.city.id
            if regionId
                #查询物流费
                _getDelivery regionId, (dilivery)->
                    if dilivery and dilivery.code ==0
                        dilivery = dilivery.data
                        if(dilivery == -1)
                            SP.alert '很抱歉！您所选的区域暂不支持配送。'
                        else
                            $('#j-delivery').text(dilivery+'.00')
                    else
                        SP.log('没有获取到配送信息.')

                # 快速购买配置
                $('#j-buy-now-form').find('input[name="region"]').val regionId
            else
                SP.log '获取地区信息失败'

    # 模板图片切换
    # $tplSwipe = $('#j-tpl-swipe')
    # $tplSwipePrev = $tplSwipe.find ".swipe-actions__prev"
    # $tplSwipeNext = $tplSwipe.find ".swipe-actions__next"
    # if $tplSwipe.find('.swipe-item').length > 1
    #     tplSwipe = new Swipe $tplSwipe[0],
    #         startSlide: 0
    #         speed: 400
    #         auto: 0
    #         continuous: true
    #         disableScroll: false
    #         stopPropagation: false
    #         callback: (index, elem)->
    #
    #     $tplSwipePrev.on 'click', ->
    #         tplSwipe.prev();
    #         return false;
    #
    #     $tplSwipeNext.on 'click', ->
    #         tplSwipe.next();
    #         return false;
    # else
    #     $tplSwipePrev.hide()
    #     $tplSwipeNext.hide()

page.initBuy = ->
    # 数量选择
    amount = new Amount
        target: '.amount-box'
        callback: (res)->
            # 快速购买配置
            $('#j-buy-now-form').find("input[name='quantity']").val res

    $document.on 'click.buy', '.j-add-to-cart', (e)-> # 加入购物车
        e.preventDefault()
        if $(this).hasClass('_disable')
            return;

        count = $('#count').val();
        data =
            is_multiple: 0
            item: pageData.skuid
            quantity: count
        webapi.cart.add(data)
        .then (res) ->
            if res && res.code is 0
                SP.notice.success '商品已经成功加入购物车'
                SP.trigger SP.events.cart_goods_quantity_update, res.data.total_quantity
            else
                SP.notice.error '添加失败'
    .on 'click.buynow', '#j-buy-now', ()-> # 立即购买
        try
            __ozclk()
        catch e
            # ...

        $form = $('#j-buy-now-form')
        if SP.isLogined()
            $amountInput = $form.find 'input[name="quantity"]'
            $amountCount = $ '#count'
            count = $amountCount.val()

            if $amountInput.val() isnt count
                $amountInput.val(count)

            $form.submit()
        else
            SP.login ->
                $form.submit()

        return false

# 收藏
page.initLike = ->
    $('#j-add-to-likelist').on 'click',()->
        try
            __ozclk()
        catch e
            # ...

        goodsApi.like pageData.goodid, (res)->
            if res
                $('#j-add-to-likelist').hide()
                $('#j-remove-to-likelist').show()
        return false

    $('#j-remove-to-likelist').on 'click',()->
        goodsApi.dislike pageData.goodid, (res)->
            if res
                $('#j-add-to-likelist').show()
                $('#j-remove-to-likelist').hide()
        return false

# 售前售后详情
_getSaleArticle = (loaded)->
    $afterSalesInfo = $ '#after-sales-info'
    loaded = loaded or ()->

    if $afterSalesInfo.data('content-loaded')
        loaded($afterSalesInfo)
        return

    $afterSalesInfo.html '<p class="u-mt_20 u-mb_20">载入中...</p>'
    $.ajax
        url: SP.config.host + '/api/getGoodsNotice',
        method: 'GET',
        success: (res)->
            if res and res.code == 0
                $afterSalesInfo.html res.data.content
                $afterSalesInfo.data('content-loaded', true)
                loaded($afterSalesInfo)

# 商品详情跳转
_jumpSaleBlack = (tab, hash)->
    _getSaleArticle ->
        $('.tab-nav-item').eq tab
            .addClass 'active'
            .siblings '.tab-nav-item'
            .removeClass 'active'

        $('.tab-content-item')
            .eq(tab)
            .show()
            .siblings()
            .hide()

        # location.hash = hash;
        $target = $('#' + hash)
        if (!$target.length)
            return

        offset = $target.offset()
        top = offset.top - 80
        $('html, body').animate
            'scrollTop': top
        , 300

page.initExtendInfo = ->
    fixedNavScroll()
    comment = null
    tab = new Tab
        target: '.goods-detail-extend'
        callback: (index) ->
            if index is 3
                _getSaleArticle()

            if index is 1
                if not comment
                    comment = new Comment()
                else
                    comment.commentRender()

            tabTop = $('.goods-detail-extend').offset().top
            scrollTop = $document.scrollTop()
            if scrollTop > tabTop
                $document.scrollTop tabTop

    $document
    .on 'click.jump', '#j-detail-keep', ->
        _jumpSaleBlack(3,'upkeep')
    .on 'click.jump', '#j-detail-install', ->
        _jumpSaleBlack(3,'installation')
    .on 'click.jump', '#j-detail-delivery', ->
        _jumpSaleBlack(3,'delivery')
    .on 'click.jump', '#j-detail-buy-flow', ->
        _jumpSaleBlack(3,'shoping-flow')
    .on 'click.jump', '#j-detail-falsh-sale-intro', ->
        _jumpSaleBlack(3, 'detail-falsh-sale-intro')

# 商品搭配
page.getCollocation = ->
    webapi.goods.getCollocation({goods_id: pageData.goodid})
    .then (res)->
        if res.code is 0
            $goodsDetailBox = $ '.goods-detail-box'
            $goodsCollocation = $ '<div id="j-goods-collocation"></div>'
            $goodsDetailBox.after $goodsCollocation
            ReactDom.render(React.createElement(Collocation, {data: res.data, skuid: pageData.skuid}), $goodsCollocation[0])

module.exports = page
