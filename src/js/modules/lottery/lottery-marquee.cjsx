###
# Marquee.
# @author remiel.
# @module lottery
###
Loading = <div>Loading...</div>
T = React.PropTypes

Marquee = React.createClass
    propTypes:
        data: T.array
        start: T.func
        callback: T.func

    getDefaultProps: ->
        data: []
        start: () ->
            # console.log ''
        callback: () ->
            # console.log ''

    getInitialState: ->
        active: -1
        drawing: no
        hasResult: no
        count: 0
        delay: 100

    componentWillReceiveProps: (props) ->
        if props.result is -1
            @clearTimeout()
            @callbackClearTimeout()
            @setState
                hasResult: no
                drawing: no
                count: 0
                delay: 100

        else if props.result isnt null
            @setState
                hasResult: yes
                drawing: no
        else
            @setState
                hasResult: no

    componentWillUnmount: ->
        @clearTimeout()
        @callbackClearTimeout()

    renderList: () ->
        if @props.data is null
            return <Loading inside/>

        @props.data.map (item, i) =>
            @renderItem(item, i)

        # row1 =
        #     <div className="lottery-marquee-row lottery-marquee-row-1" key={1}>
        #         {@renderRow(1)}
        #     </div>
        #
        # row2 =
        #     <div className="lottery-marquee-row lottery-marquee-row-2" key={2}>
        #         {@renderRow(2)}
        #         {@renderContent()}
        #     </div>
        #
        # row3 =
        #     <div className="lottery-marquee-row lottery-marquee-row-3" key={3}>
        #         {@renderRow(3)}
        #     </div>
        # [row1, row2, row3]


    # renderRow: (n) ->
    #     data = @props.data
    #     node = []
    #     switch n
    #         when 1 then data.map (item, i) =>
    #             node.push @renderItem(item, i) if i < 2
    #         when 2 then data.map (item, i) =>
    #             node.push @renderItem(item, i) if i is 2 or i is 5
    #         when 3 then data.map (item, i) =>
    #             node.push @renderItem(item, i) if i is 3 or i is 4
    #     node


    renderItem: (item, i) ->
        className = SP.classSet
            "lottery-marquee-item": yes
            "active": i is @state.active
        className = SP.classSet className, "lottery-marquee-item-" + i
        <div className={className} key={i}>
            <div className="lottery-marquee-item-inner">
                <img src={item.pics.pc} w={100} h={100} />
            </div>
        </div>

    renderContent: () ->
        btnClassName = SP.classSet
            "lottery-marquee-btn": true
            "disabled": not (@state.hasResult is no and @state.drawing is no) or not (@props.times > 0)
        btnText = if (@state.hasResult is no and @state.drawing is no) then "马上抽大奖 GO!" else "正在抽奖中"
        if not @props.isLogin
            node =
                <div className="lottery-marquee-content-inner">
                    <div className="u-f14">登录账号，点击抽大奖GO
                        <button className="lottery-marquee-btn" onClick={@props.login}>登录抽奖</button>
                    </div>
                </div>
        else if @props.times is null
            node = <Loading inside/>
        else if @props.begin isnt yes
            node =
                <div className="lottery-marquee-content-inner u-f14">
                    <span>抽奖活动未开始</span>
                </div>
        else if @props.end isnt yes
            node =
                <div className="lottery-marquee-content-inner u-f14">
                    <span>抽奖活动已结束</span>
                </div>
        else
            node =
                <div className="lottery-marquee-content-inner">
                    <div className="u-f14">今日抽奖机会
                        <span className="u-f20 u-color_red">{@props.times}</span>次
                        <button className={btnClassName} onClick={@start} >{btnText}</button>
                    </div>
                </div>
        <div className="lottery-marquee-content">
            {node}
        </div>


    start: () ->
        if @state.hasResult is no and @state.drawing is no and @props.times > 0
            @props.start()
            @setState
                active: 0
                drawing: yes
                count: @props.data.length * 2
            setTimeout () =>
                @setTimeout()
            ,20

    change: () ->
        data = @props.data
        len = data.length
        active = @state.active + 1
        if active >= len
            active = 0
        # switch active
        #     when 3 then active = 5
        #     when 6 then active = 4
        #     when 5 then active = 3
        #     when 4 then active = 0
        @setState
            active: active
            delay: @state.delay + 2
        @setTimeout()

    changeToResult: () ->
        data = @props.data
        len = data.length
        result = @props.result
        count = @state.count
        delay = @state.delay
        active = @state.active + 1
        if active >= len
            active = 0
        # switch active
        #     when 3 then active = 5
        #     when 6 then active = 4
        #     when 5 then active = 3
        #     when 4 then active = 0

        # console.log @state, @props
        if count is 0
            if result isnt @props.data[active].id
                @setState
                    active: active
                    drawing: no
                    delay: delay + 120
                @setTimeout()
            else
                @setState
                    active: active
                @callbackSetTimeout()
        else
            @setState
                active: active
                drawing: no
                count: count - 1
                delay: delay + 30
            @setTimeout()

    callbackSetTimeout: () ->
        @callbackTimer = setTimeout () =>
            @props.callback()
            @setState
                drawing: no
                count: 0
                delay: 100
        , 2500

    callbackClearTimeout: () ->
        clearTimeout @callbackTimer


    setTimeout: () ->
        # console.log @state.drawing, @state.hasResult
        @clearTimeout()
        if @state.drawing is no and @state.hasResult is yes
            @timer = setTimeout ()=>
                @changeToResult()
            , @state.delay
        else if @state.drawing is yes
            @timer = setTimeout ()=>
                @change()
            , @state.delay

    clearTimeout: () ->
        clearTimeout @timer

    renderBorder: (n) ->
        for i in [1..n]
            <i key={i}></i>

    render: ->
        className = SP.classSet
            "lottery-marquee-main": true
            "active": not (@state.hasResult is no and @state.drawing is no)
        <div className={className}>
            <div className="lottery-marquee-list">
                <div className="lottery-marquee-border lottery-marquee-top">
                    {@renderBorder(20)}
                </div>
                <div className="lottery-marquee-border lottery-marquee-bottom">
                    {@renderBorder(20)}
                </div>
                <div className="lottery-marquee-border lottery-marquee-left">
                    {@renderBorder(10)}
                </div>
                <div className="lottery-marquee-border lottery-marquee-right">
                    {@renderBorder(10)}
                </div>
                {@renderContent()}
                {@renderList()}
            </div>
        </div>

module.exports = Marquee
