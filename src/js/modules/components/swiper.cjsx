###
# Swiper.
# @author remiel.
# @module Swiper
# @example Swiper
#
#   jsx:
#   <Swiper></Swiper>
#
###
React = require 'react'
objectAssign = require 'object-assign'

Swiper = React.createClass
    displayName: 'Swiper'
    propsType:
        tagName: React.PropTypes.string
        component: React.PropTypes.element
        minSwipeLength: React.PropTypes.number
        moveThreshold: React.PropTypes.number
        onSwipe: React.PropTypes.func
        onSwipeLeft: React.PropTypes.func
        onSwipeUpLeft: React.PropTypes.func
        onSwipeUp: React.PropTypes.func
        onSwipeUpRight: React.PropTypes.func
        onSwipeRight: React.PropTypes.func
        onSwipeDownRight: React.PropTypes.func
        onSwipeDown: React.PropTypes.func
        onSwipeDownLeft: React.PropTypes.func
    getDefaultProps: () ->
        tagName: 'div'
        minSwipeLength: 75
        moveThreshold: 10
    getInitialState: ->
        direction: null
        initialTouch: null
        touch: null
        swipeStart: null

    render: ->
        Component = @props.component || @props.tagName
        <div {...@props} onTouchStart={@handleTouchStart} onTouchEnd={@handleTouchEnd} onTouchCancel={@handleTouchEnd} onTouchMove={@handleTouchMove}>
            {@props.children}
        </div>


    getTouchValue: (touch) ->
        pageX: touch.pageX
        pageY: touch.pageY

    handleTouchStart: (e)->
        return 0 if e.touches.length isnt 1
        @_initiateSwipe @getTouchValue e.touches[0]

    handleTouchEnd: (e)->
        return 0 if !@state.direction
        if @_getSwipeLength(@state.initialTouch) > @props.minSwipeLength
            method = @_getEventMethodName()
            evt =
                type: @_getEventTypeName()
                timeStampStart: @state.swipeStart
                timeStampEnd: new Date()
                initialTouch: @state.initialTouch
                finalTouch: @state.touch
            @props.onSwipe and @props.onSwipe evt
            @props[method] and @props[method] evt
            e.preventDefault()

        @_resetSwipe()

    handleTouchMove: (e)->
        return 0 if e.touches.length isnt 1 or !@state.direction
        touch = @getTouchValue e.touches[0]
        direction = @_getSwipeDirection touch
        if @_isSwipeDirectionUnchanged direction
            @_updateSwipe direction, touch
            # 去掉上下方向触摸禁用
            #e.preventDefault()
        else
            @_resetSwipe()

    _initiateSwipe: (touch)->
        @setState
            direction:
                x: null
                y: null
            initialTouch: touch
            touch: touch
            swipeStart: new Date()

    _resetSwipe: ->
        @setState @getInitialState()

    _updateSwipe: (direction, touch)->
        @setState
            direction: direction
            touch: touch

    _getSwipeLength: (touch)->
        @_getSwipeLengthX(touch) + @_getSwipeLengthY(touch)


    _getSwipeLengthX: (touch)->
        Math.abs(touch.pageX - @state.touch.pageX)

    _getSwipeLengthY: (touch)->
        Math.abs(touch.pageY - @state.touch.pageY)

    _getSwipeDirection: (touch)->
        dir = objectAssign({x: null, y: null}, @state.direction)

        if @_getSwipeLengthY(touch) > @props.moveThreshold
            dir.y = @_getSwipeDirectionY touch
        if @_getSwipeLengthX(touch) > @props.moveThreshold
            dir.x = @_getSwipeDirectionX touch

        dir

    _getSwipeDirectionX: (touch)->
        if touch.pageX < @state.touch.pageX then 'Left' else 'Right'

    _getSwipeDirectionY: (touch)->
        if touch.pageY < @state.touch.pageY then 'Up' else 'Down'

    _getSwipeDirectionName: ->
        (@state.direction.y or '') + (@state.direction.x or '')

    _isSwipeDirectionUnchanged: (direction)->
        (!@state.direction.x or @state.direction.x is direction.x) and
            (!@state.direction.y or @state.direction.y is direction.y)

    _getEventMethodName: ->
        'onSwipe' + @_getSwipeDirectionName()

    _getEventTypeName: ->
        'swipe' + @_getSwipeDirectionName()


module.exports = Swiper
