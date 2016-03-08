require 'plugins'
require 'modules/subject/entry'

$doc = $ document
$themeFilter = $ 'div.theme-filter'
$themeWrap = $ 'div.theme-collocation'

active = 'active'
disabled = 'disabled'
speed = 200
pageSize = 12
perShowSize = 4
filterData = [] # @unused
$conditions = $ '#conditions'

# @unuesd 改由PHP输出
renderLabel = ->
    labels = filterData.map (param)->
        if param.checked
            return "<a data-value=\"#{param.value}\">#{param.name}<i class=\"iconfont\"></i></a>"
        else
            return ''
    $conditions.html labels.join ''

# 多选功能
$themeFilter.CheckBox
    item: '.ui-checkbox'
    'dataAttr': 'id'
    oneach: (index, $item)->
        name = $item.text()
        value = $item.data 'value'

        $item.data 'index', index
        filterData[index] = 
            'name': name
            'value': value
            'checked': false
    onchange: (isChecked)->
        index = this.data 'index'
        filterData[index].checked = isChecked

# 筛选项的交互
$themeFilter.on 'click', '.drop-name', ->
    $this = $ @
    $item = $this.closest 'li'
    $dropCon = $item.find '.drop-con'
    isActive = $item.hasClass active
    isRuning = $dropCon.is ':animated'

    if isRuning
        return

    if isActive
        $item.removeClass active
        $dropCon.slideUp speed
        return

    $item.addClass active
    $dropCon.slideDown speed

    $item.siblings().removeClass active
    .find '.drop-con'
    .slideUp speed

.on 'click', '.actions a', ->
    $action = $ @
    $item = $action.closest 'li'
    $dropname = $item.find '.drop-name'
    actionName = $action.data 'action'

    $dropname.trigger 'click'
    actions = 
        'confirm': ->
            tag_ids = $themeFilter.CheckBoxVal null, (value)->
                return value != ''

            query = {}

            if tag_ids.length
                query.tag_ids = tag_ids

            params = $.param query
            href = location.pathname + '?' + params

            location.href = href

        'cancel': ->

    actions[actionName]()


# 主题搭配slider
# 绑定事件是为了处理初始为隐藏的元素
$('div.slider').on 'init-slider', ->
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
.filter ':visible'
.trigger 'init-slider'

# 分页页码
$pager = $ '#theme-pager'
$pageNext = $pager.find '.next'
$pagePrev = $pager.find '.prev'

# 加载更多
$btnMore = $ '#show-more-theme'
$complete = $ '#load-complete'

pageNow = $pager.data 'now'
pageMax = $pager.data 'max'
isFirstPage = pageNow == 1
isLastPage = pageNow == pageMax

if pageMax > 1 and !isFirstPage
    $pager.show()
if pageMax == 1
    $pager.remove()
if pageMax > 1
    $complete.remove()

$pagePrev.toggleClass disabled, isFirstPage
$pageNext.toggleClass disabled, isLastPage

$btnMore.on 'click', ->
    $themeSections = $ 'section.u-none:lt(' + perShowSize + ')'
    $themeSections.removeClass 'u-none'

    $themeSections.find 'div.slider'
    .trigger 'init-slider'

    $remainSections = $ 'section.u-none'

    if !$remainSections.length
        $btnMore.hide()
        $complete.show()
        $pager.show() # 只管show，因为上面会判断若是只有一页，将remove
        return

