/**
 * 整屏滚动插件
 * @param  {[type]} options 配置项目
 * @TODO 1、回调函数 2、触屏支持
 */
var isWheel = "onwheel" in document.createElement("div")
,   wheel = isWheel ? "wheel" :  "mousewheel"
,   delta_name = isWheel ? 'deltaY' : 'wheelDelta'
,   isWebKit = navigator.userAgent.toLowerCase().indexOf('applewebkit') != -1;

$.fn.fullscreen = function (options) {
    options = $.extend({
        'onpagewheel': true,
        'item': 'section',
        'firstScreenOffset': 0,
        'lastScreenOffset': 0,
        'speed': 500,
        'responsive': true,
        'scale': null // 响应式的item容器高宽度自适应缩放比例(宽度/高度)
    }, options);

    // window.pageYOffset 和 window.scrollY。旧版本IE（<9）两个属性都不支持
    var $win = $(window)
    ,   $html = $('html')
    ,   $page = isWebKit ? $('body') : $html // webkit核心是body scrolltop, ie及firefox是 html scrollTop
    ,   $items = this.find(options.item)
    ,   count = $items.length
    ,   $firstItem = $items.eq(0)
    ,   $lastItem = $items.eq(count - 1)

    ,   eventspace = '.full-screen'
    ,   events = {
        'wheel': wheel + eventspace,
        'resize': 'resize' + eventspace
    }
    ,   isRunning = false
    ,   active_index = 0

    ,   screen_height = $win.height();

    // 隐藏滚动条
    $html.css({
        'overflow-y': 'hidden'
    });

    function setActiveItem(index) {
        index = index || 0
        $items.removeClass('active').eq(index).addClass('active');
    }
    function gotoScreen(active_index) {
        // 指定滚屏
        var goto_top = $items.eq(active_index).offset().top;

        if (options.firstScreenOffset && active_index == 0) {
            goto_top -= options.firstScreenOffset;
        }
        if (options.lastScreenOffset && active_index == (count - 1)) {
            goto_top += options.lastScreenOffset;
        }

        isRunning = true;
        $page.animate({
            'scrollTop': goto_top //dir * screen_height + curr_top
        }, options.speed, function () {
            setActiveItem(active_index);
            isRunning = false;
        });
    }
    function init() {
        setTimeout(function () {
            gotoScreen(0);
        }, 1000);
    }

    if (options.responsive) {
        $win.on(events.resize, function (e) {
            screen_height = $win.height();
            $items.height(screen_height);

            if (options.scale) {
                $items.width(screen_height * options.scale);
            }

            if (options.firstScreenOffset) {
                $firstItem.height(screen_height - options.firstScreenOffset);
            }
            if (options.lastScreenOffset) {
                $lastItem.height(screen_height - options.lastScreenOffset);
            }

            // 锁定active屏
            var top = active_index * screen_height;
            $win.scrollTop(top);

        }).trigger(events.resize);
    }

    var container = options.onpagewheel ? $page : this;

    container.on(events.wheel, function (e, delta) {
        e.preventDefault();

        delta = delta || e.originalEvent[delta_name]
        var dir = 1
        ,   isDown = delta < 0;

        if (isRunning || delta === 0) {
            return;
        }

        if (isDown) {
            dir = -1
        }
        if ((active_index === 0 && dir < 0) || (active_index === (count - 1) && dir > 0)) {
            return;
        }

        // var curr_top = $win.scrollTop();
        active_index += dir;
        gotoScreen(active_index);
    });

    this.nextScreen = function () {
        container.trigger(events.wheel, 1);
    }
    this.prevScreen = function () {
        container.trigger(events.wheel, -1);
    }
    this.gotoScreen = gotoScreen;

    init();

    return this;
}
