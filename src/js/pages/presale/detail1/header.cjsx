React = require 'react'

View = React.createClass

    render: ->
        <header className="presales-detail-header no-select">
            <div className="wrap">
                <div className="presales-detail-header-text">
                    <span className="u-color_red u-f14 u-mr_5">商品预售</span>
                    <span className="u-color_black">首页 / 预售</span>
                </div>
            </div>
        </header>


module.exports = View
