###
@date 2016-01-07
@author
快乐家专题 - 模板
###

Swipe = require 'Swipe'


$win = $ window
$bd = $ 'body'
$block2 = $ '.block-2'
$block3 = $ '.j-scroll.block-3'
$block4 = $ '.j-scroll.block-4'
$block2Swiper = $block2.find '.swiper'

block2SwiperHeight = () ->
    $block2Swiper.height 716/1464*$block2Swiper.width()
block2SwiperHeight()

block3Active = (e) ->
    st = $win.scrollTop()
    block3Top = $block3.offset().top
    if st > block3Top - $block3.height()/2
        $block3.addClass 'active'
        $win.off 'scroll', block3Active


block4Active = (e) ->
    st = $win.scrollTop()
    block4Top = $block4.offset().top
    if st > block4Top - $block4.height()/2
        $block4.find('.show-dialog').addClass 'active'
        $win.off 'scroll', block4Active

$win.on 'scroll', block3Active
block3Active()
$win.on 'scroll', block4Active
block4Active()


# swiper
$swiper = $ '.swiper'
$swiper.map (item, i) ->
    swiper = new Swipe @,
        startSlide: 0
        speed: 400
        auto: 5000
        continuous: true
        disableScroll: false
        stopPropagation: false
        callback: (index, elem) ->

    $prev = $(@).find('.prev')
    if not $prev.length
        $prev = $(@).siblings('.prev')
    $prev.on 'click', ->
        swiper.prev()
        return no

    $next = $(@).find('.next')
    if not $next.length
        $next = $(@).siblings('.next')
    $next.on 'click', ->
        swiper.next()
        return no

# 初始化swiper之后 height为auto
$block2Swiper.height 'auto'
