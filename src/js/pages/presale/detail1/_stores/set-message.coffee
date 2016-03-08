liteFlux = require 'lite-flux'

store = liteFlux.store "set-message",
    data:
        canSubmit: no
        canSendCode: yes
        mobile: ''
        captcha: ''
        fieldError: {}
        random: Math.random()

    actions:
        reset: () ->
            @setStore
                canSubmit: no
                canSendCode: yes
                mobile: ''
                captcha: ''
                fieldError: {}
                random: Math.random()

        onChange: (data) ->
            console.log data
            @setStore data

        # sendCode: () ->
        #     store = @getStore()
        #     @setStore
        #         canSendCode: no
        #     param =
        #         type: 3
        #         mobile: store.mobile
        #     webapi.member.sendSms2(param).then (res) =>
        #         console.log res
        #         if res.code is 0
        #             SP.notice '验证码已发送'
        #         else
        #             SP.notice res.msg
        #             @setStore
        #                 canSendCode: yes


        setMessageReminder: (requester_id, callback) ->
            store = @getStore()
            # param =
            #     type: 1
            #     target: store.mobile
            #     requester_id: requester_id
            #     sms_code: store.code
            # webapi.presales.setMessageReminder(param).then (res) =>
            #     if res.code is 0
            #         SP.notice '设置成功'
            #         callback() if typeof callback is 'function'
            #     else
            #         SP.notice res.msg
            #         @setStore
            #             canSendCode: yes
            webapi.presales.setMessageReminder(
                type: 1
                requester_id: requester_id
                target: store.mobile
                captcha: store.captcha
                # sms_code:
            ).then (res) =>
                @setStore
                    random: Math.random()
                if res and res.code is 0
                    callback() if typeof callback is 'function'
                    SP.notice.success '设置成功'
                else
                    SP.notice.error res.msg

Validator = liteFlux.validator
validatorData = Validator store,{
    'mobile':
        required: true
        phone: true
        message:
            required: "手机号码不能为空"
            phone: "请输入正确的手机号码"
    'captcha':
        required: true
        message:
            required: "验证码不能为空"
},{
    #oneError: true
}

store.addAction 'valid', (name)->
    validatorData.valid(name)

module.exports = store;
