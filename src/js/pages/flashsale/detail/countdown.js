var tplTime = require('./tpl-time.hbs');

var millisecond = 1000
,   second = 1 * millisecond
,   minute = 60 * second
,   hour = 60 * minute
,   day = 24 * hour;

/* 左补0 */
function padLeft(str, len) {
    str = '' + str;
    return str.length >= len ? str : new Array(len - str.length + 1).join("0") + str;
}
/* 右补0 */
function padRight(str, len) {
    str = '' + str;
    return str.length >= len ? str : str + new Array(len - str.length + 1).join("0");
}
function countdown(target, currentTime, endTime, onend) {
    var timeid;
    if (! target.length) {
        return;
    }

    onend = onend || function() {};
    currentTime = currentTime || target.data('time');

    var seconds_left = endTime - currentTime;

    if (seconds_left < 0) {
        clearInterval(timeid);
        target.empty();
        onend();
        return false;
    }

    var render = function (seconds_left) {
        days = Math.floor( seconds_left / day);
        hours = Math.floor( (seconds_left % day) / hour);
        minutes = Math.floor((seconds_left % hour) / minute);
        seconds = Math.floor((seconds_left % minute) / second);

        var tpl = tplTime({
            days: days ? padLeft(days, 2) : false,
            hours: hours ? padLeft(hours, 2) : false,
            minutes: padLeft(minutes, 2),
            seconds: padLeft(seconds, 2)
        });

        target.html(tpl);
    }


    var days, hours, minutes, seconds;

    timeid = setInterval(function () {
        seconds_left -= second

        if (seconds_left < 0) {
            onend();
            clearInterval(timeid);
            return;
        }

        render(seconds_left);
    }, second);

    render(seconds_left);

    var fixTime = function (_currentTime) {
        seconds_left = endTime - _currentTime;
    }

    return fixTime;
}

module.exports = countdown;
