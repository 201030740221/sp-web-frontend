React = require 'react'
Block41 = require './block-4-1'
VerticalScroller = require './vertical-scroller'

View = React.createClass
    renderList: () ->
        @props.data.map (item, i) =>
            className = 'bg-' + (i % 3 + 1)
            <Block41 data={item} className={className} key={i} />

    render: ->
        <VerticalScroller className="presales-detail-block-4">
            {@renderList()}
        </VerticalScroller>


module.exports = View
