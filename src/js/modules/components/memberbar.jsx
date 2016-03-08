define([],function(){

    /**
     * 顶部用户状态组件
     */
    var Memberbar = React.createClass({
        getInitialState: function(){
            return {
                member: SP.member
            };
        },
        componentDidMount:function(){
            var _this = this;
            var member = this.state.member;
            SP.on(SP.events.member_update,function(e, data){
                member.name = data.name;
                _this.setState({
                    member: member
                });
            });
        },
        componentWillUnmount: function() {
            SP.off(SP.events.member_update);
        },
        render: function(){
            var self = this;
            var page_url = location.pathname;
            var login_url = '/member/login?redirect=' + page_url;
            var node = <span></span>;

            if (SP.isLogined()) {
                node =
                    <ul className="header-memberbar">
                        <li><a href="/member" className="user-name">{self.state.member.name}</a></li>
                        <li><a href="/member/logout">退出</a></li>
                        <li><span className="divider"></span></li>
                    </ul>;
            }
            else {
                node =
                    <ul className="header-memberbar">
                        <li><a className="j-login" href={login_url}>登录</a></li>
                        <li><a href="/member/register">注册</a></li>
                        <li><span className="divider"></span></li>
                    </ul>;
            }

            return node;
        }
    });

    /**
     * 返回参数
     */
    return Memberbar;

});
