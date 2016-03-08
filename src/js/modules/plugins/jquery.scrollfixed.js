/**
 * 随着滚动 而使某个元素固定在视窗内，始终可见
 * @param  {[type]} options [description]
 * @return {[type]}         [description]
 */

$.fn.scrollFixed = function (options) {
    options = $.extend({
        'box': null // 不能脱离指定的盒范围之外
    }, options);

    var $this = this
    ,   $win = $(window)
    ,   $box = options.box ? $(options.box) : null

    ,   originLeft = $this.css('left')
    ,   originBottom = $this.css('bottom')
    ,   originTop = $this.css('top')
    ,   height
    ,   offset
    ,   win_height
    ,   boxH
    ,   boxOffset
    ,   inView

    ,   resizeDelayId

    ,   get = function () {
        height = $this.outerHeight();
        offset = $this.offset();
        win_height = $win.height();
        inView = height < win_height

        if ($box) {
            boxH = $box.innerHeight();
            boxOffset = $box.offset();
        }
        
    };

    get();

    $win.on('resize.fixed', function () {
        $this.removeClass('fixed');
        $this.css({
            'left': originLeft,
            'bottom': originBottom,
            'top': originTop
        })

        clearTimeout(resizeDelayId);
        resizeDelayId = setTimeout(function () {
            get();
            $win.trigger('scroll.fixed');
        }, 300);
    }).on('scroll.fixed', function () {
        var scrollTop = $win.scrollTop()
        ,   _top = -10
        ,   bottom = 10
        ,   win_bottom = scrollTop + win_height
        ,   pos = win_bottom - (height + offset.top)

        ,   needFixed = false
        ,   style;

        // 固定元素高度小于视窗高度，则按照顶部固定，否则按底部固定
        if (inView) {
            needFixed = scrollTop >= offset.top;

            if ($box) {
                _top = -Math.max(win_bottom - (boxH + boxOffset.top) - (win_height - height), _top)
            }

            style = {
                'bottom': needFixed ? 'auto' : originBottom,
                'top': needFixed ? _top : originTop
            }
        } else {
            needFixed = pos >= 0;

            if ($box) {
                bottom = Math.max(win_bottom - (boxH + boxOffset.top), bottom)
            }
            style = {
                'top': needFixed ? 'auto' : originTop,
                'bottom': needFixed ? bottom : originBottom
            };
        }

        style.left = needFixed ? offset.left : originLeft
        
        $this.css(style);

        $this.toggleClass('fixed', needFixed)
    }).trigger('resize.fixed');

    return this;
};