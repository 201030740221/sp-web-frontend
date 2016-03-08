$win = $(window)

# menu fixed
$wrap = $('main.wrap')
$menu = $('.menu')
$footer = $('.footer')
menuTop = $menu.offset().top
menuLeft = $menu.offset().left
menuHeight = $menu.height()
menuBottom = menuTop + menuHeight
$win.on 'scroll.menu_fixed', ->
    scrollTop = $win.scrollTop()
    winHeight = $win.height()
    footerTop = $footer.offset().top
    gap = Math.max(scrollTop + winHeight - footerTop, 0)

    if menuHeight > winHeight
        if scrollTop > (menuBottom - winHeight)
            $menu.css
                position: 'fixed'
                left: menuLeft
                bottom: gap
        else
            $menu.css
                position: 'static'
    else if scrollTop > menuTop
        if menuHeight > (footerTop - scrollTop)
            $menu.css
                position: 'fixed'
                top: 'auto'
                bottom: gap
                left: menuLeft
        else
            $menu.css
                position: 'fixed'
                top: 0
                left: menuLeft
    else
        $menu.css
            position: 'static'

    return null


# scroll loading
$loading = $('<div class="ui-loading u-mb_20"></div>')
$finished = $('<div class="finished">推荐文章已浏览完，可通过目录查看更多分类文章</div>')
$content = $('.content')
$section = [
    $('.section-1').eq(0),
    $('.section-2').eq(0),
    $('.section-3').eq(0),
    $('.section-4').eq(0)
]
page = 1
isLoading = false
finished = false

handleArticle = (data, cb = ->)->
    i = 0
    data.forEach (item) ->
        $node = $section[i].clone()

        imgSrc = ''
        if item.cover and item.cover.media and item.cover.media.full_path
            imgSrc = item.cover.media.full_path
        $node.find('img').attr 'src', imgSrc

        $titleSpan = $node.find('h1 span')
        $span1 = $titleSpan.eq(0).html item.titleArray[0]
        if item.titleArray[1]
            $titleSpan.eq(1).html item.titleArray[1]
        else
            $span1.siblings().remove()

        $node.find('.text').html item.article.content
        $node.find('a').attr 'href', item.href
        $node.appendTo($content).hide().slideDown(cb)

        i = if i < 3 then i + 1 else 0

        return null

loadingFailed = ->
    $loading
    .removeClass('ui-loading')
    .addClass('u-text-center')
    .html '加载失败...'

$win.on 'scroll.auto_loading', ->
    return null if isLoading or finished
    scrollTop = $win.scrollTop()
    winHeight = $win.height()
    contentBottom = $content.offset().top + $content.height()
    bottom = winHeight - (contentBottom - scrollTop)
    gap = 50
    if bottom > gap
        isLoading = true
        page += 1
        $loading.appendTo $content
        webapi.lesson.getList({
            node_id: window.node_id
            page: page
            })
        .then (res) ->
            if res.code is 0
                finished = true if res.data.next_page_url is null
                t1 = setTimeout ->
                    $loading.remove()
                    handleArticle res.data.data, ->
                        isLoading = false
                        $finished.appendTo $content if finished
                        clearTimeout t1
                , 1000
            else
                loadingFailed()
        .fail ->
            loadingFailed()
