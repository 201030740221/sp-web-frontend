//秒杀模块
var Tab = require('Tab');
var _countdown = require('../../flashsale/detail/countdown');

var tab1 = new Tab({
    target: '.flash-goods-grid'
});
var $goodsGrid = $('.flash-goods-grid');
var $tab = $goodsGrid.find('.ui-tab');
var $tabItem = $tab.find('.ui-tab__item');
var $navTrigger = $('#j-grid-nav');
var $activeItem;
var activeIndex;

function handleStatus() {
    $activeItem = $tab.find('a._active').closest('li');
    activeIndex = $tabItem.index($activeItem);
    $navTrigger.find('.grid-nav__item').removeClass('_disable');
    if (activeIndex === 0) {
        $navTrigger.find('li.j-prev').addClass('_disable');
    }
    else if (activeIndex === $tabItem.length - 1) {
        $navTrigger.find('li.j-next').addClass('_disable');
    }
}

handleStatus();

$tabItem.on('click', function () {
    handleStatus();
});

$navTrigger.on('click', '.grid-nav__item', function (e) {
    handleStatus();
    var $target = $(e.target);
    if ($target.hasClass('j-prev') && !$target.hasClass('_disable')) {
        $tabItem.eq(activeIndex - 1).trigger('click');
    }
    else if ($target.hasClass('j-next') && !$target.hasClass('_disable')) {
        $tabItem.eq(activeIndex + 1).trigger('click');
    }
});

//秒杀倒计时
function countdown(target) {
    var $target = $(target);
    var start = $target.data('starttime');
    var end = $target.data('endtime');
    var now = $target.data('now');

    now = new Date(now).getTime();
    start = new Date(start).getTime();
    end = new Date(end).getTime();

    _countdown($target, now, start, function () {
        var clone = $target.clone(false);
        $target.replaceWith(clone);

        var $tip = clone.prev();

        if ($tip.text().indexOf('离秒杀开始时间还有') != -1) {
            $tip.html('离秒杀结束时间还有')
        }

        _countdown(clone, now, end);
    });
}

var $flashSection = $('.flash-section');
var $target = $flashSection.find('[data-starttime]');
$target.each(function (index) {
    countdown(this);
});