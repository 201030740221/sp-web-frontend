
ModalBox = require 'ModalBox'
tplNotice = require './tpl-notice.hbs'
tplNoticeGet = require './tpl-notice-get.hbs'
tplSetNotice = require './tpl-set-notice.hbs'
Navigator = require '../navigator/navigator.coffee'
Validator = require 'Validator'
validator = new Validator()
$document = $ document

# banner
d = new Date()
$link = $('.banner a')
if (d.getMonth() + 1 > 10) and (d.getDate() > 5) or (d.getFullYear() > 2015)
    $link.show()
else
    $link.hide()

# 优惠券
$action = $ '.action'
noticeBox = null
$action.on 'click', '.j-get', (e) ->
    e.preventDefault()
    $target = $ @
    unless SP.isLogined()
        SP.login()
        return null

    if DATE.lt '2015-11-13 16:00:00'
        webapi.coupon.take task_id: $target.closest('.action-item').data 'id'
        .then (res)->
            if res.code is 0
                $title = $target.closest('.action-item').find('.title').clone()
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

# 短信通知
$setNotice = $ '#set-notice'
webapi.tools.reminderStatus type: 3
.then (res)->
    if res.code is 0
        $setNotice.text '您已设置提醒'
        $setNotice.off 'click'

$setNotice.on 'click', (e) ->
    e.preventDefault()
    unless SP.isLogined()
        SP.login()
        return null
    noticeBox = new ModalBox
        template: tplSetNotice {}
        top: 300
        width: 400
        mask: true
        closeBtn: true
    noticeBox.show()
    $ipt = noticeBox.modal.find('input')
    $btn = noticeBox.modal.find('.submit')
    $ipt.val SP.member.mobile or ''
    $btn.on 'click', ->
        val = $ipt.val()
        if validator.verify('phone', val)
            webapi.tools.reminder
                types: [3,4,5]
                target: val
            .then (res)->
                if res.code is 0
                    noticeBox.close()
                    SP.notice.success '设置成功！'
                    $setNotice
                    .text '您已设置提醒'
                    .off 'click'
        else
            SP.notice.error '号码格式错误！'

# 活动未开始
$document.on 'click', '.three a', (e) ->
    e.preventDefault()
    SP.alert '活动还未开始，11月25日，抽奖、特惠返场等着你哟'
.on 'click', '.two a', (e) ->
    end = '2015-11-13 16:00:00'
    return null if DATE.lt end
    e.preventDefault()
    SP.alert '第二弹活动已结束，请期待终极返场活动！'

# sidebar
new Navigator
    trigger: '#sidebar li, #sidebar .goto-top, .zero .item img'
    gap: 100
