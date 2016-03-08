React = require 'react'
utils = require './utils'
WindowListenable = require 'modules/components/mixins/window-listenable'
$win = $ window

GoodsInfo = require('./goods-info.cjsx');

View = React.createClass

    render: ->
        <div className="presales-detail-block-1" ref="box">
            <div className="wrap u-pr">
                <div className="img-box">
                    <img src={@props.data}/>
                </div>
                <GoodsInfo className="presales-detail-goods-info" />
            </div>
            <div className="u-text-center">
                <img src="#{staticPrefix}/images/presales/detail/presales-detail-block-1-footer.png" />
            </div>
        </div>

module.exports = View
