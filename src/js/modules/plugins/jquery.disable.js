/**
 * @author tofishes
 * @description 禁用，启用元素
 * @example
 * 1、$('.btn').disable().enable()
 * 2、$('.btn').disable('请求中...')
 * 3、$('.btn').disable({
 *        'text': '进行中...',
 *        'status': '_disable'     
 *    })
 */

var disabled = 'disabled';

$.fn.disable = function (options, enable) {
    if (options && options.substring) {
        options = {
            'text': options
        }
    }

    options = $.extend({
        'status': disabled,
        'text': null
    }, options);

    if (options.text !== null) {
        this.html(options.text);
    }

    return this.toggleClass(options.status, !enable);
}

$.fn.enable = function (options) {
    return this.disable(options, true);
}

$.fn.isDisabled = function () {
    return this.hasClass(disabled);
}