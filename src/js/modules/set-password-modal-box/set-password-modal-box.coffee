# 模态框
define ['./tpl-layout.hbs'], (setPassWordModalBox_tpl)->
    require 'modules/plugins/jquery.modal'

    class setPassWordModalBox
        constructor: (@options)->
            self = this
            @options.success = @options.success || ()->

            modal = $.Modal
                title: '修改登录密码'
                width: 400
                content: setPassWordModalBox_tpl()

            $modal = modal.getContainer()
            $tipError = $modal.find(".tips_error")

            modal.on 'click', ".btn-confirm", (e)->

                oldpassword = $modal.find("input[name='oldpassword']").val()
                newpassword = $modal.find("input[name='newpassword']").val()
                repassword = $modal.find("input[name='repassword']").val()

                if !oldpassword.length or !newpassword.length or !repassword.length
                    $tipError.html("密码不能为空").show()
                    return
                else if newpassword != repassword
                    $tipError.html("两次输入密码不一致").show()
                else if (newpassword.length<6 || newpassword.length>20)
                    $tipError.html("密码长度应在6-20位之间").show()
                else
                    $tipError.hide()

                    webapi.member.changePassword
                        old_password: oldpassword,
                        password: newpassword
                    .then (res)->
                        if(res && res.code ==0)
                            self.options.success true
                            modal.remove()
                        else
                            self.options.success false
                            $tipError.html(res.msg).show()


    return  setPassWordModalBox
