# cart
define ['Swipe', 'FavoriteList', 'plugins'], (Swipe, FavoriteList)->
    # 收藏夹列表
    favoriteList = new FavoriteList()
    favoriteList.init()

    $('#referral-goods-list').slider({
        circular: 0,
        btnPrev: '#referral-goods-prev',
        btnNext: '#referral-goods-next'
    });
