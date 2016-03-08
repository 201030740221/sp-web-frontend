/**
 * 单选功能，对指定容器内的单选项目作为一组单选按钮
 * @param  {[type]} options [description]
 * @return {[type]}         [description]
 * @example
 * <a class="radio" data-value="">单选文本</a>
 */
var data_name_options = "radio-options";
$.fn.radio = function (options) {
    options = $.extend({
        'item': '.radio-box',
        'input': 'input',
        'name': null, // 相当于 input[name]的name属性
        'checked': 'checked',
        'onchange': function (value) {}
    }, options);

    return this.each(function () {
        var $this = $(this)
        ,   $items = $this.find(options.item)
        ,   $input = $this.find(options.input);

        if (!options.name) {
            options.name = $this.data('name')
        }
        
        if (! $input.length) {
            $input = $('<input/>', {
                name: options.name,
                type: 'hidden'
            });
            $this.append($input);
        };

        $this.data('value-input', $input);
        $this.data(data_name_options, options);

        $this.on('click.radio', options.item, function () {
            var $item = $(this);
            if ($item.hasClass(options.checked)) {
                return;
            }

            $item.trigger('radio-checked');

        }).on('radio-checked', options.item, function () {
            var $item = $(this);
    
            $items.removeClass(options.checked);
            $item.addClass(options.checked);

            var value = $item.data('value');
            $input.val($item.data('value'));
            options.onchange.call($item, value, $items);
        });

        $items.filter('.' + options.checked).trigger('radio-checked');
    })
};
/**
 * 获取单选组的当前值的便捷方法
 * @return {[type]} [description]
 */
$.fn.radioVal = function () {
    var $this = this
    ,   $input = $this.data('value-input');

    return $input.length ? $input.val() : null
}