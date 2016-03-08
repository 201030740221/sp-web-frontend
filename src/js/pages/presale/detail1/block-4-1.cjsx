React = require 'react'
WindowListenable = require 'modules/components/mixins/window-listenable'
ImgLoader = require './img-loader'
$win = $ window
View = React.createClass
    mixins: [WindowListenable]

    windowListeners:
        'resize': 'windowInit'
    windowInit: () ->
        @setState
            init: @state.init++

    getInitialState: ->
        show: no
        w: 0
        h: 0
        init: 1

    componentDidMount: ->
        @windowInit()
    onLoad: (el, w, h) ->
        # el = if e.target then e.target else e.srcElement
        @setState
            show: yes
            w: w
            h: h
    renderDesc: () ->
        desc = @props.data.desc
        if desc and desc.length
            list = desc.map (item, i) =>
                <li dangerouslySetInnerHTML={{__html: item}} key={i}></li>
            <ul>{list}</ul>

    render: ->
        img = ''
        if @props.data.descImg
            img = <img className="u-img-w-100" src={@props.data.descImg} />

        className = SP.classSet
            'presales-detail-block-4-1': yes
            'position-left': @props.data.position is 'left'
            'position-right': @props.data.position is 'right'
        className = className + ' ' + @props.className

        # desc = ''
        # if typeof @props.data.desc is 'string'
        #     <section>{@props.data.desc}</section>
        # else
                # <section dangerouslySetInnerHTML={{__html:@props.data.desc}}></section>
        #


        if @state.show is no
            <div className={className} ref="box">
                <div className="img-box">
                    <ImgLoader src={@props.data.background} onLoad={@onLoad}></ImgLoader>
                </div>
                <div className="presales-detail-block-text" ref="block-text-4-1">
                    <h4>{@props.data.title}</h4>
                    {@renderDesc()}
                    <div>{img}</div>
                </div>
            </div>
        else
            style =
                "marginTop": -(@state.h / 2 * $win.width() / 1920)
            <div className={className} ref="box">
                <div className="img-box">
                    <img src={@props.data.background} style={style} />
                </div>
                <div className="presales-detail-block-text" ref="block-text-4-1">
                    <h4>{@props.data.title}</h4>
                    {@renderDesc()}
                    <div>{img}</div>
                </div>
            </div>


module.exports = View
