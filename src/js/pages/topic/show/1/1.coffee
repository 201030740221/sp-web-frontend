###
@date 2016-01-07
@author remiel
快乐家专题 - 模板
###
videocss = require 'video.js/dist/video-js.css'
videojs = require 'video.js'
Swipe = require 'Swipe'

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

$videoWrap = $ 'div.topic-show-video'
$video = $ '#example_video_1'
player = videojs($video[0], {
        example_option: true
    },
    ->
        this.on 'play', ->
            $videoWrap.addClass 'playing'
        this.on 'ended', ->
            $videoWrap.removeClass 'playing'
)

$videoWrap.on 'click', (e)->
    $target = $ e.target
    if $target.is $videoWrap
        player.pause()
        $videoWrap.removeClass 'playing'
