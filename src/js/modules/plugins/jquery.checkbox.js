/**
 * 单选功能，对指定容器内的单选项目作为一组单选按钮
 * @param  {[type]} options [description]
 * @return {[type]}         [description]
 * @example
 * <a class="checkbox" data-value="">单选文本</a>
 */
var data_name_options = "checkbox-options";
$.fn.CheckBox = function (options) {
    options = $.extend({
        'item': '.checkbox',
        'name': null, // 相当于 input[name]的name属性
        'dataAttr': 'value', // 从data-value取值
        'checked': 'checked',
        'oneach': function (index, element) {}, // 遍历每个多选项目
        'onchange': function (isChecked, value, $items) {} // 选中状态， 值， 所有选项，this指向当前选项jquery对象
    }, options);

    return this.each(function () {
        var $this = $(this)
        ,   $items = $this.find(options.item);

        if (!options.name) {
            options.name = $this.data('name')
        }

        $this.data(data_name_options, options);

        $items.each(function (index) {
            var $item = $(this);

            var $input = $('<input/>', {
                name: options.name,
                type: 'hidden',
                value: $item.data(options.dataAttr) // 从data-value取值
            });
            $item.append($input);

            options.oneach.call($item, index, $item);
        });

        $this.on('click.checkbox', options.item, function () {
            var $item = $(this)
            ,   $input = $item.find('input:hidden')
            ,   isChecked = $item.hasClass(options.checked);

            $item.trigger('checkbox-checked', !isChecked);
            options.onchange.call($item, isChecked, $input.val(), $items);

        }).on('checkbox-checked', options.item, function (e, isChecked) {
            var $item = $(this);

            if (isChecked !== false) {
                isChecked = true;
            }

            $item.toggleClass(options.checked, isChecked);
            $item.find('input:hidden').prop('disabled', !isChecked);
        });

        $items.filter('.' + options.checked).trigger('checkbox-checked');
    })
};
/**
 * 获取单选组的当前值的便捷方法
 * @param {Boolean} [isArray] 是否返回数组格式，非数组将返回 逗号间隔的多值字符串
 * @return {[type]} [description]
 */
$.fn.CheckBoxVal = function (values, filter) {
    var $this = this
    ,   options = $this.data(data_name_options)
    ,   $items = $this.find(options.item);

    filter = filter || function (value, $item) {
        return true;
    }

    // 赋值操作
    if (values && Array.isArray(values)) {
        $items.each(function () {
            var $item = $(this)
            ,   value = $item.data(options.dataAttr) // 从data-value取值
            ,   isChecked = values.indexOf(value) != -1;

            $item.trigger('checkbox-checked', isChecked)
        });      
        return this;
    }
    // 取值操作
    values = [];

    $items.each(function () {
        var $item = $(this);

        if (!$item.hasClass(options.checked)) {
            return;
        }

        var $input = $item.find('input:hidden')
        ,   value = $input.val();

        if (filter.call($item, value)) {
            values.push(value);
        }
    });

    return values;
}