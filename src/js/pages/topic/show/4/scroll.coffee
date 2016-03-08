$wrap = $ '.j-show-dialog-wrap'
$cont = $wrap.find 'ul'
$wrapScrollBar = $wrap.find '.show-dialog-scroll-wrap'
$scrollBar = $wrapScrollBar.find 'i'

wh = $wrap.height()
ch = $cont.height()

# //设置滚动按钮宽度
$scrollBar.height wh * wh / ch

sh = $scrollBar.height()
disY = 0;

fnChangePos = (data) ->
    ret = yes
    if data < 0
        data = 0
        ret = no
    else if data > (wh - sh)
        data = wh - sh
        ret = no
    $scrollBar.css('top', data)
    $cont.css('top', -(ch - wh) * data / (wh - sh))
    ret

# //滚动条拖动事件
$scrollBar.mousedown (event) ->
    $this = $ @
    disY = event.pageY - $this.position().top
    if @setCapture
        $(@).mousemove (event) ->
            fnChangePos(event.pageY - disY);
        @setCapture(); #//设置捕获范围
        $scrollBar.mouseup () ->
            $(@).unbind('mousemove mouseup')
            @releaseCapture() #//取消捕获范围
    else
        $(document).mousemove (event) ->
            fnChangePos(event.pageY - disY);
        $(document).mouseup () ->
            $(document).unbind('mousemove mouseup')
    no


# //鼠标在滚动条上点击或滚动滚轮单次移动的距离
sMoveDis = 20;
# //滚动条单击事件注册
$wrapScrollBar.click (event) ->
    relDisY = event.pageY - $(this).offset().top
    if relDisY > ($scrollBar.position().top + sh)
        fnChangePos($scrollBar.position().top + sMoveDis)
    else if relDisY < $scrollBar.position().top
        fnChangePos(($scrollBar.position().top - sMoveDis))
# //阻止事件冒泡
$scrollBar.click (event) ->
    event.stopPropagation()

# //鼠标滚轮事件处理函数
fnMouseWheel = (e) ->
    if typeof e is 'object' and e.stopPropagation
        e.stopPropagation()
    evt = e or window.event
    wheelDelta = evt.wheelDelta or evt.detail # //鼠标滚动值，可由此判断鼠标滚动方向
    ret = fnChangePos($scrollBar.position().top - sMoveDis * wheelDelta / 3 / 10)

    if typeof e is 'object' and e.stopPropagation and ret
        e.stopPropagation()
        no

# //滚动条鼠标滚轮事件注册
if $wrapScrollBar[0].addEventListener # //for firefox
    $wrapScrollBar[0].addEventListener("DOMMouseScroll", fnMouseWheel)

if $wrap.find('.show-dialog')[0].addEventListener # //for firefox
    $wrap.find('.show-dialog')[0].addEventListener("DOMMouseScroll", fnMouseWheel)

$wrapScrollBar[0].onmousewheel = fnMouseWheel # // for other browser
$wrap.find('.show-dialog')[0].onmousewheel = fnMouseWheel # // for other browser
