###
@date 2016-02-01
@author axu
###

# Swipe = require('Swipe')
imageScrollFixed = require 'modules/plugins/jquery.imagescrollfixed'
# slider = require 'modules/plugins/jquery.slider'
Swipe2 = require 'modules/swipejs/swipe2'

$(window).load ->
  swipe1 = new Swipe2(document.getElementById('block-2-swipe'), {
    speed: 400,
    auto: false,
    continuous: true,
    disableScroll: false,
    stopPropagation: false
  })

  $('.block-2-box-3').on 'click', '.prev', ->
    swipe1.prev()
  .on 'click', '.next', ->
    swipe1.next()

  # $('#block-2-swipe').slider
  #     circular: 0,
  #     btnPrev: '.block-2-box-3 .prev',
  #     btnNext: '.block-2-box-3 .next',
  #     visible: 1

  window.swipe2 = new Swipe2(document.getElementById('review-swipe'), {
    cols: 3,
    speed: 400,
    stopPropagation: false
  })

  $('.review').on 'click', '.prev', ->
    swipe2.prev()
  .on 'click', '.next', ->
    swipe2.next()

  # $(window).on 'resize', ->
  #   $('#review-swipe').slider
  #       circular: 0,
  #       btnPrev: '.review .prev',
  #       btnNext: '.review .next',
  #       visible: 3
  # .trigger 'resize'

  $('.fixed-image').imageScrollFixed
    scrollTopBegin: $('.header').height()
    # viewHeight: 200
