/*
@author axu
*/

(function($) {

    $.fn.tag = function(options) {
        var $el = this;
        var defaults = {
            isMultiple: true,
            dataValue: null,
            onChange: function() {}
        };
        var opts = $.extend({}, defaults, options);

        function getValues () {
            var values = [];
            $el.each(function() {
                var $this = $(this);
                if ($this.hasClass('_active')) {
                    if (opts.dataValue) {
                        values.push($this.data(opts.dataValue));
                    }
                    else {
                        values.push($this.text());
                    }
                }
            });
            return values;
        }

        $el.each(function() {
            var $this = $(this);
            $this.on('click', function(e) {
                var $target = $(this);
                if (opts.isMultiple) {
                    $target.toggleClass('_active');
                    opts.onChange(getValues());
                }
                else {
                    $el.removeClass('_active');
                    $target.addClass('_active');
                    var value = null;
                    if (opts.dataValue) {
                        value = $target.data(opts.dataValue);
                    }
                    else {
                        value = $target.text();
                    }
                    opts.onChange(value);
                }
            });
        });

        return $el;
    };

})(jQuery);
