Lottery = require 'modules/lottery/index'
Tab = require 'modules/tab/rc-tab'
TabPane = Tab.TabPane;

autoScroll = (target) ->
    $target = $ target
    return null if $target.height() < $target.parent().height()
    scrollHeight = - $target.find('li').height()
    interval = 1500
    timeScroll = 0
    run = ->
        $target.animate { marginTop: scrollHeight }, interval, 'linear', ->
            $target.css(marginTop: '0px').find('li:first').appendTo this
            return
        timeScroll = setTimeout run, interval
        return

    run()

    $target.hover ->
        clearTimeout timeScroll
        $target.stop()
        return
    , ->
        run()
        return

    return


Section = React.createClass
    getInitialState: ->
        publicResult: null
        myResult: null
        lottery_id: LOTTERY_ID or 1
        times: 0

    componentDidMount: ->
        @getPublicResult @state.lottery_id

    getPublicResult: (id) ->
        webapi.lottery.getPublicResult(id).then (res) =>
            @setState
                publicResult: res.data.data

    getMyResult: (id) ->
        webapi.lottery.getMyResult(id).then (res) =>
            @setState
                myResult: res.data.data

    onTabChange: (key) ->
        if key is "2" and SP.isLogined()
            @getMyResult @state.lottery_id

    handleScroll: (target) ->
        return null unless target
        autoScroll target

    renderPublicResult: ->
        node = null
        result = @state.publicResult
        if result
            node =
                <ul ref={@handleScroll} className="result">
                {
                    result.map (item, i) ->
                        <li className="result-item" key={i}>
                            <span className="user-name">{item.member_name}</span>
                            获得
                            <span className="prize-name">{item.prize_name}</span>
                        </li>
                }
                </ul>
        else
            node =
                <p>暂无数据</p>

        node

    renderMyResult: ->
        node = null
        result = @state.myResult

        if not SP.isLogined()
            node = <a className="login-trigger">登录查看</a>
        else if result
            node =
                <div className="my-result">
                    <ul className="result">
                    {
                        result.map (item, i) ->
                            <li className="result-item" key={i}>
                                <span className="user-name">{item.created_at.split(' ')[0]}</span>
                                获得
                                <span className="prize-name">{item.prize_name}</span>
                            </li>
                    }
                    </ul>
                </div>
        else
            node =
                <p>暂无纪录</p>

        node


    render: ->
        return (
            <div className="u-clearfix">
                <Lottery id={@state.lottery_id} />
                <div className="lottery-aside u-fl">
                    <Tab defaultActiveKey="1" onChange={@onTabChange}>
                        <TabPane tab="中奖名单" key="1">
                            {@renderPublicResult()}
                        </TabPane>
                        <TabPane tab="我的中奖纪录" key="2">
                            {@renderMyResult()}
                        </TabPane>
                    </Tab>
                </div>
            </div>
        )

module.exports = Section
