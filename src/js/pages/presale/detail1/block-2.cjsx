React = require 'react'
utils = require './utils'
WindowListenable = require 'modules/components/mixins/window-listenable'
EdgeVisible = require './is-edge-visible'
$win = $ window
View = React.createClass
    mixins: [WindowListenable, EdgeVisible]

    windowListeners:
        'scroll': 'handleScroll'
        'resize': 'windowInit'
    windowInit: () ->
        @setVariable()
        @setBoxHeight()
        @setTextPosition()

    handleScroll: (e) ->
        @fixedBox()
        @scaleImg()

    getInitialState: ->
        scaled: no

    componentDidMount: ->
        b = @refs['box']
        bi = @refs['box-inner']
        scaleImg = @refs['scale-img']
        leftBox = @refs['left-box']
        rightBox = @refs['right-box']
        centerBoxImg = @refs['center-box-img']
        centerBoxDesc = @refs['center-box-desc']
        scaleImg = @refs['scale-img']
        blockText = @refs['block-text']

        @$b = $ b
        @$bi = $ bi
        @$scaleImg = $ scaleImg
        @$leftBox = $ leftBox
        @$rightBox = $ rightBox
        @$centerBoxImg = $ centerBoxImg
        @$centerBoxDesc = $ centerBoxDesc
        @$blockText = $ blockText

        @init()

    init: () ->

        @windowInit()
        @scaleImg()

    setVariable: () ->
        h = $win.height()
        w = $win.width()

        @maxSize = 2990/1920*w
        @minSize = 460/1920*w
        @scrollDistance = h

    setBoxHeight: () ->
        h = $win.height()
        w = $win.width()
        @$bi.css
            height: h

        @$b.css
            height: h # + @scrollDistance

    setTextPosition: () ->
        h = $win.height()
        @$blockText.css
            marginBottom: h/760*150

    fixedBox: () ->
        offset = @isTopEdgeOutFromTop @$b
        ibt = @isBottomEdgeOutFromTop @$b
        if offset > 0
            if ibt > 0
                @$bi.css
                    top: $win.height()
            else
                @$bi.css
                    top: offset
        else
            @$bi.css
                top: 0

    scaleImg: () ->
        offset = @isTopEdgeOutFromTop @$b
        bottomOffset = @isTopEdgeInFromBottom @$b

        w = $win.width()
        h = $win.height()
        opacity = 1
        scale = @maxSize/@minSize
        if bottomOffset > 0
            scale = (@scrollDistance - bottomOffset)/@scrollDistance*scale
        originScale = scale
        if scale <= 1
            scale = 1
        if scale <= 1.5
            opacity = 2 * scale - 2
        css =
            opacity: opacity
            transform: 'scale(' + scale + ')'
        @$scaleImg.css css

        sideOpacity = 0
        if scale <= 2
            sideOpacity = -scale + 2
        @$leftBox.css
            opacity: sideOpacity
            left: 50 * (1 - sideOpacity) + '%'
        @$rightBox.css
            opacity: sideOpacity
            right: 50 * (1 - sideOpacity) + '%'
        @$centerBoxImg.css
            opacity: 1 - opacity
        @$centerBoxDesc.css
            opacity: 1 - opacity
        scaled = @state.scaled
        if scale is 1 and scaled isnt yes
            @setState
                scaled : yes
        if scale isnt 1 and scaled isnt no
            @setState
                scaled : no
    renderList: () ->
        data = @props.data
        list = data.list
        if not list or not list.length
            return ''
        className =
            'li': SP.classSet
                'u-fl': yes
                'scaled': @state.scaled
        list.map (item, i) =>
            ref = ''
            if i is 0
                ref = 'left-box'

            if i is 2
                ref = 'right-box'
            if i is 1
                <li className="#{className.li} scale-box-li" key={i}>
                    <img className="u-pr" src={item.img} ref="center-box-img" />
                    <div className="scale-box" ref="scale-box">
                        <img src={item.img2} ref="scale-img" />
                    </div>
                    <div className="scale-box-desc" ref="center-box-desc">
                        <h5>{item.title}</h5>
                        <img src="#{staticPrefix}/images/presales/detail/icon-01.png" />
                        <section>{item.desc}</section>
                    </div>
                </li>
            else
                # <li className={className.li} ref={ref}>
                #     <img className="u-pr" src={item.img} />
                #     <div className="scale-box-desc">
                #         <h5>{item.title}</h5>
                #         <img src="#{staticPrefix}/images/presales/detail/icon-01.png" />
                #         <section>{item.desc}</section>
                #     </div>
                # </li>
                <li className={className.li} ref={ref} key={i}>&nbsp;</li>


    render: ->
        data = @props.data
        className =
            'li': SP.classSet
                'u-fl': yes
                'scaled': @state.scaled
        desc = ''
        if data.desc
            desc = <section>{data.desc}</section>
        <div className="presales-detail-block-2" ref="box">
            <div className="presales-detail-block-inner" ref="box-inner">
                <div className="presales-detail-block-text" ref="block-text">
                    <h4 className="u-text-center">{data.title}</h4>
                    {desc}
                </div>
                <ul className="u-clearfix img">
                    {@renderList()}
                </ul>
            </div>
        </div>

module.exports = View
