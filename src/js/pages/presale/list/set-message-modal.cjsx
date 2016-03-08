React = require 'react'
liteFlux = require 'lite-flux'
storeName = 'set-message'
Store = require './_stores/set-message'
Action = Store.getAction()

View = React.createClass
    mixins: [liteFlux.mixins.storeMixin(storeName)]
    getInitialState: ->
        console.log 'his'
        Action.reset()
        {}
    componentDidMount: ->

    componentWillUnmount: ->
        Action.reset()

    handleChagne: (e) ->
        el = e.target
        value = el.value
        name = el.name
        data = {}
        data[name] = value
        Action.onChange data

    handleBlur: (e) ->
        el = e.target
        value = el.value
        name = el.name
        Action.valid name
        return

    submit: (e) ->
        valid = Action.valid()
        Action.setMessageReminder @props.requesterid, @props.close if valid


    # sendCode: (e) ->
    #     if store.canSendCode
    #         Action.sendCode()
    #     else
    #         console.log ''

    getCaptcha: ->
        # @refs['captcha-img'].src = '/api/captcha?' + Math.random()
        Action.onChange
            random: Math.random()
    render: ->
        store = @state[storeName]
        console.log store
        console.log @props
        error = store.fieldError
        className =
            sendCodeBtn: SP.classSet
                "btn btn-primary get-sms-code u-fr": yes,
                "_disable": not store.canSendCode

        # <div className="row">
        #     <input type="text" name="code" size="6" placeholder="短信验证码" value={store.code} onChange={@handleChagne} onBlur={@handleBlur} />
        #     <a className={className.sendCodeBtn} onClick={@sendCode}>{if store.canSendCode is yes then '获取短信验证码' else '验证码已发送'}</a>
        #     <div className="u-color_red u-f12 u-mt_10">{if error.code then error.code[0] else ""}</div>
        # </div>
        <div className="ui-modal__box presales-set-message-modal">
            <div className="ui-modal__title  u-ml_20">
                预售商品开售提醒
            </div>
            <div className="common-modal-box__content ui-modal__inner u-clearfix">
                <div className="u-f18 u-mt_20  u-ml_20">下批销售我们将提前2个小时短信告知您</div>
                <form className="common-form common-form-nolabel change-mobile-form">
                    <div className="row">
                        <input className="mobilephone full-width" type="text" name="mobile" placeholder="手机号码" value={store.mobile} onChange={@handleChagne} onBlur={@handleBlur} />
                        <div className="u-color_red u-f12 u-mt_10">{if error.mobile then error.mobile[0] else ""}</div>
                    </div>
                    <div className="row">
                        <a className="u-fr">
                            <img className="captcha-image captcha-modal-updater" src="/api/captcha?#{store.random}" alt="点击刷新" onClick={@getCaptcha} ref="captcha-img" />
                        </a>
                        <input type="text" name="captcha" size="6" placeholder="图形验证码" value={store.captcha} onChange={@handleChagne} onBlur={@handleBlur} />
                        <div className="u-color_red u-f12 u-mt_10">{if error.captcha then error.captcha[0] else ""}</div>
                    </div>
                </form>
                <footer className="u-mt_10 u-ml_20">
                    <a href="javascript:;" className="btn btn-larger-big btn-color-red" onClick={@submit} >提交信息</a>
                </footer>
            </div>
        </div>

module.exports = View;
