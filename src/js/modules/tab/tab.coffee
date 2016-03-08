Tab = (options) ->
    self = this
    $target = $(options.target)
    $tab = $target.find(".tab")
    $content = $target.find(".tab-content")
    navItemCls = ".tab-nav-item"
    $navItem = $tab.find(navItemCls) ;
    contentItemCls = ".tab-content-item"
    $contentItem = $content.find(contentItemCls)
    activeCls = "active"

    fn = (e) ->
        e.preventDefault()
        index = $(this).index()
        $(this).addClass activeCls
        .siblings navItemCls
        .removeClass activeCls

        $contentItem.eq(index)
        .show()
        .siblings contentItemCls
        .hide()

        if(options.callback)
            options.callback(index)

        return false

    $navItem.on "click", fn
    self

module.exports = Tab
