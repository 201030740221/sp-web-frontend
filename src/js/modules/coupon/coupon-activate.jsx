
var couponActivate = React.createClass({
    getInitialState: function () {
        return {value: ''}
    },

    propTypes: {
        successCallback: React.PropTypes.func,
        failCallback: React.PropTypes.func
    },

    getDefaultProps: function () {
        return {
            type: '优惠券'
        }
    },

    handleChange: function (event) {
        this.setState({value: event.target.value});
    },

    handleSubmit: function () {
        var _this = this;
        webapi.coupon.activateCoupon({code: this.state.value})
            .then(function (res) {
                switch (res.code) {
                    case 0:
                        SP.notice.success(res.msg);
                        _this.props.successCallback();
                        break;
                    case 20002:
                        SP.notice.error(res.data.errors.code[0]);
                        _this.props.failCallback();
                        break;
                    default :
                        SP.notice.error(res.msg);
                }
            })
            .fail(function (res) {
                SP.notice.error('请求失败～请稍后再试！');
                _this.props.failCallback();
            })
    },

    render: function() {
        var value = this.state.value;
        return (
            <div className="coupon-activate u-clearfix">
                <label htmlFor="code-input" className="u-fl">有{this.props.type}兑换码？</label>
                <input className="form-text u-fl"
                       type="text"
                       name="code-input"
                       value={value}
                       onChange={this.handleChange}
                       placeholder="输入激活码"
                    />
                <button className="btn u-fl" onClick={this.handleSubmit}>激活{this.props.type}</button>
            </div>
        );
    }
});

module.exports = couponActivate;
