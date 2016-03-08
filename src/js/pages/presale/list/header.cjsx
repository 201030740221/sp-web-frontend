React = require 'react'
liteFlux = require 'lite-flux'
Store = require './_stores/presales-home'
Action = Store.getAction()
storeName = 'presales-home'

View = React.createClass

    mixins: [liteFlux.mixins.storeMixin(storeName)]

    tabText: [
        '接受预订中'
        '即将预售'
        '限量低价'
        '敬请期待'
    ]
    onChangeTab: (i) ->
        store = @state[storeName]
        index = store.tab
        if i isnt index and i isnt 3
            Action.tab i

    renderTab:() ->
        store = @state[storeName]
        index = store.tab
        list = store.list
        tabs = list.map (item, i) =>
            className = 'presales-status'
            if i is index
                className = className + ' active'
            if i < 4
                <li key={i} onClick={@onChangeTab.bind(null, i)}>
                    <table className="img-box">
                        <tbody>
                            <tr>
                                <td>
                                    <img src={item.thumbs.media.full_path} />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <h4>{item.name}</h4>
                    <div className={className}>{@tabText[i]}</div>
                </li>
        if list.length < 4
            tabs.push (
                <li key={list.length}>
                    <table className={'img-box'}>
                        <tbody>
                            <tr>
                                <td>
                                    <img src="#{staticPrefix}/images/presales/img-x.png"  />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <h4>{'神秘新品X'}</h4>
                    <div className="presales-status">{@tabText[3]}</div>
                </li>
            )


        <ul className="presales-list">
            {tabs}
        </ul>

    render: ->


        #
        # <ul className="presales-list">
        #     <li>
        #         <table className="img-box">
        #             <tr>
        #                 <td>
        #                     <img src="#{staticPrefix}/images/presales/presales-icon-04.png" />
        #                 </td>
        #             </tr>
        #         </table>
        #         <h4>123</h4>
        #         <div className="presales-status">接受预定中</div>
        #     </li>
        #     <li>
        #         <table className="img-box">
        #             <tr>
        #                 <td>
        #                     <img src="#{staticPrefix}/images/presales/presales-icon-04.png" />
        #                 </td>
        #             </tr>
        #         </table>
        #         <h4>123</h4>
        #         <div className="presales-status active">即将预售</div>
        #     </li>
        #     <li>
        #         <table className="img-box">
        #             <tr>
        #                 <td>
        #                     <img src="#{staticPrefix}/images/presales/presales-icon-04.png" />
        #                 </td>
        #             </tr>
        #         </table>
        #         <h4>123</h4>
        #         <div className="presales-status">限量低价</div>
        #     </li>
        #     <li>
        #         <table className="img-box">
        #             <tr>
        #                 <td>
        #                     <img src="#{staticPrefix}/images/presales/presales-icon-04.png" />
        #                 </td>
        #             </tr>
        #         </table>
        #         <h4>123</h4>
        #         <div className="presales-status">敬请期待</div>
        #     </li>
        # </ul>

        <div className="wrap">
            <header className="presales-header no-select">
                <h2>国际顶级设计，越早预定越实惠</h2>
                <div className="presales-header-links">
                    <a href="/article/3">常见问题</a>
                    <span>|</span>
                    <a href="/article/19">预售规则</a>
                    <span>|</span>
                    <a href="/article/10">服务保障</a>
                    <span>|</span>
                    <a href="/article/4">物流政策</a>
                </div>
                <ul className="presales-header-icons">
                    <li>
                        <img src="#{staticPrefix}/images/presales/presales-icon-01.png" />
                        <span>世界设计</span>
                    </li>
                    <li>
                        <img src="#{staticPrefix}/images/presales/presales-icon-02.png" />
                        <span>100%原创首发</span>
                    </li>
                    <li>
                        <img src="#{staticPrefix}/images/presales/presales-icon-03.png" />
                        <span>5级品控</span>
                    </li>
                    <li>
                        <img src="#{staticPrefix}/images/presales/presales-icon-04.png" />
                        <span>包邮到家</span>
                    </li>
                </ul>
                {@renderTab()}
            </header>
        </div>


module.exports = View
