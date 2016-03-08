/**
 * 简易兼容ie8的placeholder插件
 * @see  components/input.jsx
 * @tofishes
 */
$.fn.placeholder = function () {
    return this.each(function () {
        var $input = $(this)
        ,   placeholder = $input.attr('placeholder');

        if ('placeholder' in document.createElement('input') || !placeholder) return;

        var $wrap = $('<span class="placeholder-wrap" />')
        ,   $label = $('<i class="placeholder-label"></i>').html(placeholder);

        if ($input.is("textarea"))
            $wrap.addClass('placeholder-textarea-wrap')

        $input.wrap($wrap).after($label);

        $input.on('blur', function () {
            if (!$.trim($input.val())) {
                $label.show();
            }
        }).on('focus', function () {
            $label.hide();
        }).parent().on('click', function() {
            $input.focus();
        }).css({
            'float': $input.css('float')
        });
    });
};