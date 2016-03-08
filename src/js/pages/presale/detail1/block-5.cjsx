React = require 'react'
Slider = require './slider'
$win = $ window
$body = $ 'body'

View = React.createClass
    renderList: () ->
        data = @props.data
        if not data or not data.length
            return ''
        data.map (item, i) =>
            <img className="u-img-max-w u-img-w-100" src={item} key={i} />

    render: ->

        <div className="presales-detail-block-5" ref="box">
            <Slider auto={no}>
                {@renderList()}
            </Slider>
        </div>


module.exports = View
