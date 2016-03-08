var modalTpl = require('./jquery.modal.hbs')
,   maskDom = '<div id="modal-mask" class="modal-mask"></div>'

,   eventClick = 'click.modal'
,   eventClose = 'close.modal'
,   $body = $('body')
,   $doc = $(document)
,   $win = $(window)
,   maskCount = 0; // 记录打开的modal数，当最后一个modal关闭才关闭mask

function Modal(options) {
    var _this = this;
    this.options = $.extend({
        title: null,
        content: '',
        footer: null,

        top: null,
        width: 460,
        closeBtn: true,
        mask: true,
        maskClose: true,

        onshow: function (){},
        onclose: function (){}
    }, options);

    var $modal = $(modalTpl(this.options))
    ,   $mask = $('#modal-mask');

    if (!$mask.length) {
        $body.append(maskDom);
        $mask = $('#modal-mask');
    }

    this.$modal = $modal;
    this.$mask = $mask;

    $modal.on(eventClick, '.modal-close', function () {
        _this.close();
    });

    if (this.options.maskClose) {
        $mask.on(eventClick, function () {
            _this.close();
        });
    }

    $body.append($modal);
}

Modal.prototype.show = function () {
    this.mask();
    this.$modal.show();

    this.options.onshow.call(this, this.$modal);

    this.setPos();
}

Modal.prototype.close = function () {
    this.$modal.hide();
    this.mask(false);

    this.options.onclose.call(this, this.$modal);
}

Modal.prototype.remove = function () {
    this.close();
    this.$modal.remove();
}
// 遮罩，支持多个modal同时打开与关闭
Modal.prototype.mask = function (show) {
    show = show !== false;

    if (!this.options.mask) {
        return;
    }

    if (show) {
        this.$mask.show();
        maskCount ++;

        return;
    }

    maskCount --;
    if (maskCount <= 0) {
        this.$mask.hide();
        maskCount = 0;
    }
}

Modal.prototype.update = function(options) {
    options.title && this.$modal.find('.modal-title').html(options.title);
    options.content && this.$modal.find('.modal-body').html(options.content);
}

Modal.prototype.setPos = function () {
    var posCss = {
        top: this.options.top
    }
    // 若指定了top，则使用指定top
    if (posCss.top !== null) {
        this.$modal.css(posCss);
        return;
    }

    // 未指定top，则计算位置，垂直居中
    var modalH = this.$modal.height()
    ,   winH = $win.height();

    // 内容比窗口高，则使用absolute定位
    if (winH < modalH) {
        this.$modal.addClass('moveable');
        posCss.top = 20;
    } else {
        posCss.top = (winH - modalH) / 2;
    }
    this.$modal.css(posCss);
}
// 事件委托封装
Modal.prototype.on = function() {
    this.$modal.on.apply(this.$modal, arguments);
};
Modal.prototype.off = function() {
    this.$modal.off.apply(this.$modal, arguments);
};
Modal.prototype.trigger = function() {
    this.$modal.trigger.apply(this.$modal, arguments);
};

Modal.prototype.getContainer = function() {
    return this.$modal;
};

$.Modal = function (options) {
    var modal = new Modal(options);
    
    if (options.autoShow !== false) {
        modal.show();
    }

    return modal;
}

module.exports = Modal;