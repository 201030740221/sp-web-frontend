React = require 'react'
Slider = require './slider'
utils = require './utils'
WindowListenable = require 'modules/components/mixins/window-listenable'
$win = $ window
ImgLoader = require './img-loader'

Ani = React.createClass
    getInitialState: ->
        init: no
    componentWillReceiveProps: (props) ->
        if props.init is yes and @state.init is no
            @setState
                init: yes

    getStyle: (index) ->
        if not utils.support.transform
            return {}
        init = @state.init
        transition = utils.getProperty 'Transition'
        transform = utils.getProperty 'transform'
        style = {}
        if init
            style[transition] = 'transform .5s ease-in ' + (.25*index) + 's'
            style[transform] = 'translateY(0)'
        style

    render: ->
        className = SP.classSet 'presales-ani', @props.className
        style = @getStyle @props.index
        <div {...@props} className={className} style={style}>
            {@props.children}
        </div>


# SpecialItem = React.createClass
#     mixins: [WindowListenable]
#
#     windowListeners:
#         'resize': 'windowInit'
#     windowInit: () ->
#         @setHeight()
#
#     componentDidMount: ->
#         @$b = $ @refs['box']
#         @windowInit()
#
#     setHeight: () ->
#         @$b.height $win.width() * @props.h / @props.w
#     renderList: () ->
#         className =
#             'li': SP.classSet
#                 'u-fl': yes
#         @props.data.list.map (item, i) =>
#             <li className={className.li} key={i}>
#                 <img className="u-pr" src={item.img} />
#                 <footer>
#                     <h5>{item.title}</h5>
#                     <img src="#{staticPrefix}/images/presales/detail/presales-detail-3-4.png" />
#                     <section>{item.desc}</section>
#                 </footer>
#             </li>
#
#
#     render: ->
#         data = @props.data
#         <div className="presales-block-2-special-item" ref="box">
#             <header>
#                 <h5>{data.title}</h5>
#                 <section>{data.desc}</section>
#                 <a href={data.url}>观看详情</a>
#             </header>
#             <ul>
#                 {@renderList()}
#             </ul>
#         </div>

List = React.createClass
    mixins: [WindowListenable]

    windowListeners:
        'scroll': 'handleScroll'

    handleScroll: (e) ->
        if utils.support.transform
            @visited()
            @moveSlider()

    shouldMove: () ->
        st = $win.scrollTop()
        offset = @$b.offset()
        top = offset.top

        move: top < st
        offset: st - top

    isBottomEdgeOutFromTop: ($el) ->
        st = $win.scrollTop()
        offset = $el.offset()
        top = offset.top
        height = $el.height()

        st - top - height
    visited: () ->
        st = $win.scrollTop()
        offset = @$b.offset()
        top = offset.top
        # console.log st + $win.height() , top
        if st + $win.height() > top and @state.visited is no
            @setState
                visited: yes

    moveSlider: () ->
        s = @shouldMove()
        h = $win.height()
        ibt = @isBottomEdgeOutFromTop @$b
        if s.move
            if ibt > 0
                @$slider.css
                    top: h*.6
            else
                @$slider.css
                    top: s.offset*.6
        else
            @$slider.css
                top: 0

    getInitialState: ->
        visited: no

    componentDidMount: ->
        b = @refs['box']
        slider = @refs['slider']
        @$b = $ b
        @$slider = $ slider

        @visited()

    renderList: () ->
        @props.data.map (item, i) =>
            if i < 3
                # if i is 1
                #     # <Ani index={i} init={@state.visited} key={i}>
                #     #     <SpecialItem data={item} w={@props.w} h={@props.h} />
                #     # </Ani>
                #     width = @props.w/3
                #     height = $win.width() / @props.w * @props.h
                #     <Ani index={i} init={@state.visited} key={i}>
                #         <img src={item} key={i} width={width} height={height}/>
                #     </Ani>
                # else
                #     <Ani index={i} init={@state.visited} key={i}>
                #         <img src={item} />
                #     </Ani>

                <Ani index={i} init={@state.visited} key={i}>
                    <img src={item} />
                </Ani>
            else
                <img src={item} key={i} />

    render: ->
        <div className="presales-block-2" ref="box">
            <Slider auto={no} active={1} ref="slider">
                {@renderList()}
            </Slider>
        </div>


View = React.createClass
    getInitialState: ->
        imgLoaded: no
        w: 0
        h: 0

    onLoad: (el, w, h) ->
        # el = if e.target then e.target else e.srcElement
        @setState
            imgLoaded: yes
            w: w
            h: h
    render: ->
        if not @state.imgLoaded
            <ImgLoader src={@props.data[0]} onLoad={@onLoad}></ImgLoader>
        else
            <List w={@state.w} h={@state.h} {...@props}/>


module.exports = View
