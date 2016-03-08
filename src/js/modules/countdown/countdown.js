var MILLISECOND = 1,
    SECOND = 1000 * MILLISECOND,
    MINUTE = 60 * SECOND,
    HOUR = 60 * MINUTE,
    DAY = 24 * HOUR;

/* 左补0 */
function padLeft(str, len) {
    str = '' + str;
    return str.length >= len ? str : new Array(len - str.length + 1).join('0') + str;
}

/* 右补0 */
function padRight(str, len) {
    str = '' + str;
    return str.length >= len ? str : str + new Array(len - str.length + 1).join('0');
}

function countdown($target, currentTime, endTime, onend) {
    var timeid, days, hours, minutes, seconds;

    onend = onend || function () {};

    var secondsLeft = endTime - currentTime;

    if (secondsLeft < 0) {
        clearInterval(timeid);
        $target.empty();
        onend($target);
        return false;
    }

    var render = function (secondsLeft) {
        days = Math.floor(secondsLeft / DAY);
        hours = Math.floor((secondsLeft % DAY) / HOUR);
        minutes = Math.floor((secondsLeft % HOUR) / MINUTE);
        seconds = Math.floor((secondsLeft % MINUTE) / SECOND);

        var tpl = '';

        if (days) {
            tpl = tpl + '<span class="_item">' + days + '</span>天';
        }
        if (hours) {
            tpl = tpl + '<span class="_item">' + padLeft(hours, 2) + '</span>时';
        }

        tpl = tpl + '<span class="_item">' + padLeft(minutes, 2) + '</span>分' +
                '<span class="_item">' + padLeft(seconds, 2) + '</span>秒';

        $target.html(tpl);
    };

    timeid = setInterval(function () {
        secondsLeft -= SECOND;

        if (secondsLeft < 0) {
            onend($target);
            clearInterval(timeid);
            return;
        }

        render(secondsLeft);
    }, SECOND);

    render(secondsLeft);

    var fixTime = function (_currentTime) {
        secondsLeft = endTime - _currentTime;
    };

    return fixTime;
}

$.fn.countdown = function (options) {

    var opts = $.extend({
        onend: function(){}
    }, options);

    return this.each(function () {
        var $target = $(this);
        var now = opts.now ? $target.data(opts.now) : $target.data('validity-now');
        var end = opts.end ? $target.data(opts.end) : $target.data('validity-end');

        now = DATE.parse(now).getTime();
        end = DATE.parse(end).getTime();

        countdown($target, now, end, opts.onend);
    });
};

module.exports = countdown;
