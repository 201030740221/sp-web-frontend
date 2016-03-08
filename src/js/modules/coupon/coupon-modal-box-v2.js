var ModalBox = require('ModalBox');
var tpl = require('./tpl-coupon.hbs');

function Coupon(options) {
    options.template = tpl({});
    var _this = this;
    this.modal = new ModalBox(options);

    function _init() {
        _this.$btn = $('.coupon-modal-btn');
        _this.$ipt = $('.coupon-modal-input');
        _bindEvent();
    }

    function _bindEvent() {
        _this.$btn.on('click', function (e) {
            var value = _this.$ipt.val();
            webapi.coupon.activateCoupon({code: value})
                .then(function (res) {
                    var status = '';
                    var text = '';

                    switch (res.code) {
                        case 0:
                            status = 'success';
                            text = res.msg;
                            _this.modal.close();
                            break;
                        case 20002:
                            status = 'error';
                            text = res.data.errors.code[0];
                            break;
                        default :
                            status = 'error';
                            text = res.msg;
                    }

                    SP.notice[status](text);

                    if (res.code === 0 && typeof options.couponCodeCallback === 'function') {
                        options.couponCodeCallback(res);
                    }
                })
                .fail(function (res) {
                    SP.notice.error('请求失败～请稍后再试！')
                })
        })
    }

    _init();
    return this.modal;
}

module.exports = Coupon;
