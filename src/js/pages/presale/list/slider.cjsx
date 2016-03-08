###
# Slider.
# @author remiel.
# @module Slider
# @example Slider
#
#   jsx:
#   <Slider></Slider>
#
# @param options {Object} the options
#
###
React = require 'react'
utils = require './utils'
WindowListenable = require 'modules/components/mixins/window-listenable'
T = React.PropTypes

Swiper = require 'modules/components/swiper'
Tappable = require 'modules/components/tappable'
Img = require 'modules/components/img'

Slider = React.createClass
    mixins: [WindowListenable]

    windowListeners:
        'resize': 'initSize'

    propTypes:
        # type: T.number
        duration: T.number
        auto: T.bool
        delay: T.number
        active: T.number
        nav: T.bool
        "full-screen": T.bool

    getDefaultProps: ->
        # type: 0
        duration: 200
        auto: yes
        delay: 5000
        active: 0


    getInitialState: ->
        @transformProperty = utils.getProperty 'Transform'
        @transitionProperty = utils.getProperty 'Transition'
        width: null
        active: @props.active || 0
        moved: no


    componentDidMount: ->
        @initSize()
        if @props.auto is yes
            @autoPlay()

    componentWillUnmount: ->
        @cancelAutoPlay()

    renderNavList: () ->
        children = @props.children
        index = @state.active
        return null if not @props.nav

        if children and children.length
            node = React.Children.map children, (item, i) =>
                classes = SP.classSet
                    "presales-slider-nav-item": yes
                    "active": i is index
                <Tappable key={i} className={classes} onClick={@jumpToIndex.bind null, i}></Tappable>

        classes = SP.classSet
            "presales-slider-nav": yes
            "nav-at-center": @props['nav-center']
            "nav-at-right": @props['nav-right']
            "nav-gold": @props['nav-gold']
            "nav-gray": @props['nav-gray']
        <div className={classes}>
            {node}
        </div>


    render: ->

        width = @state.width
        index = @state.active
        children = @props.children

        styles =
            inner:{}
        if width isnt null
            styles.inner =
                width: width * children.length - width / 3 * 2
            if utils.support.transform
                # 保证初始化的时候 定位到active不会出现滑动效果, 直接定位
                if @state.moved
                    styles.inner[@transitionProperty] = 'all ' + @props.duration + 'ms '
                styles.inner[@transformProperty] = @getPosition()
            else
                # 不支持transform
                styles.inner['left'] = @getPositionLeft()
        className = SP.classSet
            "presales-slider": yes
            "full-screen": @props["full-screen"]
        <div ref="wrapper" className={className} onTouchMove={@preventDefault} onTouchStart={@preventDefault} onMouseEnter={@onMouseEnter} onMouseLeave={@onMouseLeave} >
            <Swiper ref="inner" onSwipe={@onSwipe} moveThreshold={4} minSwipeLength={10} className="presales-slider-inner" style={styles.inner}>
                {@renderList(styles)}
            </Swiper>
            {@renderNavList()}
            <a className="prev" onClick={@prev} />
            <a className="next" onClick={@next} />
        </div>

    renderList: (styles) ->
        width = @state.width
        index = @state.active
        children = @props.children

        if children and children.length
            React.Children.map children, (item, i) =>
                if i is 1
                    style =
                        width: width/3
                else
                    style =
                        width: width
                <div className="presales-slider-item" style={style} key={i} >
                    {item}
                </div>

    initSize: () ->
        wrapper = @refs.wrapper
        wrapperWidth = wrapper.offsetWidth
        @setState
            width: wrapperWidth

    getPosition: () ->
        width = @state.width
        index = @state.active
        x = 0
        switch index
            when 0
                x = 0
            when 1
                x = width / 3 * 2
            else
                x = index * width - width / 3 * 2
        @setTransform -x + 'px', 0, 0
    getPositionLeft: () ->
        width = @state.width
        index = @state.active
        x = 0
        switch index
            when 0
                x = 0
            when 1
                x = width / 3 * 2
            else
                x = index * width - width / 3 * 2
        -x + 'px'

    setTransform: (x, y, z) ->
        if utils.support.transform3d
            'translate3d(' + x + ',' + y + ',' + z + ')'
        else
            'translate(' + x + ',' + y + ')'

    onSwipeLeft: (e) ->
        @setActiveIndex 1

    onSwipeRight: (e) ->
        @setActiveIndex -1

    onSwipe: (e) ->
        if e.type is 'swipeUpLeft' or e.type is 'swipeDownLeft' or e.type is 'swipeLeft'
            @onSwipeLeft()
        if e.type is 'swipeUpRight' or e.type is 'swipeDownRight' or e.type is 'swipeRight'
            @onSwipeRight()

    jumpToIndex: (value) ->
        width = @state.width
        children = @props.children
        length = children.length
        if width isnt null
            if isNaN value
                index = 0
            else
                index = value
            if index >= 0 and index < length
                @setState
                    active: index
                    moved: yes
            else if index >= length
                @setState
                    active: length - 1
                    moved: yes
            else
                @setState
                    active: 0
                    moved: yes

    setActiveIndex: (value) ->
        width = @state.width
        children = @props.children
        length = children.length
        if width isnt null
            index = @state.active
            index += value
            if index >= 0 and index < length
                @setState
                    active: index
                    moved: yes
            else if index >= length
                @setState
                    active: 0
                    moved: yes
            else
                @setState
                    active: length - 1
                    moved: yes

    next: () ->
        @setActiveIndex 1

    prev: () ->
        @setActiveIndex -1

    autoPlay: () ->
        @cancelAutoPlay()
        @autoTimer = setTimeout () =>
            index = @state.active
            @next()
            @autoPlay()
        , @props.delay

    cancelAutoPlay: () ->
        clearTimeout @autoTimer

    preventDefault: (e) ->
        # 暂时取消. TODO:加入x,y判断
        e.preventDefault() if @props.preventDefault
        @autoPlay() if @props.auto

    onMouseEnter: (e) ->
        @cancelAutoPlay()

    onMouseLeave: (e) ->
        @autoPlay() if @props.auto

module.exports = Slider
