# 个人信息
define ['./change-mobile.hbs', './change-email.hbs', './verify-email.hbs', 'SetPassWordModalBox','AddressList', 'validate', 'plugins'], (changeMobileTpl, changeEmailTpl, verifyEmailTpl, SetPassWordModalBox, AddressList)->
    captchaModal = require 'modules/captcha-modal/captcha-modal'

    page = ->

    # 初始化页面
    page.init = ->
        #验证邮箱
        # $('#j-verifyEmail-btn').on 'click', ->
        #     verifyEmail()
        # 设置邮箱
        $('#j-setEmail-btn').on 'click', ->
            changeEmail(true)
        # 更换邮箱
        $('#j-changeEmail-btn').on 'click', ->
            changeEmail()


        # 更改手机
        $('#j-changePhone-btn').on 'click', ->
            setPhone()
        # 设置手机
        $('#j-setPhone-btn').on 'click', ->
            setPhone(true)

        # 修改用户名
        modifyUserName()

        # 修改密码
        changePassword()

        new AddressList
            el:'#j-order-info-address'
            checkboxClick: false,
            callback: (value)->


    # 修改用户名
    modifyUserName = ()->

        $userNameBox = $ '#j-user-name-box'
        username = pageData.username.val

        # 取消操作
        usernameActionTpl = '<a href="javascript:;" id="j-submit-modify-user-name">修改</a><span class="u-color_gold u-ml_10 u-mr_10">|</span><a href="javascript:;" id="j-cancel-modify-user-name">取消</a>'

        editActionTpl = '<a href="javascript:;" id="j-modify-user-name">修改</a>'

        usernameFirst = '<span class="u-mr_20">'+username+'</span><span><i class="iconfont icon-tanhaotishi u-f14"></i>可以设置个性用户名作为账号登录斯品平台(<span class="u-color_red">只允许修改一次</span>)</span>'

        usernameSecond = '<span class="u-mr_20" id="j-show-username">'+username+'</span>'

        inputTpl = '<input id="j-user-name-ipt" type="text" placeholder="" class="form-text" value="'+username+'" name=""><p class="u-color_red is_name_error u-mt_5 _tips_p"></p>'


        $account_action_box = $ ".account_action_box"
        # 点击修改用户名
        $(document).on 'click','#j-modify-user-name',()->
            $account_action_box.html usernameActionTpl
            $userNameBox.html inputTpl
            $("#j-user-name-ipt").focus()
            return false

        # 取消修改
        $(document).on "click","#j-cancel-modify-user-name",->
            $account_action_box.html editActionTpl
            $userNameBox.html usernameFirst
            return false

        # 提交修改
        name_error = (msg)->
            $error = $(".is_name_error").text(msg)
            if msg then $error.show() else $error.hide()

        $(document).on "click","#j-submit-modify-user-name",->
            value = $.trim($("#j-user-name-ipt").val())
            name_error(false)

            # 规则验证，不能纯数字，只能由字母，数字，下划线，中划线组成
            if /^\d+$/.test value
                name_error('用户名不能为纯数字')
                return
            if !/^[a-zA-Z0-9_-]{4,20}$/.test(value)
                name_error('用户名只能使用字母、数字、下划线及中划线，长度为4-20个字符')
                return

            # 用户名是否存在
            webapi.member.checkName
                name:value
            .then (res)->
                if res and res.code ==0
                    name_error "用户名已存在"
                else
                    ## 调用修改用户名API
                    SP.post SP.config.host + "/api/member/changeName", {
                        name: value
                    },(res)->
                        if(res && res.code ==0)
                            $userNameBox.html usernameSecond
                            pageData.username.val = res.data.name
                            pageData.username.init = false
                            $("#j-show-username").text res.data.name
                            $account_action_box.html ''

                            SP.setMember res.data
                            SP.notice.success '用户名修改成功'
                        else

                            SP.notice.error '用户名修改失败'

            return false

    $.fn.waitTime = (options)->
        options = $.extend
            'time': 120
            'waitText': '{0}秒后重新发送'
            'endText': '重新发送验证码'
        , options

        formatString = (src)->
            args = Array.prototype.slice.call(arguments, 1)
            return src.replace /\{(\d+)\}/g, (m, i)->
                return args[i]

        oneSecond = 1000
        waitTime = options.time
        waitTimeId = null
        $this = this

        $this.disable formatString options.waitText, waitTime

        waitTimeId = setInterval ->
            waitTime -= 1

            if waitTime == 0
                $this.enable options.endText
                waitTime = options.time
                clearInterval waitTimeId
            else
                $this.html formatString options.waitText, waitTime
        , oneSecond

        return this

    # 设置手机
    setPhone = (isNew)->
        $mobileShow = $ '#j-show-phone'

        title = if isNew then '验证新手机' else '验证手机'
        modal = $.Modal
            title: title
            width: 400
            content: changeMobileTpl {'isNew': isNew, 'mobile': pageData.phone.val}

        $modal = modal.getContainer()
        $form = $modal.find '.change-mobile-form'
        validator = $form.validate()

        smsType =
            changeMobile: 5

        # 禁止提交表单
        $form.on 'submit', =>
          return false;

        modal.on 'click', '.btn-confirm', ->
            if !$form.valid()
                return false

            params = $form.serializeMap()
            # API验证旧手机号码
            if !isNew
                webapi.member.checkSms
                    mobile: params.mobile
                    sms_code: params.sms_code
                    type: smsType.changeMobile
                .then (res)->
                    if res.code isnt 0
                        validator.showErrors
                            'sms_code': '验证码错误'

                        return false
                    # 旧手机号通过验证，进入新号码设置
                    modal.remove()
                    setPhone(true)
                return

            # 新号码设置
            webapi.member.changeMobile params
            .then (res)->
                if res.code is 20002
                    validator.showErrors
                        'sms_code': '验证码错误'
                    return false

                if res.code is 0
                    SP.notice.success '更换手机成功'

                    $ '#user_phone'
                    .html params.mobile

                    modal.remove()

            return false

        modal.on 'click', '.get-sms-code', ->
            $this = $(this)

            if $this.isDisabled()
                return
            # 验证手机号
            if !validator.element('#change-mobile-input')
                return
            # 请求api发送sms, 并开始倒计时
            mobile = $form.serializeMap().mobile

            if !mobile
                validator.showErrors
                    'mobile': '请填写手机号'
                return

            webapi.member.checkMobile
                mobile: mobile
            .then (res)->
                # 新手机号已存在，则不发送sms
                if isNew and res.code is 0
                    validator.showErrors
                        'mobile': '该手机号码已被注册'
                    return false

                if res.code is 20002
                    validator.showErrors
                        'mobile': '请填写手机号'
                    return false

                modal.close()
                captcha_modal = captchaModal (captcha, $error)->
                    webapi.member.sendAuthSms
                        captcha: captcha
                        mobile: mobile
                        type: smsType.changeMobile
                    .then (res)->
                        if res.code is 0
                            $this.waitTime()

                            captcha_modal.remove()
                            modal.show()
                        else
                            $error.show().html res.msg
    # 验证邮箱
    verifyEmail = (data)->
        $.Modal
            title: '验证邮件'
            content: verifyEmailTpl data

    # 更改邮箱
    changeEmail = (isFirstBind) ->
        mobile = pageData.phone.val
        username = pageData.username.val
        title = if mobile then '验证手机' else '为了保障您的账户安全，请先绑定手机'
        if isFirstBind
            title = '绑定邮箱'

        modal = $.Modal
            title: title
            width: 400
            content: changeEmailTpl {mobile: mobile, isFirstBind: isFirstBind, username: username}

        $form = modal.getContainer().find 'form'
        validator = $form.validate()

        # 禁止回车提交表单
        $form.on 'submit', =>
          return false;

        # 验证邮箱
        modal.on 'click', '.btn-confirm', ->
            $this = $ @

            if $this.isDisabled() or !$form.valid()
                return false

            $this.disable()

            params = $form.serializeMap()

            if mobile
                delete params.mobile

            # 发送到api，api返回成功，则弹窗提示
            webapi.member.changeEmail params
            .then (res)->
                $this.enable()

                if res.code is 20002
                    modal.remove()
                    SP.alert '该邮箱已被绑定，请更换邮箱！'

                    return

                if res.code isnt 0
                    SP.alert res.msg
                    return false

                data = res.data or {}
                params.email_url = data.next || null

                modal.remove()
                verifyEmail params

        modal.on 'click', '.get-sms-code', ->
            $this = $(this)

            if $this.isDisabled()
                return

            params = $form.serializeMap()
            #21: 修改邮箱时绑定手机号, 22: 修改邮箱时验证手机号
            smsType = if mobile then 22 else 21
            # 请求api发送sms, 并开始倒计时
            isBindMobile = !mobile
            webapi.member.checkMobile
                mobile: mobile or params.mobile
            .then (res)->
                # 新手机号已存在，则不发送sms
                if isBindMobile and res.code is 0
                    validator.showErrors
                        'mobile': '该手机号码已被注册'
                    return false

                if res.code is 20002
                    validator.showErrors
                        'mobile': '请填写手机号'
                    return false

                modal.close()
                captcha_modal = captchaModal (captcha, $error)->
                    webapi.member.sendAuthSms
                        captcha: captcha
                        mobile: mobile or params.mobile
                        type: smsType
                    .then (res)->
                        if res.code is 0
                            $this.waitTime()

                            captcha_modal.remove()
                            modal.show()
                        else
                            $error.show().html res.msg

    # 修改密码
    changePassword = ()->
        $("#j-change-pw").on "click",->
            changePasswordModalBox = new SetPassWordModalBox
                success: (isSuccess)->
                    if isSuccess
                        SP.notice.success '修改密码成功'
                    else
                        SP.notice.error '修改密码失败'
            return false
    page.init()
