# 商品详情页面逻辑
define ['AutoComplete', 'NavDropDown',
        'TopbarDropDown', 'Cart','Placeholder','modules/components/memberbar', 'LoginModalBox', 'modules/global-bar/global-sidebar'], (AutoComplete, NavDropDown, TopbarDropDown, Cart,Placeholder,Memberbar,LoginModalBox, GlabalBar)->
    page = ->

    page.initMenu = ->
        return null if $('.page').hasClass('page-index')
        navIsHover = false
        menuIsHover = false
        $navMenu = $('.header-nav-menu')
        $menu = $('.header-menu')

        hideMenu = ->
            t1 = setTimeout ->
                if !navIsHover && !menuIsHover
                    $navMenu.removeClass 'active'
                    $menu
                    .stop()
                    .slideUp 250, ->
                        $menu.removeClass('open').hide()
                clearTimeout t1
            , 500

        showMenu = ->
            $navMenu.addClass 'active'
            $menu
            .addClass('open')
            .stop()
            .slideDown 250, ->
                legacyLayout()

        $navMenu.on "mouseenter", ->
            navIsHover = true
            showMenu()
        .on "mouseleave", ->
            navIsHover = false
            hideMenu()

        $menu.on "mouseenter", ->
            menuIsHover = true
        .on "mouseleave", ->
            menuIsHover = false
            hideMenu()

        # menu layout for legacy browser
        legacyLayout = ->
            testEl = document.createElement('div')
            if testEl.style.flexWrap is undefined
                $menuList = $menu.find('.header-menu-list')
                $items = $menuList.children()
                itemsWidth = 0
                $items.each ->
                    itemsWidth += $(this).width()
                gap = ($menuList.width() - itemsWidth) / ($items.length - 1)
                if gap > 0
                    $items.css('paddingRight', gap).last().css('paddingRight', 0)
                    $menuList.addClass('u-clearfix')
                    $menu.css('borderBottom', '1px solid #dcdcdc')

    # 初始化页面
    page.init = ->
        page.initMenu()

        # 页面底部和商品详情页在线客服
        $('.j-get-contact').on 'click', (e) ->
            e.preventDefault()
            if typeof mechatClick != 'undefined'
                mechatClick()
                return

        # placeholder fixed
        $('input, textarea').placeholder();

        # 顶部用户状态组件
        if($("#j-header-memberbar").length)
            ReactDom.render <Memberbar />, document.getElementById('j-header-memberbar')


        # 全局触发登录框
        loginBox = null
        loginedAction = null
        createLoginBox = () ->
            loginBox = new LoginModalBox
                top: 250
                mask: true
                closeBtn: true
                loginSuccessCallback: (data)->
                    loginBox.close()
                    if loginedAction
                        loginedAction(data)
                        return

                    if !SP.sidebar.refresh()
                        window.location.reload()
        SP.login = (logined)->
            loginedAction = logined;
            if(!loginBox)
                createLoginBox()

            else if(loginBox.id and not $(loginBox.id).length)
                createLoginBox()

            loginBox.show()

        $(document).on 'click', '.login-trigger', (e)->
            e.preventDefault()
            SP.login()
        .on 'click', '.login-modal-box', (e)->
            e.stopPropagation()

        # 自动补全
        ac = new AutoComplete
            target: "#ac"
            source:
                data: []
        ac.render()

        # 路径导航下拉
        navDropDown = new NavDropDown
            target: ".nav-dropdown"

        # 个人中心下拉
        topbarDropDown = new TopbarDropDown
            target: ".j-dropdown-menu1"
            event: "mouseenter"

        topbarDropDown2 = new TopbarDropDown
            target: ".j-dropdown-menu2"
            event: "mouseenter"

        topbarDropDown2 = new TopbarDropDown
            target: ".j-dropdown-menu3"
            event: "mouseenter"

        #购物车按钮
        $cartBtn = $ '#j-cart-btn'
        $cartBtn.cart() if $cartBtn.length
        #通知更新购物车数据
        #$cartBtn.cart 'setShouldUpdate'

        # 微信分享
        setWeChatShare = ->

            shareData =
                title: '斯品家居商城', # 分享标题
                desc: "斯品，让居家生活更美好。年轻人的居家生活态度。\n\r www.sipin.com"
                link: location.href, # 分享链接
                imgUrl: 'http://7viii7.com2.z0.glb.qiniucdn.com/2015/07/15/72f2d4ce_share-logo.jpg', # 分享图标
                weiboAppKey: "1229563682"
                successCallback: () ->

            data =
                url: location.href.split('#')[0]

            if window.wx
                webapi.referral.getWeixinConfig(data).then (res) =>

                    # 微信配置
                    wx.config
                        debug: false,
                        appId: res.data.appid,
                        timestamp: res.data.timestamp,
                        nonceStr: res.data.noncestr,
                        signature: res.data.signature,
                        jsApiList: [
                            "onMenuShareTimeline",
                            "onMenuShareAppMessage",
                            "onMenuShareQQ",
                            "onMenuShareWeibo",
                            "hideOptionMenu",
                            "showOptionMenu"
                        ]

                    # 分享朋友圈
                    wx.onMenuShareTimeline
                        title: shareData.title, # 分享标题
                        desc: shareData.desc
                        link: shareData.link , # 分享链接
                        imgUrl: shareData.imgUrl, # 分享图标
                        success: shareData.successCallback


                    # 分享到朋友
                    wx.onMenuShareAppMessage
                        title: shareData.title, # 分享标题
                        desc: shareData.desc
                        link: shareData.link , # 分享链接
                        imgUrl: shareData.imgUrl, # 分享图标
                        success: shareData.successCallback

                    # 分享到 QQ
                    wx.onMenuShareQQ
                        title: shareData.title, # 分享标题
                        desc: shareData.desc
                        link: shareData.link , # 分享链接
                        imgUrl: shareData.imgUrl, # 分享图标
                        success: shareData.successCallback

                    # 分享到微博
                    wx.onMenuShareWeibo
                        title: shareData.title, # 分享标题
                        desc: shareData.desc
                        link: shareData.link , # 分享链接
                        imgUrl: shareData.imgUrl, # 分享图标
                        success: shareData.successCallback

        setWeChatShare()

        # pages 翻页
        $number = $ '#j-page-number, .page-number'
        $number.on 'blur', (e)->
            $el = $ @
            value = $el.val() | 0
            max = $el.data 'max'
            max = max | 0
            if value > max then value = max
            $el.val value
            $go = $el.closest('.paging').find '#j-page-go, .paging-go'
            url = $go.attr 'href'
            reg = /page=([0-9])*/g
            url = url.replace reg, 'page='+value
            $go.attr 'href', url

    page.init()

    return  page
