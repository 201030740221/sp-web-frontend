# 商品详情页面逻辑

define ['SelectBox','./phone_tpl.hbs','./email_tpl.hbs','./email_complete_tpl.hbs','Validator', 'modules/check-password-strength/index'], ( SelectBox, phone_tpl, email_tpl, email_complete_tpl, Validator, checkPasswordStrength )->

    captchaModal = require 'modules/captcha-modal/captcha-modal'
    validator = new Validator()
    success_text = '<span class="form-success-tips u-ml_5 iconfont u-color_green">&#xe615;</span>'

    page = ->

    page.step1 = () ->

        validatored = {}
        validatored.account = false
        validatored.code = false

        $step1_submit = $(".j-step1-formbtn").on "click",->
            if $(this).hasClass("_disable")
                return

        checkSetp1 = ->
            #console.log validatored.account, validatored.code
            if validatored.account and validatored.code
                $step1_submit.removeClass("_disable").removeAttr("disabled")
            else
                $step1_submit.addClass("_disable").attr("disabled","disabled")

        account_error = ->
            $(".is_account_error").show().html "该账号不存在，请检查后再尝试!"
            validatored.account = false
            checkSetp1()

        account_success = ->
            $(".is_account_error").hide()
            validatored.account = true
            checkSetp1()

        code_error = (msg)->
            msg = msg or "请输入正确的图形验证码"
            $(".is_captcha_error").show().html msg
            validatored.code = false
            checkSetp1()

        code_success = ->
            $(".is_captcha_error").hide()
            validatored.code = true
            checkSetp1()

        $("input[name='account']").on "keyup paste",->
            self = this
            account = $(this).val()
            account = $.trim(account)

            if(!account)
                validatored.account = false
                checkSetp1()

        $("input[name='account']").on "blur",->
            self = this
            account = $(this).val()
            account = $.trim(account)

            if validator.methods.email(account)
                params =
                    email: account
                url = "checkEmail"
            else if validator.methods.phone(account)
                params =
                    mobile: account
                url = "checkMobile"
            else
                params =
                    name: account
                url = "checkName"

            SP.post SP.config.host + '/api/member/' + url, params, (res)->
                if res && res.code == 0
                    account_success()
                else
                    account_error()


        # 输入验证码
        issend = false
        $(".text-captcha").on "keyup", (e)->
            # 判断输入是数字或字母
            # http://blog.dodozhu.com/html/315.html
            if e.keyCode < 47 or e.keyCode > 90
                return

            if issend
                code_error "正在验证中..."
                return false

            code_length = $.trim($(this).val()).length

            if code_length == 5
                data =
                    captcha: $(this).val()

                issend = true
                webapi.member.checkCaptcha data
                .then (res)->
                    issend = false

                    if res and res.code ==0
                        code_success()
                    else
                        code_error()

            else if code_length > 5
                code_error "图形验证码长度不对"

        .on 'focus', ->
            $(".is_captcha_error").hide()

        .on 'blur', ->
            if $.trim($(this).val()).length != 5
                code_error "图形验证码长度不对"


    page.step2 = ()->
        $form = $ '#j-setp2-form'
        account_info =
            name: $form.data 'name'
            email: $form.data 'email'
            mobile: $form.data 'mobile'
            email_url: $form.data 'url'

        time = 0
        timer = null

        validatored = {}
        validatored.phonecode = false

        checkSetp2 = ->
            if validatored.phonecode
                $("#j-phone-next").removeClass("_disable").removeAttr("disabled")
            else
                $("#j-phone-next").addClass("_disable").attr("disabled","disabled")

        code_error = ->
            $(".text-verifyphonecode").siblings(".form-success-tips").remove()
            $(".is_code_error").show().html "请输入正确的短信验证码"
            validatored.phonecode = false
            checkSetp2()

        code_success = ->
            if !$(".text-verifyphonecode").siblings(".form-success-tips").length
                $(".text-verifyphonecode").after success_text
            $(".is_code_error").hide()
            $(".form-verifycode").hide()
            validatored.phonecode = true
            checkSetp2()

        render = (type)->
            if (type == "email")
                tpl = email_tpl(account_info)
            else if(type=="phone")
                tpl = phone_tpl(account_info)
            else tpl = "<p>手机或邮箱没有通过验证</p>"

            $(".validate_forgetpass_box").html(tpl)

        $('#j-select-validate').selectBox
            callback: (type,text)->
                render(type)

        # 初始化
        if($('#j-select-validate').length)
            type = $('#j-select-validate')[0]._selectBox.value
            render(type)

        $(document).on "click", ".form-verifycode .btn", ->
            if $(this).hasClass '_disable' or !validatored.code
                return;


            modal = captchaModal (captcha, $error)->
                webapi.member.sendSms
                    type: 4
                    captcha: captcha
                .then (res)->
                    if(res && res.code == 0 )
                        if(!time)
                            $(".form-verifycode .btn").html '<span class="u-color_darkred u-fl">120</span> <span class="u-color_black">秒后重新获取</span>'
                            $(".form-verifycode .btn").addClass "_disable"
                            _timerFn()

                        modal.remove()
                    else
                        $error.show().html res.msg
                return false

        _timerFn = =>
            time = 120
            timer = setInterval =>
                if(time<=1)
                    clearInterval timer
                    #$(".form-regetcode").hide();
                    $(".form-verifycode .btn").removeClass "_disable"
                    $(".form-verifycode .btn").html("重新获取验证码")

                timeElement = $(".form-verifycode").find(".u-color_darkred")
                timeElement.text --time
            ,1000

        # 验证手机验证码
        $(document).off('verifyphonecode').on "keyup.verifyphonecode blur.verifyphonecode paste.verifyphonecode", ".text-verifyphonecode", (e)->
            $this = $ this
            # 判断输入是数字或字母
            # http://blog.dodozhu.com/html/315.html
            if e.keyCode < 47 or e.keyCode > 91
                return

            code = $.trim $this.val()

            if code.length == 6
                data = {}
                data['sms_code'] = code
                data.type = 4

                webapi.member.checkSms data
                .then (res)->
                    if res and res.code ==0
                        code_success()
                        $("input[name='sms_code']").val code
                        $this.attr 'readonly', 'readonly'
                    else
                        code_error()

            else if code.length > 6
                code_error()

        $(document).on "click","#j-phone-next", ->
            $("#j-setp2-form").submit()
            return false

        # 获取邮箱验证码
        email_url = $("input[name=account]").val()
        $(document).on "click",".j-forgetpass-next",->
            SP.post SP.config.host + '/api/member/sendMailWithAccount', {
                type: 3
            },(res)->
                if(res && res.code == 0)
                    tpl = email_complete_tpl(account_info)
                    $(".getbackpassword-box__content").html(tpl)
                else
                    SP.notice.error "邮件发送失败，请稍后再试"

            return false

    page.step3 = (data) ->
        checkStrong = checkPasswordStrength

        validatored =
            password: false
            repassword: false


        $submit = $("#j-submit");
        $submit.on 'click', (e) ->
            e.preventDefault()
            e.stopPropagation()
            if $submit.hasClass '_disable' or !validatored.password or !validatored.repassword
                console.log 'no submit'
                return false
            else
                console.log 'go submit'
                $('form').submit();

        checkOK = ->
            if validatored.password and validatored.repassword
                $submit.removeClass("_disable")
            else
                $submit.addClass("_disable")


        strongStr = ["弱", "弱", "弱", "中", "强", "非常好"]
        # 密码验证
        $("input[name='password']").on "keyup focus",->
            password = $(this).val()
            password = $.trim(password)

            if password.length == 0
                $(".is_password_tips").show().text "6-20位字符，建议使用字母加数字或者符号组合"
                $(".is_password_error").hide()
            else
                $(".is_password_tips").hide()

        $("input[name='password']").on "keyup blur",->
            value = $(this).val()
            value = $.trim value
            strong = checkStrong value
            $(".ui-strength")
            .removeClass("_level-00")
            .removeClass("_level-01")
            .removeClass("_level-02")
            .removeClass("_level-03")
            .removeClass("_level-04")
            .removeClass("_level-05")
            .addClass("ui-strength")
            .addClass("_level-0"+strong)

            $("#pass_strong").text "强度:"+ strongStr[strong]

            if value.length >0
                $(".ui-pass-strong").show()
            else
                $(".ui-pass-strong").hide()

            if value.length > 5 and value.length <= 20
                $(".is_password_error").hide()
                validatored.password = true
            else
                $(this).siblings(".form-success-tips").remove()
                if value.length !=0
                    $(".is_password_error").show().text "密码长度应是6-20位字符"
                validatored.password = false

            checkOK()

        $("input[name='password']").on "blur",->
            #确认密码状态
            if ($("input[name='password_confirmation']").val()).length==0 and validatored.password == true
                $(".is_repassword_error").show().text "请确认密码"

        # 密码再次验证
        $("input[name='password_confirmation']").on "keyup focus",->
            repassword = $(this).val()
            repassword = $.trim(repassword)

            if repassword.length == 0
                $(".is_repassword_tips").show().text "请再次输入密码，确保两次输入一致"
                $(".is_repassword_error").hide()
            else
                $(".is_repassword_tips").hide()


        $("input[name='password_confirmation']").on "focus keyup blur",->
            if $(this).val().length > 5 and $(this).val().length <= 20
                if $(this).val() == $("input[name='password']").val()
                    #显示正确标识
                    if !$(this).siblings(".form-success-tips").length
                        $(this).after success_text
                    $(".is_repassword_error").hide()
                    validatored.repassword = true
                else
                    $(this).siblings(".form-success-tips").remove()
                    $(".is_repassword_error").show().text "两次输入密码不一致"
                    validatored.repassword = false
            else if $(this).val().length == 0
                $(this).siblings(".form-success-tips").remove()
                $(".is_repassword_error").hide()
                validatored.repassword = false
            else
                $(this).siblings(".form-success-tips").remove()
                $(".is_repassword_error").show().text "密码长度应是6-20位字符"
                validatored.repassword = false
            checkOK()

    # 初始化页面
    page.init = ->
        # 第一步
        if $(".ui-progress__bar._step-1").length
            page.step1()

        # 第二步
        if $(".ui-progress__bar._step-2").length
            page.step2()

        # 第3步
        if $(".ui-progress__bar._step-3").length
            page.step3()
            console.log '第3步'

    page.init()
