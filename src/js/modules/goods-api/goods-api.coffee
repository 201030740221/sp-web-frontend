# 商品API
define ['webapi'], (webapi)->
    api = {}

    # 加入收藏夹
    api.like = (goods_ids, callback)->
        if(!SP.isLogined())
            SP.login()
            return false

        data =
            "goods_ids" : JSON.stringify([goods_ids])

        webapi.goods.like data
        .then (res) ->
            res = res || {};
            successTip = {
                0: '商品收藏成功',
                20004: '该商品已收藏'
            }
            if(res.code == 0 || res.code == 20004)
                SP.notice.success successTip[res.code]
                if callback
                    callback(true)
            else
                SP.notice.error '商品收藏失败'
                if callback
                    callback(false)

    # 取消收藏
    api.dislike = (ids, callback)->
        webapi.goods.dislike goods_ids: ids
        .then (res) ->
            if(res && res.code == 0)
                SP.notice.success "取消收藏成功"
                if callback
                    callback(true)
            else
                SP.notice.error '取消收藏失败'
                if callback
                    callback(false)

    return  api
