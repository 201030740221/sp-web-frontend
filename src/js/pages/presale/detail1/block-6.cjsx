React = require 'react'
$win = $ window
$body = $ 'body'

View = React.createClass
    renderList: () ->
        @props.data.map (item, i) =>
            <div className="presales-detail-block-6-item" key={i}>
                <img src={item.img} />
                <i className="table-bg"></i>
                <section>
                    <table>
                        <tbody>
                            <tr>
                                <td>{item.desc}</td>
                            </tr>
                        </tbody>
                    </table>
                </section>
            </div>

    render: ->

        <a href="javascript:;" className="presales-detail-block-6 u-clearfix" ref="box">
            {@renderList()}
        </a>


module.exports = View
