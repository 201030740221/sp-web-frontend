React = require 'react'
utils = require './utils'
WindowListenable = require 'modules/components/mixins/window-listenable'

$win = $ window

PresalesGoodsInfo = require './presales-goods-info.cjsx';
PresalesGoodsInfoModalBox = require 'modules/react-modal-box/index.cjsx'
Coupon = require './coupon'
SetMessageBtn = require './set-message-btn'
Block1Info = require './block-1-info'

View = React.createClass
    mixins: [WindowListenable]

    windowListeners:
        'scroll': 'handleScroll'

    handleScroll: (e) ->
        if utils.support.transform
            @moveImg()
            @moveAside()

    shouldMove: () ->

        st = $win.scrollTop()
        offset = @$b.offset()
        top = offset.top

        move: top < st
        offset: st - top

    moveImg: () ->
        s = @shouldMove()
        h = $win.height()
        if s.move
            @$img.css
                top: s.offset*.6
                # transform: 'scale('+(h - s.offset)/h+')'
        else
            @$img.css
                top: 0

    moveAside: () ->
        s = @shouldMove()
        w = $win.width() - 20
        w = 1580 if w > 1600
        if s.move
            @$aside.css
                top: (s.offset*.8 / w * 100 + 13.75)+'%'
                # left: 10 + s.offset*1
        else
            @$aside.css
                top: '13.75%'

    getInitialState: ->
        fadeIn: no

    componentDidMount: ->
        b = @refs['box']
        img = @refs['img']
        aside = @refs['aside']

        @$b = $ b
        @$img = $ img
        @$aside = $ aside
        @setState
            fadeIn: yes

    showGoodsInfo: (event)->
        event.preventDefault()

        presalesGoodsInfoModalBox = new PresalesGoodsInfoModalBox
            width: 1024
            top: 100
            mask: true
            closeBtn: true
            component: <PresalesGoodsInfo />

        presalesGoodsInfoModalBox.show()

    render: ->
        className = SP.classSet
            "presales-block-1": yes
            "u-transition-fade-in": yes
            "u-opacity-init": not @state.fadeIn
            "u-opacity-1": @state.fadeIn
        <div className={className} ref="box">
            <div className="wrap">
                <div className="presales-block-1-img-box">
                    <img src={@props.covers} ref="img" />
                </div>
                <aside ref="aside">
                    <Block1Info />
                </aside>
            </div>
        </div>

module.exports = View
