# 验证邮箱页面逻辑
define [], ()->
    # 获取邮箱验证码
    $(document).on "click",".j-resend-mail",->
        email = $(this).data 'email'
        SP.post SP.config.host + '/api/member/sendMail', {
            email: email,
            type: 0
        },(res)->
            if(res && res.code == 0)
                SP.notice.success "验证邮件发送成功"
            else
                SP.notice.error "邮箱发送验证失败"

        return false
