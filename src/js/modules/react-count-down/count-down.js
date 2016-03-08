var DATE = require('modules/sp/date');
var CountDown = React.createClass({
    getInitialState: function() {
        return {
            timer: null,
            days: 0,
            hours: 0,
            minutes: 0,
            seconds: 0,
            milliseconds: 0
        };
    },
    getDefaultProps: function(){
        return {
            milliseconds: true,  // 是否支持毫秒
            fromNow: true, // 是否从当前时间开始计时
            showDay: true, // 是否显示天数
        }
    },
    countDown: function() {
        var self = this,
            endTime = DATE.getTime(this.props.data.endTime),
            startTime = DATE.getTime(this.props.data.startTime),
            diff = endTime - startTime,
            second =  this.props.milliseconds? 1000: 1,
            minute = 60 * second,
            hour = 60 * minute,
            day = 24 * hour;

        if(!diff){
            self.setState({
                days: '00',
                hours: '00',
                minutes: '00',
                seconds: '00',
                milliseconds: '000',
            });
            return;
        }

        clearInterval(this.state.timer);
        this.setState({
            timer: setInterval(function() {

                if(self.props.fromNow){
                    endTime = DATE.getTime(self.props.data.endTime);
                    startTime = DATE.getTime();
                    diff = endTime - startTime;
                }else{
                    diff--;
                }

                var days = Math.floor(diff / day),
                    hours = Math.floor(( diff - day * days ) / hour),
                    minutes = Math.floor(( diff - day * days - hour * hours ) / minute),
                    seconds = Math.floor((diff - day * days - hour * hours - minutes * minute)/second),
                    milliseconds = Math.floor(diff - day * days - hour * hours - minutes * minute - seconds * second);
                // 如果不显示天数
                hours = Math.floor(diff/ hour);

                if (diff < 0) {
                    clearInterval(self.state.timer);
                    if (self.props.callback)
                        self.props
                            .callback();
                } else {

                    hours = hours < 10
                        ? "0" + hours
                        : hours;
                    minutes = minutes < 10
                        ? "0" + minutes
                        : minutes;
                    seconds = seconds < 10
                        ? "0" + seconds
                        : seconds;
                    milliseconds = milliseconds < 100
                        ? "0" + milliseconds
                        : (milliseconds < 10 ? "00" + milliseconds : (milliseconds <= 0 ? "000" : milliseconds));

                    self.setState({
                        days: days,
                        hours: hours,
                        minutes: minutes,
                        seconds: seconds,
                        milliseconds: milliseconds,
                    });
                }

            }, this.props.milliseconds ? 1 : 1000)
        });
    },
    componentDidMount: function() {
        this.countDown();
    },
    componentWillReceiveProps: function() {
        this.countDown();
    },
    componentWillUnmount: function() {
        clearInterval(this.state.timer);
    },
    render: function() {
        var Content = this.props.component;
        return (
            <Content
                days={this.state.days}
                hours={this.state.hours}
                minutes={this.state.minutes}
                seconds={this.state.seconds}
                milliseconds = {this.state.milliseconds}/>
        );
    }
});

module.exports = CountDown;
