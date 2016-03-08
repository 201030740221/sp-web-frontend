import captchaModal from 'modules/captcha-modal/captcha-modal'
export default class SmsNotice extends React.Component {
    // getSmsCode() {
    //     $("#mobile-error").html('');
    //     $("#sms_code-error").html('');
    //
    //     let val = $('#sms-code-input').val();
    //     if(/^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$/.test(val)){
    //
    //     }else{
    //         $("#mobile-error").html('请输入正确的手机号码');
    //     }
    // }
    componentDidMount() {
        $('#mobile-input').on('focus', function(){
            $('#mobile-error').val('');
        });

    }
    postSmsCode(sceneId) {
        $("#mobile-error").html('');

        let mobile = $('#mobile-input').val();
        if(/^(0|86|17951)?(13[0-9]|15[012356789]|17[0678]|18[0-9]|14[57])[0-9]{8}$/.test(mobile)){
            var captcha_modal = captchaModal(function(captcha, $error){

                webapi.activity.reminderNoLogin({
                    type: 6,
                    target:mobile,
                    captcha: captcha,
                    requester_id: sceneId
                }).then(function(res1){
                    if(res1 && !res1.code){
                        SP.notice.success('设置成功');
                        $('#modal-mask').remove();
                        $('.modal').remove();
                        $('.ui-modal').remove();
                    }else{
                        SP.notice.success('你已经设置过提醒，请勿重复设置');
                        $('#modal-mask').remove();
                        $('.modal').remove();
                        $('.ui-modal').remove();
                    }
                });

            }, function(){
                $('#modal-mask').css({
                    zIndex: 99
                });
                $('.modal').css({
                    zIndex: 99
                });
            });
        }else{
            $("#mobile-error").show().html('请输入正确的手机号码');
        }


    }
    render() {
        return (
            <div className="ui-modal__box prize-info-modal">
                <div className="ui-modal__title">
                    游戏短信提醒
                </div>
                <div className="common-modal-box__content ui-modal__inner u-clearfix">
                    <form className="common-form common-form-nolabel change-mobile-form">
                        <div className="sms-notice-tips">
                            我们将会在游戏场景开放前10分钟以短信的形式通知您
                        </div>
                        <div className="row">
                            <input id="mobile-input" className="mobilephone full-width" type="text" name="mobile" placeholder="请输入手机号码" />
                            <p id="mobile-error" className="error"></p>
                        </div>

                        <div className="row">
                            <a className="btn btn-confirm" href="javascript:;" onClick={this.postSmsCode.bind(this, this.props.sceneId)}>提交信息</a>
                        </div>
                    </form>
                </div>
            </div>
        )
    }
}
