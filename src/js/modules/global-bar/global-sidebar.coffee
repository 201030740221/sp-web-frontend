# @tofishes
# 全局侧边栏
cartAction = require './sidebar-cart'

$sidebar = $ '#global-sidebar'
$content = $ '#global-bar-content'

speed = 200 # /* 200ms */
open = 'open'

# 侧边栏对象，提供方法
sidebar =
    'open': ->
        $content.show().animate
            'width': 300
            , speed
        $sidebar.addClass open
    'close': ->
        $content.animate
            'width': 0
            , speed, ()->
                $content.hide()
                $sidebar.removeClass open
    'isOpen': ->
        return $sidebar.hasClass open
    'refresh': ->
        if !sidebar.isOpen()
            return false

        sidebar.do sidebar.activeAction
        return true
    'do': (action)->
        action.call sidebar, $content
        sidebar.activeAction = action

SP.sidebar = sidebar;

# 侧边栏小按钮的动作定义
window.getMeChatPartnerUserID = ->
    return userId: SP.member.user_key
actions =
    'gotop': ->
        $('html, body').animate
            'scrollTop': 0
            , speed
    'cart': ->
        isOpen = sidebar.isOpen()
        if isOpen then sidebar.close()
        else
            sidebar.open()
            sidebar.do cartAction
    'consult': (e)->
        e && e.preventDefault()
        # 判断第三方存在
        if typeof mechatClick != 'undefined'
            mechatClick()
            return

# 事件定义
$sidebar.on 'click', '.action', (event)->
    $this = $ @
    action = $this.data 'action'
    actions[action].call $this, event
.on 'click', '.login-trigger', ->
    SP.login()
.on 'click', (e)->
    e.stopPropagation() # 阻止冒泡，让点击其他区域时，侧栏隐藏

# 吉祥物动画
$toolbar = $sidebar.children '.toolbar'
$cs = $toolbar.children().eq(0)
status_class = 'enter init leave'

$cs.on 'mouseenter', ->
    $toolbar.removeClass(status_class).addClass 'enter'
.on 'mouseleave', ->
    $toolbar.removeClass(status_class).addClass 'leave'

$toolbar.on 'mouseenter', '> *', ->
    $(this).addClass 'hover'
.on 'mouseleave', '> *', ->
    $(this).removeClass 'hover'

# 初始化
$toolbar.addClass 'init'

$gotop = $('#global-sidebar .goto-top')
gotopTimeId = null
speed = 100
$win = $(window)
$body = $('body')
$win.on 'scroll', ->
    clearTimeout(gotopTimeId)

    gotopTimeId = setTimeout ()->
        win_height = $win.height()
        scroll_top = $win.scrollTop()

        if scroll_top > win_height
            $gotop.fadeIn(speed)
        else
            $gotop.fadeOut(speed)
    , 50
$win.trigger 'scroll'

# 有侧栏的页面，给body增加一个class
if $sidebar.length then $body.addClass 'global-sidebar-body'

$(document).on 'click', '.online-service-trigger', actions.consult
.on 'click', ->
    sidebar.close()
.on 'mouseenter', '.tiny-tip', ->
    $this = $ @
    title = $this.attr 'title'
    $tip = $(this).data 'tiny-tip'

    if !title && !$tip
        return

    if !$tip
        $this.removeAttr 'title'
        $tip = $ '<span class="tiny-tip-box">' + title + '</span>'

        $this.data 'tiny-tip', $tip
        $body.append $tip

    dir = $this.data 'dir'
    dir = dir || 'left'

    pos = this.getBoundingClientRect() # getClientRects()
    height = pos.height || (pos.bottom - pos.top)
    tip_width = $tip.outerWidth()
    tip_height = $tip.height()

    styles =
        left:
            left: pos.left - tip_width,
            top: pos.top + height / 2 - tip_height / 2

    $tip.show().css styles[dir]

.on 'mouseleave', '.tiny-tip', ->
    $tip = $(this).data 'tiny-tip'
    $tip && $tip.hide()
