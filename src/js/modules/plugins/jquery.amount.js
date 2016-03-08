/**
 * 数量选择器
 * @param  {[type]} options [description]
 * @return {[type]}         [description]
 */
var data_old = 'amount-old-value'
,   event_click = 'click.amount'

,   _alert = function (msg) {
    if (window.SP) SP.alert(msg)
    else alert(msg)    
}
,   setVal = function ($input, increase, filter) {
    var max = $input.data('max') || 99
    ,   min = $input.data('min') || 1
    ,   oldNum = $input.data(data_old)
    ,   newNum = increase + parseInt($input.val().replace(/[^0-9]/g,''))
    ,   valid = true
    ,   valid_filter;

    valid_filter = filter.call($input, newNum);

    if ($.isFunction(valid_filter)) {
        valid_filter.call($input, newNum);
        return;
    }

    if (valid_filter === false) {
        valid = false;
    }

    if (isNaN(newNum)) {
        valid = false;
    }

    if (newNum > max) {
        _alert("最多只能选择" + max + "件商品")
        valid = false
    }
        
    if (newNum < 1) {
        _alert("最少得有 " + min + "件商品")
        valid = false
    }

    if (!valid) {
        $input.val(oldNum)
    } else {
        $input.val(newNum)
        $input.data(data_old, newNum);
    }
};

$.fn.amount = function (options) {
    options = $.extend({
        'plus': '.plus',
        'minus': '.minus',
        'onchange': function (value) {} // 返回false可以阻止值改变
    }, options);

    return this.each(function () {
        var $this = $(this)
        ,   $input = $this.find('input');

        $this.on(event_click, options.plus, function () {
            setVal($input, 1, options.onchange);
        }).on(event_click, options.minus, function () {
            setVal($input, -1, options.onchange);
        });

        $input.on('keyup amount.change', function (e) {
            // 上下左右键, 不做操作, 38/40/37/39
            if (e.keyCode > 36 && e.keyCode < 41) {
                return;
            }
            setVal($input, 0, options.onchange);
        }).data(data_old, $input.val() || 1);
    });
}
/**
 * 获取或设置数量的当前值的便捷方法
 * @return {[type]} [description]
 */
$.fn.amountVal = function (value) {
    var $input = this.find('input');

    if (typeof value !== 'undefined') {
        $input.val(value)
        return $input.trigger('amount.change');
    }

    return $input.val();
}
/**
 * 修改数量最大值，最小值
 * @param  {Object Map} range {max: 22, min: 1} || {max: 22} || {min : 1}
 * @return input对象
 */
$.fn.amountRange = function (range) {
    var $input = this.find('input');

    for (var name in range) {
        $input.data(name, range[name])
    }
    return $input;
}