listTpl = require './comment-list-tpl.hbs'
emptyTpl = require './comment-empty-tpl.hbs'
swipeTpl = require './swipe-tpl.hbs'
Swipe = require 'Swipe'

class Comment
    constructor: (options)->
        @options = $.extend {}, @defaults, options
        @currentPage = @options.currentPage
        @onlyPic = @options.onlyPic
        @goodsId = @options.goodsId || pageData.goodid
        @init()

    defaults:
        currentPage: 1
        size: 20
        onlyPic: -1

    init: () ->
        @el = $ '#j-comment'
        @commentRender()

    emptyRender: (data) ->
        data = data or {}
        @el.empty().append emptyTpl {
            limit: data.top_comment_limit or 5
            times: data.top_comment_multiplier or 5
        }

    commentRender: () ->
        _this = @

        data =
            goods_id: @goodsId
            page: @currentPage
            size: @options.size
            has_pic: @onlyPic

        webapi.comment.getList data
        .then (res) ->
            if res and (res.code is 0) and ((res.data.data.length > 0) or (_this.onlyPic is 1))
                _this.el.empty().append listTpl {
                    total: res.data.total_comment_count
                    data: _this.handleList res.data.data
                    rate: _this.handleRate res.data
                }
                new ImageSlider el: '.comment-list__img'
                _this.getTags _this.goodsId
                _this.handlePages res.data
                _this.filter()
            else
                _this.emptyRender(res.data)
        .fail () ->
            _this.emptyRender()

    getTags: (goodsId) ->
        $tags = @el.find '.comment__tags'
        tags = ''
        webapi.comment.getTag goods_id: goodsId
        .then (res) ->
            if res and res.code is 0 and res.data
                res.data.map (item, index) ->
                    tags += "<span class='u-label'>#{item.name}(#{item.count})</span>"
                $tags.html tags

    handleList: (data) ->
        data.map (item, index) ->
            switch item.rate
                when 0 then item.rate = '好评'
                when 1 then item.rate = '中评'
                when 2 then item.rate = '差评'
                else item.rate = '好评'
        data


    handleRate: (data) ->
        all = SP.Math.Add(data.rate_stat.positive, data.rate_stat.neutral)
        all = SP.Math.Add(all, data.rate_stat.negative)
        rate =
            positive: SP.Math.Mul(SP.Math.Div(data.rate_stat.positive, all), 100, 0)
            neutral: SP.Math.Mul(SP.Math.Div(data.rate_stat.neutral, all), 100, 0)
            negative: SP.Math.Mul(SP.Math.Div(data.rate_stat.negative, all), 100, 0)
        rate

    filter: () ->
        _this = @
        $filter = @el.find '.j-filter'

        $filter.attr '_checked', true if @onlyPic is 1

        $filter.checkbox
            callback: (value) ->
                if value
                    _this.onlyPic = 1
                    _this.commentRender()
                else
                    _this.onlyPic = -1
                    _this.commentRender()

    handlePages: (data) ->
        $prev = @el.find '.pages__prev'
        $next = @el.find '.pages__next'

        $prev.addClass '_disable' if @currentPage is 1
        $next.addClass '_disable' if @currentPage is data.last_page

        $prev.on 'click', (e) =>
            return null if $(e.currentTarget).hasClass '_disable'
            @currentPage -= 1
            @commentRender()

        $next.on 'click', (e) =>
            return null if $(e.currentTarget).hasClass '_disable'
            @currentPage += 1
            @commentRender()



class ImageSlider
    constructor: (options) ->
        @options = $.extend {}, @defaults, options
        @init()

    defaults: {}

    init: () ->
        return null if !this.options.el
        @el = $ this.options.el
        @initEvent()

    initEvent: () ->
        _this = @
        @el.each () ->
            $item = $ @
            swipe = null
            $imgWrap = $item.find '.img-wrap'
            $item.on 'click', '.img-wrap', (e) ->
                index = $imgWrap.index $(@).addClass('_active')

                if $item.data 'isSwipeShowing'
                    swipe.slide index
                    return null

                $images = $item.find 'img'
                imgSrc = []
                $images.each ()->
                    imgSrc.push $(@).data 'original-src'
                swipeHTML = swipeTpl data: imgSrc
                $view = $ swipeHTML
                $item.after $view
                $swipe = $view.find('.swipe')
                swipe = new Swipe($swipe[0], {
                    startSlide: index,
                    continuous: false,
                    callback: (idx, el) ->
                        $imgWrap.removeClass('_active')
                        $imgWrap.eq(idx).addClass('_active')
                        $view.find('.j-view').attr 'href', imgSrc[idx]
                        return ->
                })

                $view.find('.j-view').attr 'href', imgSrc[index]
                $item.data 'isSwipeShowing', true

                $swipe.find '._prev'
                .on 'click', (e)->
                    swipe.prev()
                $swipe.find '._next'
                .on 'click', (e)->
                    swipe.next()

                $view.find '.j-close'
                .on 'click', (e) ->
                    $view.remove()
                    $imgWrap.removeClass '_active'
                    $item.data 'isSwipeShowing', false

module.exports = Comment
