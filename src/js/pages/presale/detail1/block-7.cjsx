React = require 'react'
$win = $ window
$body = $ 'body'

View = React.createClass
    renderDesc: (desc) ->
        if desc
            <section>
                <table>
                    <tbody>
                        <tr>
                            <td>{desc}</td>
                        </tr>
                    </tbody>
                </table>
            </section>
    renderBg: (desc) ->
        if desc
            <i className="table-bg"></i>


    renderList: () ->
        @props.data.map (item, i) =>
            <div className="presales-detail-block-7-item" key={i}>
                <img src={item.img} />
                {@renderBg(item.desc)}
                {@renderDesc(item.desc)}
            </div>

    render: ->

        <a href="javascript:;" className="presales-detail-block-7" ref="box">
            {@renderList()}
        </a>


module.exports = View
