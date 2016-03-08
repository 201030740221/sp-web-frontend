React = require 'react'
WindowListenable = require 'modules/components/mixins/window-listenable'
EdgeVisible = require './is-edge-visible'
$win = $ window
$body = $ 'body'

View = React.createClass
    mixins: [WindowListenable, EdgeVisible]

    windowListeners:
        'scroll': 'handleScroll'
        'resize': 'windowInit'
    windowInit: () ->
        @setItemHeight()
        @fixedBox()
        @fixedNav()

    handleScroll: (e) ->
        @fixedBox()
        @fixedNav()
        @setIndexActive()


    initBoxEl: () ->
        React.Children.map @props.children, (item, i) =>
            this['$b' + i] = $ @refs['box-' + i]

    getInitialState: ->
        index: 0

    componentDidMount: ->
        b = @refs['box']
        nav = @refs['nav']

        @$b = $ b
        @$nav = $ nav

        @initBoxEl()

        @init()

    init: () ->
        @windowInit()

    setItemHeight: () ->
        h = $win.height()
        w = $win.width()
        React.Children.map @props.children, (item, i) =>
            this['$b' + i].css
                height: h

    fixedNav: () ->
        h = $win.height()
        w = $win.width()
        tot = @isTopEdgeOutFromTop @$b
        bib = @isBottomEdgeInFromBottom @$b
        boxHeight = @$b.height()
        top = 0
        right = 0
        if tot > 0
            top = tot
        if bib > 0
            top = boxHeight - h
        if w < 1600
            right = 50
        @$nav.css
            top: top + h / 2
            right: right

    fixedBox: () ->
        h = $win.height()
        tot = @isTopEdgeOutFromTop @$b
        bib = @isTopEdgeInFromBottom @$b
        boxOffset = @$b.offset()
        st = $win.scrollTop()
        @oldOffset = tot if isNaN @oldOffset
        dir = tot - @oldOffset
        @oldOffset = tot

        React.Children.map @props.children, (item, i) =>

            if bib > h * i and bib < h * (i + 1)
                if i is 0
                    if  bib > h / 4
                        @next(dir)
                    else
                        @clearTimer()
                else
                    @next(dir)

            if bib is (h * (i + 1))
                @clearTimer()

            if bib is h * (i + 1)
                @clearTimer()

            if tot > h * i and tot <= h * (i + 1)
                this['$b' + i].css
                    top: tot - h * i
            else
                this['$b' + i].css
                    top: 0

        if bib <= 0 or bib >= h * @props.children.length
            @clearTimer()

    next: (dir) ->
        @setTimer(dir)

    clearTimer: () ->
        clearTimeout @timer

    setTimer: (dir) ->
        @clearTimer()

        h = $win.height()
        bob = @isTopEdgeOutFromTop @$b
        index = Math.ceil bob / h
        if dir < 0
            index = index - 1

        @timer = setTimeout () =>
            @setScrollTop index
        , 200

    setScrollTop: (index) ->
        boxOffset = @$b.offset()
        h = $win.height()
        @setState
            index: if index <= 0 then 0 else index
        $body.animate
            scrollTop: boxOffset.top + h * index
         ,
            100
    setIndexActive: () ->
        tib = @isTopEdgeInFromBottom @$b
        bib = @isBottomEdgeInFromBottom @$b
        h = $win.height()
        if tib <= 0 and @state.index isnt -1
            @setState
                index: -1
            return ''
        React.Children.map @props.children, (item, i) =>
            if tib > h * i + h / 2 and tib <= h * (i + 1) + h / 2 and bib < 0 and @state.index isnt i
                @setState
                    index: i

    renderNav: () ->

        list = React.Children.map @props.children, (item, i) =>
            className = SP.classSet
                'active': i is @state.index
            <li className={className} key={i}></li>
        style =
            height: @props.children.length * (14 + 20) - 20
        <div className="wrap u-pr presales-detail-block-4-nav" ref="nav">
            <ul style={style}>
                {list}
            </ul>
        </div>
    renderList: () ->
        React.Children.map @props.children, (item, i) =>
            className = SP.classSet
                'u-pr': yes
                'active': i is @state.index
            <div className={className} ref="box-#{i}" key={i}>
                {item}
            </div>

    render: ->
        className = SP.classSet 'u-pr', @props.className
        <div className={className} ref="box">
            {@renderList()}
            {@renderNav()}
        </div>


module.exports = View
