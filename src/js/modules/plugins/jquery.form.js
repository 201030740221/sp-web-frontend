var inputElements = 'input, select, textarea';
$.fn.serializeMap = function (options) {
    var opt = $.extend({
        'separator': ',' // checkbox多个值的间隔符
    }, options);

    var $inputs = this.find(inputElements)
        , map = {};

    $inputs.each(function () {
        var name = this.name
            , value = this.value;

        if (!name) return;

        if (this.type === 'radio' && this.checked) {
            map[name] = value;
        } else if (this.type === 'checkbox' && this.checked) {
            map[name] = map[name] ? (map[name] + opt.separator + value) : value
        } else if (map[name] && opt.separator) {
            map[name] = map[name] + opt.separator + value
        } else if (map[name]) {
            if (map[name] instanceof Array) {
                map[name].push(value);
            }
            else {
                map[name] = [map[name], value];
            }
        } else {
            map[name] = value;
        }
    });

    return map;
};