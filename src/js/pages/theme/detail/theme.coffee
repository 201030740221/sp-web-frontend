# 首页
Swipe = require 'Swipe'
Collocation = require '../../goods/collocation/index'
Share = require 'modules/social-share/share'
require 'modules/subject/entry'

require 'plugins'

# 轮播图
$themeBanner = $('#theme-banner').Swipe()

$themeGoodsInfo = $ '#theme-goods-info'
$goodsList = $ '#theme-goods-list'

theme_collocation_id = $goodsList.data 'theme-id'
# 加载搭配商品
if theme_collocation_id
    webapi.goods.getThemeCollocation
        id: theme_collocation_id
    .then (res)->
        if res.code is 0
            # 转换数据格式与商品推荐保持一致
            themeGoodsData = [res.data]
            ReactDom.render(React.createElement(Collocation, {data: themeGoodsData, type: 'theme'}), $goodsList[0])

            $themeGoodsInfo.scrollFixed
                'box': 'div.theme-detail'

# 分享及收藏
$themeLike = $themeGoodsInfo.children '.like'

$shareInfo = $ '#social-share'

socialShare = new Share
    'weixin_title': $shareInfo.data 'weixin-title'
    'image': $shareInfo.data 'image'
    'weixin_content': $shareInfo.data 'weixin-content'
    'weibo_content': $shareInfo.data 'weibo-content'

likeActions =
    'share-to-weixin': ->
        socialShare.toWeixin()

    'share-to-weibo': ->
        socialShare.toWeibo()

    'favorite': ->

$themeLike.on 'click', '.action', (e)->
    $this = $ @
    actionName = $this.data 'action'
    action = likeActions[actionName]

    action.call $this, e
