# register
define ['Validator','modules/check-password-strength/index','agreementModalBox', 'plugins'], (Validator,checkPasswordStrength,AgreementModalBox)->
    require 'modules/plugins/jquery.form'

    captchaModal = require 'modules/captcha-modal/captcha-modal'

    validator = new Validator()
    success_text = '<span class="form-success-tips u-ml_5 iconfont u-color_green">&#xe615;</span>'

    old_account = ''

    validatored =
        account: false
        code: true
        phonecode: false
        password: false
        repassword: false
        readed: true

    checkOK = ->
        if validatored.account and validatored.phonecode and validatored.password and validatored.repassword and validatored.readed
            $(".j-register-btn").enable()
        else
            $(".j-register-btn").disable()

    page = ->

    page.init = ->
        # 注册时手机、邮箱判断
        verifycode();
        $(".form-verifycode .btn").disable()

    checkStrong = checkPasswordStrength

    timer = null
    time = 120
    #获取手机验证码
    verifycode = ->
        time = 0
        _timerFn = =>
            time = 120
            timer = setInterval =>
                if(time<=1)
                    clearInterval timer
                    $(".form-verifycode .btn").enable "重新获取验证码"
                    
                timeElement = $(".form-verifycode").find(".u-color_darkred")
                timeElement.text --time
            ,1000
        $(".form-verifycode .btn").on "click",->
            if $(this).isDisabled()
                return

            modal = captchaModal (captcha, $error)->
                data = {}
                data.captcha = captcha
                data.mobile = $(".register-box input[name='account']").val()
                data.type = 0
                
                webapi.member.sendSms data
                .then (res)->
                    if res and res.code ==0
                        # $("#reg-captcha").hide()
                        # $("#phone-code-box").show()
                        $(".text-verifycode").focus()
                        if(!time)
                            #$("#j-phone-verify-time").text "该手机还有还可获取2次验证码，请尽快完成验证"
                            $(".form-verifycode .btn").disable '<span class="u-color_darkred u-fl">120</span> <span class="u-color_black">秒后重新获取</span>'
                            _timerFn()
                        validatored.code = true

                        modal.remove()
                    else
                        $error.show().html res.msg

                    return false

        # 快捷登录
        loginBox = null
        $(document).on "click",".j-quick-login", ->
            SP.login ->
                window.location.href = "/"


        # 显示手机验证码
        $("input[name='account']").on "focus",->

            $(".is_account_error").hide()
            $(".is_account_tips").show().text "请输入11位手机号"

            checkOK()
            return false


        $("input[name='account']").on "blur",->

            self = this
            account = $(this).val()
            account = $.trim(account)

            complete = (that)->
                if !$(that).siblings(".form-success-tips").length
                    $(that).after success_text
                $(".is_account_error").hide().text ""
                validatored.account = true
                $(".form-verifycode .btn").enable()
            
                checkOK()

            error = (that)->
                $(that).siblings(".form-success-tips").remove()
                $("#reg-captcha").hide()
                # $("#phone-code-box").hide()
                validatored.account = false
                $(".form-verifycode .btn").disable()

            $(".is_account_tips").hide()

            if validator.methods.phone(account)

                webapi.member.checkMobile
                    mobile: account
                .then (res)->
                    if res && res.code == 0
                        if parseInt(res.data.status) == 1
                            $(".is_account_error").show().html "该账号已经存在，请马上<a class='j-quick-login' href='#'>登录</a>"
                        else
                            $(".is_account_error").show().html "该账号已经存在，尚未激活"
                    else
                        old_account = account
                        complete self
              
            else if account.length
                $(".is_account_error").show().text "请输入正确的手机号"
                error self

            checkOK()
            return false

        # 验证手机验证码
        ischeck = false
        $(".text-verifycode").on "keyup blur",->
            that = this
            val = $.trim($(this).val())

            if  !ischeck and val.length == 6
                data = {}
                data['sms_code'] = $(".register-box input[name='sms_code']").val()
                data.mobile = $(".register-box input[name='account']").val()
                #$(".register-box input[name='account']").attr("disable")
                data.type = 0
                ischeck = true
                
                webapi.member.checkSms data
                .then (res)->
                    if res and res.code ==0
                        #显示正确标识 todo
                        if !$(that).siblings(".form-success-tips").length
                            $(that).after success_text
                        $(".is_verify_error").hide().text ""
                        $(".form-verifycode").hide()
                        $(".text-verifycode").attr("disabled","disabled");
                        validatored.phonecode = true
                    else
                        $(".is_verify_error").show().text "请输入正确的短信验证码"
                        validatored.phonecode = false
                    checkOK()
            else if val.length && val.length != 6
                ischeck = false
                $(".is_verify_error").show().text "验证码长度不正确"
                validatored.phonecode = false
           
            checkOK()

        strongStr = ["弱", "弱", "弱", "中", "强", "非常好"]


        $("input[name='password']").on "focus",->
            $(".is_password_tips").show().text "6-20位字符，建议使用字母加数字或者符号组合"
            $(".is_password_error").hide()

        $("input[name='password']").on "blur",->

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

            $(".is_password_tips").hide()
            $("#pass_strong").text "强度:"+ strongStr[strong]

            if value.length >0
                $(".ui-pass-strong").show()
            else
                $(".ui-pass-strong").hide()

            if value.length > 5 and value.length <= 20
                $(".is_password_error").hide()
                validatored.password = true
                repasswordInput = $("input[name='password_confirmation']")
                repassword_val = repasswordInput.val()
                #确认密码状态
                if repassword_val.length!=0 and validatored.password == true
                    if repassword_val == value
                        #显示正确标识
                        if !repasswordInput.siblings(".form-success-tips").length
                            repasswordInput.after success_text
                        $(".is_repassword_error").hide()
                        validatored.repassword = true
                    else
                        repasswordInput.siblings(".form-success-tips").remove()
                        $(".is_repassword_error").show().text "两次输入密码不一致"
                        validatored.repassword = false
            else
                $(this).siblings(".form-success-tips").remove()
                if value.length !=0
                    $(".is_password_error").show().text "密码长度应是6-20位字符"
                validatored.password = false

            checkOK()

        # 密码再次验证
        $("input[name='password_confirmation']").on "focus",->
            $(".is_repassword_tips").show().text "请再次输入密码，确保两次输入一致"
            $(".is_repassword_error").hide()


        $("input[name='password_confirmation']").on "blur",->
            $(".is_repassword_tips").hide()
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

        readed = ->
            validatored.readed = $(".agree-checked").prop( "checked" )
            checkOK()


        # 查看用户协议
        agreementBox = null
        $("#j-show-protocol").on "click",->
            AgreementModalBox()
            return false

        # 关闭用户协议
        $(document).on "click","#js-agreement",->
            if agreementBox
                agreementBox.modal.hide()
                $(".agree-checked").prop( "checked", true )
                readed()

        # 点击已阅用户协议
        $(".agree-checked").on "click", ->
            readed()
            return

        # 开始注册
        $(".j-register-btn").on "click",->
            $this = $(this)
            if $(this).isDisabled()
                return

            $form = $ '#register-form'

            data = $form.serializeMap()
                
            # data = SP.getQuery() # 获取一些url参数（比如一些跟踪代码），如果没有，则返回 {}
            # data['account'] = $(".register-box input[name='account']").val()
            # data['password'] = $(".register-box input[name='password']").val()
            # data['password_confirmation'] = $(".register-box input[name='password_confirmation']").val()
            # data['sms_code'] = $(".register-box input[name='sms_code']").val()
    
            $(this).disable "正在注册.."

            SP.post SP.config.host + "/api/member/register",data,(res)->
                if res && res.code == 0
                    setTimeout ->
                        window.location.href = res.data.url
                    , 300
                    # TODO need remove 99click method
                    try
                        tprm = "user_id=#{res.data.analytics_user_key}"
                        __ozfac2 tprm, "#regok"
                    catch e
                        # ...

                else
                    SP.log res
                    errors = res.data.errors
                    msgs = []

                    for name, value of errors
                        msgs.push value

                    if msgs.length
                        SP.alert msgs.join ''
                    
                    $this.enable "注册"
            return false


    page.init()
