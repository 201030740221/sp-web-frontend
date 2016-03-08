# 收藏夹
define ['CheckAll', './tpl-item.hbs'], ( CheckAll, itemTemplate )->
    class favoriteList
        constructor: (@options)->
            this.page = 1
            this.lastPage = 1
            this.data = []

        # 初始化
        init: ()->
            self = this
            # 加载首页
            self.getData 1,()->
                self.render()

            #上一页
            $(document).on "click", "#j-prev-favorite",(e)->
                if $(this).hasClass('_disable')
                    return false

                self.prevPage($(this))
                return false
            #下一页
            $(document).on "click", "#j-next-favorite",(e)->
                if $(this).hasClass('_disable')
                    return false

                self.nextPage($(this))
                return false

            # 取消收藏
            $(document).on "click","#j-cancel-favorite",()->
                self.handleDeleteFavorite()
                return false
            # 取消单条收藏
            $(document).on "click",".j-cancel-one-favorite", ()->
                indexs = [$(this).closest(".cart-table__item").data("key")]
                ids = [$(this).data("id")];
                self.deleteFavorite(ids, indexs);
                return false

        # 重新加载数据
        reGetData: ()->
            # location.reload()

            self = this
            page = self.page
            self.getData page,()->
                self.render()

        # 获取数据
        getData: (page,callback)->
            self = this

            SP.get SP.config.host + "/api/member/favorite",{
                page: page || self.page
            },(res)->
                if(res && res.code == 0)
                    self.page = res.data["current_page"]
                    self.lastPage = res.data["last_page"]
                    self.data = res.data.data
                    #更新页码按钮状态
                    if(self.page ==self.lastPage)
                        $("#j-next-favorite").addClass("_disable")
                    else
                        $("#j-next-favorite").removeClass("_disable")

                    if(self.page == 1)
                        $("#j-prev-favorite").addClass("_disable")
                    else
                        $("#j-prev-favorite").removeClass("_disable")
                    callback()

                else
                    SP.log ("收藏数据获取出错")

        # 渲染页面
        render: ()->
            self = this
            # console.log self.data, '...'
            if(self.data.length)
                template = itemTemplate(self.data)
                $("#j-favorite-body").html(template)
                initCheckbox = ($el)->
                    $el.checkAll(
                        checkboxClass: '.ui-checkbox'
                        callback: (checked, $el)->
                    )
                initCheckbox $ '.cart-table'
            else
                #$("#j-favorite-body").html('<div class="cart-table__item u-text-center u-clearfix">暂时没有任何收藏</div>')
                self.renderEmpty()

        renderEmpty: ()->
            $empty = [
                    '<div class="cart-table__empty">'
                    '<div class="cart-table__empty-info">'
                    '<div class="u-f18">收藏夹暂时没有商品！</div>'
                    '<div class="u-f14">'
                    '您可以 '
                    '<a href="/">返回首页</a>'
                    ' 挑选喜欢的商品'
                    '</div>'
                    '</div>'
                    '</div>'
                ].join ''
            $ '.main-layout-container'
            .html $empty
        # 点击取消收藏
        handleDeleteFavorite: ()->
            self = this
            ids = []
            indexs = []
            checkFavs = $(".cart-table__inner .check-fav")
            checkFavs.each ()->
                if $(this).attr("_checked")=="true"
                    indexs.push $(this).closest(".cart-table__item").data("key")
                    ids.push $(this).data("id")
            if(ids.length)
                self.deleteFavorite(ids, indexs)
            return false

        # 取消收藏
        deleteFavorite: (ids, indexs)->
            self=@
            SP.post SP.config.host + "/api/member/favorite/delete", {
                goods_ids: JSON.stringify(ids)
            },(res)->
                if(res && res.code == 0)
                    SP.notice.success '取消收藏成功'
                    $.each ids,(index,id)->
                        $(".cart-table__item-"+id).remove();
                    #@tofishes 检查剩余项目,有分页，所以重新获取数据
                    isEmpty = $('#j-favorite-body').children().length == 0
                    if isEmpty then self.reGetData()

                else
                    SP.notice.error '取消收藏失败'

        #上一页
        prevPage: ($btn)->
            self = this
            page = Math.max 1, self.page - 1

            if(page == 1)
                $btn.addClass '_disable'

            self.getData page,()->
                self.render()
            return false

        #下一页
        nextPage: ($btn)->
            self = this
            page = Math.min self.page + 1, self.lastPage

            if(page == self.lastPage)
                $btn.addClass '_disable'

            self.getData page,()->
                self.render()
            return false

    return  favoriteList
