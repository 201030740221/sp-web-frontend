define(['Validator','cookie'],function(Validator,cookie){

    var ReactCheckbox = require('widgets/react-checkbox/react-checkbox');
    var Input = require('modules/components/input');
    var PASSWORD_WRONG_TEXT = '帐号或者密码不正确，请检查重试!';

    /**
     * 登录页组件
     */
    var validator = new Validator();
    var classSet = SP.classSet;

    // 获取search字串
    var searchVar = location.search.length?location.search:'';
    searchVar = searchVar.substr(1);
    var searchVarArr = searchVar.split('&');
    var searchObj = {};
    for(var i = 0; i< searchVarArr.length; i++){
        var tmp = searchVarArr[i].split("=");
        searchObj[tmp[0]] = decodeURIComponent(tmp[1]);
    }

    var timer = null;

    var Loginbox = React.createClass({
        getInitialState: function(){
            return {
                account: {
                    val: $.cookie('sipin_member_name') || '',
                    error: true,
                    info:"",
                    isChecked: false,
                    _val:''
                },
                password: {
                    val: '',
                    error: true,
                    info:"",
                    isChecked: false,
                    _val:''
                },
                submit_active: false,
                remember: false
            };
        },
        validAccount: function(){
            var state = this.state;
            if(state.account.val.length){
                if(validator.methods.username(state.account.val)){  // 如果是用户名
                    state.account.error = false;
                    state.account.info = "";
                }else if(validator.methods.email(state.account.val)){  // 如果是邮箱
                    state.account.error = false;
                    state.account.info = "";
                }else if(state.account.val.length===11 && validator.methods.phone(state.account.val)){ // 如果是手机
                    state.account.error = false;
                    state.account.info = "";
                }else{
                    state.account.error = true;
                    state.account.info = "请输入正确的帐号";
                }
                this.setState(state);
            }

        },
        validPassword: function(){
            var state = this.state;
            if(state.password.val.length>0){
                // 正则检查
                if(!validator.methods.password(state.password.val)){
                    state.password.error = true;
                    state.password.info = '请输入正确的密码';
                }else{
                    state.password.error = false;
                    state.password.info = '';
                }
            }
            this.setState(state);
        },
        componentDidMount: function(){

             var self = this,
                 state = this.state,
                 $account = $("#account"),
                 $password = $("#password");

             if($.cookie('sipin_member_name')){
                 $account.val($.cookie('sipin_member_name'));
                 state.account.val = $.cookie('sipin_member_name');
                 if(state.account.val.length>=4){
                     state.account.error = false;
                     state.account.info = "";
                 }
                 self.setState(state);
                 $password.val("");
             }

             totalTimer = 2000;
             timer = setInterval(function(){

                if(totalTimer>0){
                    totalTimer = totalTimer -250;
                }else{
                    clearInterval(timer);
                }

                state = self.state;

                var account = $account.val();
                account = typeof(account) === 'string' && account.length ? account.trim() : null;
                var password = $password.val() || null;

                if( account && account.length && password && password.length){
                    state.account.val = account;
                    state.password.val = password;

                    if(account.length>=4 && password.length>=6){
                        state.account.error = false;
                        state.account.info = "";
                        state.password.error = false;
                        state.password.info = '';
                    }

                    self.setState(state);
                    clearInterval(timer);
                }

            },250);

            // 输入框获得焦点时，清除提示信息
            $account.add($password).on('focus', function(){
              state.account.info = "";
              self.setState(state);
            });

            this.setState(state);
            this.validAccount();

         },
         componentWillUnmount: function(){
             clearInterval(timer);
         },
         checkEnter: function(e){
             if(e.keyCode==13){
                 this.login(e);
             }
         },
         checkAccount: function(e){
            e.preventDefault();
            e.stopPropagation();

            clearInterval(timer);
            var value = e.target.value;
            var state = this.state;
            state.account.val = value.trim();
            // 用户名长度是否正确
            if(state.account.val.length>=4){
                state.account.error = false;
                state.account.info = "";
            }else{
                state.account.error = true;
                state.account.info = "";
            }
            this.setState(state);

        },
        checkPass: function(e){
            e.preventDefault();
            e.stopPropagation();
            clearInterval(timer);

            var state = this.state;
            state.password.val = e.target.value;
            // 密码长度是否正确
            if(state.password.val.length>=6){
                state.password.error = false;
                state.password.info = '';
            }else{
                state.password.error = true;
                state.password.info = '';
            }
            this.setState(state);
        },
        checkRemember: function(isChecked){
            var state = this.state;
            state.remember = isChecked;
            this.setState(state);
        },
        // 登录
        _loginSubmit: function(account,password,remember,callback){
            // TODO: 登录成功后需要加载到cookie里去
            // TODO: 需要把前一页的路由存到本地存储，做跳转
            webapi.member.login({
                account: account,
                password: password,
                remember: remember
            }).then(function(res){
                callback(res);
            });
        },
        _loginCheck: function(res,account,password,remember,callback){
            if(res && res.code !== 0){
                callback(false);
            }else{
                this._loginSubmit(account,password,remember,callback);
            }
        },
        _login: function(account,password,remember,callback){
            var self = this;
            var state = this.state;
            // 检查用户名是否存在
            if(validator.methods.username(account)){  // 如果是用户名
                webapi.member.checkName({
                    name: account
                }).then(function(res){
                    self._loginCheck(res,account,password,remember,callback);
                });
            }else if(validator.methods.email(account)){  // 如果是邮箱
                webapi.member.checkEmail({
                    email: account
                }).then(function(res){
                    self._loginCheck(res,account,password,remember,callback);
                });
            }else if(account.length===11 && validator.methods.phone(account)){ // 如果是手机
                webapi.member.checkMobile({
                    mobile: account
                }).then(function(res){
                    self._loginCheck(res,account,password,remember,callback);
                });
            }else{
                state.account.info = PASSWORD_WRONG_TEXT;
                self.setState(state);
            }
        },
        login: function(e){

            e.preventDefault();
            e.stopPropagation();

            var self = this;
            var state = this.state;
            if(!this.state.submit_active){
                // 检查是否存在
                this._login(state.account.val,state.password.val,state.remember ? 1 : 0,function(res){
                    //登录成功
                    if(res===false){
                        state.account.info = PASSWORD_WRONG_TEXT;
                    }else{
                        if(res&&res.code===0){

                            if(state.remember){
                                $.cookie('sipin_member_name',state.account.val);
                            }else{
                                $.removeCookie('sipin_member_name');
                            }

                            SP.setMember(res.data);

                            if(self.props.pageType == "pop"){
                                self.props.success(res.data);
                            }else{
                                // 登录成功跳转到首页
                                if(typeof searchObj.redirect !=="undefined")
                                    window.location.href = searchObj.redirect;
                                else
                                    window.location.href = "/";
                            }
                        }else{
                            if(res&&res.code==1&&res.data.status===0){
                                var _info = function(){
                                    return(
                                        <span>此帐号尚未激活，请<a target="_blank" href={res.data.url}>马上激活</a></span>
                                    );
                                };
                                state.account.info = _info();
                            }else{
                                // 提示错误信息
                                state.account.info = PASSWORD_WRONG_TEXT;
                            }
                        }
                    }

                    self.setState(state);

                });
            }

        },
        getLoginBtnClass: function(){

            var state = this.state,
                active = true;

            if(!state.account.error && !state.password.error){
                active = false;
            }

            return classSet({
                'j-login-submit': true,
                'formbtn': true,
                'btn-primary': true,
                '_disable': active
            });
        },
        renderModal: function(){
            return (
                <form method="post" action="" className="form">
                    <div className="form-item">
                        <div className="form-field">
                            <Input id="account" onKeyUp={this.checkEnter} onChange={this.checkAccount} type="text" className="form-text j-login-username" name="username" placeholder="手机号/邮箱/用户名" />
                        </div>
                        <div className="login-modal-box__error _username j-error-username u-color_red">{this.state.account.info}</div>
                    </div>
                    <div className="form-item">
                        <div className="form-field">
                            <Input id="password" onKeyUp={this.checkEnter} onChange={this.checkPass} type="password" className="form-text j-login-password" name="password" placeholder="密码" />
                        </div>
                        <div className="login-modal-box__error _password j-error-password u-color_red">{this.state.password.info}</div>
                    </div>
                    <div className="form-item">
                        <div className="form-field form-field-rc u-clearfix">
                            <ReactCheckbox checked={this.state.remember} onChange={this.checkRemember} label='记住用户名' />
                            <a className="forget-link u-fr u-color_black" href="/member/forgotPass">忘记密码？</a>
                        </div>
                    </div>
                    <div className="form-action action-left u-mt_30">
                        <a onClick={this.login} className={this.getLoginBtnClass()} href="#">登录</a>
                    </div>
                    <div className="form-action action-left u-mt_20">
                        还不是斯品用户？<a className="btn-right" href="/member/register">马上注册》</a>
                    </div>
                </form>
            )
        },
        renderPage: function(){
            return (
                <form method="post" action="#" className="form">
                    <div className="form-item">
                        <div className="form-field">
                            <Input id="account" onKeyUp={this.checkEnter} onChange={this.checkAccount} type="text" className="form-text" name="username" placeholder="手机号/邮箱/用户名" />
                        </div>
                        <p className="u-color_white is_account_error u-mt_10 _tips_p" style={{display:"block"}}>{this.state.account.info}</p>
                    </div>
                    <div className="form-item u-mt_30">
                        <div className="form-field">
                            <Input id="password" onKeyUp={this.checkEnter} onChange={this.checkPass} type="password" className="form-text" name="password" placeholder="密码" />
                        </div>
                        <p className="u-color_white is_password_error u-mt_10 _tips_p" style={{display:"block"}}>{this.state.password.info}</p>
                    </div>
                    <div className="form-item u-mt_15">
                        <div className="form-field form-field-rc u-clearfix">
                            <label className="u-fl">
                                <ReactCheckbox checked={this.state.remember} onChange={this.checkRemember} label='记住用户名' />
                            </label>
                            <a className="forget-link u-fr u-color_white" href="/member/forgotPass">忘记密码？</a>
                        </div>
                    </div>
                    <div className="form-action action-left u-mt_30">
                        <a onClick={this.login} className={this.getLoginBtnClass()} href="#">登录</a>
                    </div>
                    <div className="form-action action-left u-mt_20">
                        还不是斯品用户？<a className="btn-right" href="/member/register">马上注册》</a>
                    </div>
                </form>
            );
        },
        render: function(){
            if(this.props.pageType == "pop"){
                return this.renderModal();
            }else{
                return this.renderPage();
            }

        }
    });

    /**
     * 返回参数
     */
    return Loginbox;

});
