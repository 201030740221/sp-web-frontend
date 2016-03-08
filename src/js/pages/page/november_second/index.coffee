ModalBox = require 'ModalBox'
tplNoticeGet = require '../november_index/tpl-notice-get.hbs'
VerticalSlider = require './vertical-slider.coffee'
countdown = require 'modules/countdown/countdown'
Navigator = require '../navigator/navigator.coffee'

# 优惠券
$action = $ '.action'
noticeBox = null
$action.on 'click', '.j-get', (e) ->
    e.preventDefault()
    $target = $ @
    unless SP.isLogined()
        SP.login()
        return null

    # $title = $target.closest('.item').find('.title').clone()
    # unless noticeBox
    #     noticeBox = new ModalBox
    #         template: tplNoticeGet {}
    #         top: 300
    #         width: 400
    #         mask: true
    #         closeBtn: true
    # noticeBox.show()
    # noticeBox.modal.find('.value').html $title

    if DATE.lt '2015-11-13 16:00:00'
        webapi.coupon.take task_id: $target.closest('.item').data 'id'
        .then (res)->
            if res.code is 0
                $title = $target.closest('.item').find('.title').clone()
                unless noticeBox
                    noticeBox = new ModalBox
                        template: tplNoticeGet {}
                        top: 300
                        width: 400
                        mask: true
                        closeBtn: true
                noticeBox.show()
                noticeBox.modal.find('.value').html $title
            else
                SP.notice.error res.msg
    else
        alert "活动已结束"

# empty link
# $('.s-one .empty-link').on 'click', (e) ->
#     e.preventDefault()
#     SP.alert '该活动尚未开始！'

#slider
d = new Date()
month = d.getMonth() + 1
date = d.getDate()

if date < 6
    date = 6
else if date > 13
    date = 13

dateStr = month + '-' + date

$('.s-slider .trigger a')
.each ->
    $item = $ @
    if $item.data('target') is dateStr
        $item.addClass 'active'

new VerticalSlider '.s-slider'

#倒计时
$('.s-slider .item .countdown span')
.countdown
    'now': 'now'
    'end': 'start'
    'onend': ($target)->
        $target
        .closest 'a'
        .text '马上进入抢购'
        .closest '.item'
        .removeClass 'item-ready'
        .addClass 'item-going'
        .find '.status'
        .text '正在秒杀中...'

# sidebar
new Navigator
    trigger: '#sidebar li, #sidebar .goto-top, .s-zero .links a'
    # scrollEffect: false
