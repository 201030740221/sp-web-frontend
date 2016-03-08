# 首页
Swipe = require 'Swipe'

require 'jquery-lazyload'
require 'modules/plugins/jquery.slider'
require 'modules/plugins/jquery.tab'
require 'modules/subject/entry'

$doc = $(document)
$win = $ window

triggerLazy = ->
    setTimeout ->
        $win.trigger 'scroll'
    , 100

$("img.lazy").lazyload
    effect: "fadeIn",
    threshold : 1000
triggerLazy()

# 首页轮播图
$banner = $ '#home-banner'
$banner.Swipe()

# 橱窗位sku切换产品图
$showcase = $('#home-showcase').on 'click mouseenter', '.sku-list a', (e)->
    $this = $ this
    if e.type is 'mouseenter'
        # timeid = setTimeout ->
        $this.trigger 'click'
        # ,  300
        # $this.data 'timeid', timeid
        return false

    if $this.hasClass 'active'
        return

    $item = $this.closest 'li'
    $scenes = $item.find '.scene-cover'
    $thumb = $item.find 'a.thumb'
    $link = $item.find 'a.thumb, h3 a'

    thumb = $this.data 'thumb'
    sceneSrc = $this.data 'scene'
    sku_sn = $this.data 'sku'

    sceneId = "showcase-scene-#{sku_sn}"
    href = "/item/#{sku_sn}.html"

    $link.attr 'href', href

    if sceneSrc
        $sceneImg = $ '#'+sceneId

        # 场景图处理
        if !$sceneImg.length
            $sceneImg = $ '<img class="scene-cover" id="'+sceneId+'"/>'
            $sceneImg.attr 'src', sceneSrc
            $thumb.append $sceneImg

        $scenes.hide()
        $sceneImg.show()

    $this.addClass('active').siblings().removeClass('active')

# .on 'mouseleave', '.sku-list a', ->
#     timeid = $(this).data 'timeid'
#     clearTimeout timeid
.on 'mouseleave', 'li', ->
    $scenes = $(this).find '.scene-cover'

    $(this).find('.sku-list a').removeClass 'active'
    $scenes.hide()

# 预加载
$skuScene = $showcase.find '.sku-list a'
.on 'preload', ->
    scene_src = $(this).data 'scene'
    if scene_src
        image = new Image()
        image.onload = ->
            # console.log "#{scene_src} has loaded..."
        image.src = scene_src

setTimeout ->
    $skuScene.trigger 'preload'
,  600

# 主题搭配slider
$('#life-theme .slider').each ->
    $this = $ this
    $slider = $this.children '.inner-wrap'
    $prev = $this.children '.prev'
    $next = $this.children '.next'
    itemLenght = $slider.find('li').lenght

    if itemLenght < 3
        $prev.hide()
        $next.hide()

    $slider.slider
        circular: 0,
        visible: 2,
        'btnPrev': $prev,
        'btnNext': $next

# 分类切换
$('#category-showcase').tab
    'title': '.categories li'
    'content': '.content'
    'onswitch': ->
        triggerLazy()

# 平面
# $('.planar').on 'mouseenter', 'a', ->
#     $others = $(this).siblings()
#     $others.addClass 'blur'
#     $(this).removeClass 'blur'
# .on 'mouseleave', ->
#     $(this).children().addClass 'blur'
# 哀悼变灰
# $ 'html'
# .addClass 'page-gray page-gray-standard'
