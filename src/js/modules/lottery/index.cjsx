Marquee = require './lottery-marquee'
Modal = require 'ModalBox'
NewAddress = require 'NewAddress'

renderResultTitle = (result) ->
    type = result.prize_type
    name = result.prize_name
    node = ''
    # 0 - 积分
    # 1 - 优惠券
    # 2 - 实体商品
    # 3 - 再来一次
    # 4 - 空
    switch type
        when 0
            node =
                <div className="u-f14 u-mb_15">
                    恭喜您获得了由斯品商城提供的
                    <div className="u-f18 u-color_yellow">{result.prize_name}</div>
                </div>
        when 1
            node =
                <div className="u-f14 u-mb_15">
                    恭喜您获得了由斯品商城提供的
                    <div className="u-f18 u-color_yellow">{result.prize_name}</div>
                </div>
        when 2
            node =
                <div className="u-f14 u-mb_15">
                    恭喜您获得了由斯品商城提供的
                    <div className="u-f18 u-color_yellow">{result.prize_name}</div>
                </div>
        when 5
            node =
                <div className="u-f14 u-mb_15">
                    恭喜您获得了由斯品商城提供的
                    <div className="u-f18 u-color_yellow">{result.prize_name}</div>
                </div>

    return node

renderResultText = (result) ->
    type = result.prize_type
    name = result.prize_name
    node = ''
    # 0 - 积分
    # 1 - 优惠券
    # 2 - 实体商品
    # 3 - 再来一次
    # 4 - 空
    switch type
        when 0
            node =
                <div className="u-color_white u-opacity_6">
                    <div>积分已计入您的账户，您可以在“个人中心&gt;我的积分”中查看</div>
                </div>
        when 1
            node =
                <div className="u-color_white u-opacity_6">
                    <div>优惠券已计入您的账户，您可以在“个人中心&gt;我的优惠券”中查看</div>
                </div>
        when 3
            node =
                <div className="u-color_white u-opacity_6">
                    <div>再来一次</div>
                </div>
        else
            node =
                <div className="u-color_white u-opacity_6">
                    <div></div>
                </div>

    return node

renderResultImg = (result)->
    type = result.prize_type
    name = result.prize_name
    # node = ''
    node =
        <div className="lottery-result-img lottery-result-img-#{type}">
            <img src={result.prize_pics.pc_popup}/>
        </div>

    return node

ResultBox = React.createClass
    handleClick: ->
        type = @props.result.prize_type
        @props.modalBox.close()
        if type is 2 or type is 5
            showAddressBox @props.result

    render: ->
        type = @props.result.prize_type
        btnText = ''

        if type is 2 or type is 5
            btnText = '马上填写收货地址'
        else
            btnText = '知道了'

        return (
            <div className="u-pt_30 u-pr_15 u-pl_15 u-text-center u-color_white">
                {@props.children}
                <button className="btn u-mb_15" onClick={@handleClick}>{btnText}</button>
            </div>
        )

showResult = (result) ->
    modalBox = new Modal
        template: '<div class="lottery-result"></div>'
        width: 460
        top: 50
        mask: true
        # closeBtn: true,
    modalBox.show()
    content =
        <ResultBox result={result} modalBox={modalBox}>
            {renderResultTitle(result)}
            {renderResultText(result)}
            {renderResultImg(result)}
        </ResultBox>
    ReactDom.render(content, modalBox.modal.find('.lottery-result')[0])

showAddressBox = (result) ->
    handleAddress = (value)->
        address_id = value[value.length - 1].id
        webapi.lottery.setAddress(result.id, address_id)
        .then (res) =>
            modalBox.close()
            SP.notice.success '提交成功，请耐心等候！'

    cancelCallback = ->
        modalBox.close()

    modalBox = new Modal
        template: '<div class="lottery-address"></div>'
        width: 610
        top: 100
        mask: true
        # closeBtn: true,
    modalBox.show()
    modalBox.modal.find('.lottery-address').newAddress
        callback: handleAddress
        cancelCallback: cancelCallback


Lottery = React.createClass
    getInitialState: ->
        # lottery_id: 6
        lottery: {}
        # prizeList: []
        result: null
        myResult: null
        times: 0

    componentDidMount: ->
        @getEligibility @props.id
        @getLottery @props.id
        # @getPrizeList(@state.lottery_id)


    getLottery: (id) ->
        webapi.lottery.getLottery(id).then (res) =>
            if res.code is 0
                @setState
                    lottery: res.data

    # getPrizeList: (id)->
    #     webapi.lottery.getPrizeList(id).then (res) =>
    #         @setState
    #             prizeList: res.data

    getEligibility: (id) ->
        webapi.lottery.getEligibility(id).then (res) =>
            @setState
                times: res.data.remaining_times

    start: ->
        webapi.lottery.draw(@props.id).then (res) =>
            if res.code is 0
                @setState
                    result: res.data
                    times: res.data.remaining_times
            else
                @setState
                    result: null
                SP.notice.error res.msg

    callback: ->
        result = @state.result
        type = result.prize_type
        showResult result
        @setState
            result: null

    login: ->
        SP.login ->
            window.location.reload()

    render: ->
        lottery = @state.lottery;
        begin = lottery.begin_at and DATE.gt lottery.begin_at
        end = lottery.end_at and DATE.lt lottery.end_at
        prizeList = lottery.prizes
        result_id = if @state.result isnt null then @state.result.prize_id else -1

        getRule = =>
            return __html: @state.lottery.rule

        return (
            <div className="lottery">
                <h2 className="u-mb_10">你目前拥有<em>{@state.times}</em>次抽奖机会，大奖在等你哟！</h2>

                <Marquee
                    data={prizeList}
                    begin={begin}
                    end={end}
                    times={@state.times}
                    result={result_id}
                    start={@start}
                    callback={@callback}
                    isLogin={SP.isLogined()}
                    login={@login} />

                <h2 className="u-mt_10"><span>抽奖规则</span></h2>
                <p dangerouslySetInnerHTML={getRule()}></p>
            </div>
        )

module.exports = Lottery
