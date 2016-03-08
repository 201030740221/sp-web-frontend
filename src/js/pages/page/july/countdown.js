var _countdown = require('../../flashsale/detail/countdown');

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

    // if (!start.length || !now.length) {
    //     return false;
    // }

    // var startTime = new Date(start).getTime();
    // var currentTime = new Date(now).getTime();

    // if (currentTime - startTime >= 0) {
    //     $(target).text('0');
    //     return false;
    // }

    // var days, hours, minutes, seconds;

    // setInterval(function () {

    //     var currentTime = new Date().getTime();
    //     var secondsLeft = (startTime - currentTime) / 1000;

    //     days = parseInt(secondsLeft / 86400);
    //     secondsLeft = secondsLeft % 86400;

    //     hours = parseInt(secondsLeft / 3600);
    //     secondsLeft = secondsLeft % 3600;

    //     minutes = parseInt(secondsLeft / 60);
    //     seconds = parseInt(secondsLeft % 60);

    //     $(target).html("<span>" + days + "</span>天<span>" + hours + "</span>小时<span>" + minutes + "</span>分<span>" + seconds + "</span>秒");

    // }, 1000);
}

module.exports = countdown;
