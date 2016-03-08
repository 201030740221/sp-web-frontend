import CountDown from 'modules/react-count-down/count-down';
import DATE from 'modules/sp/date';
import TimeShow from 'modules/react-time-show/time-show';

var CountDownContent = React.createClass({
    render: function(){
        var timeTitle = '剩余时间 ';
        if(this.props.days === 0 && this.props.hours === 0 && this.props.minutes === 0 && this.props.seconds === 0){
            return (
                <span>{timeTitle}<em>加载中...</em> </span>
            );
        } else{
            return (
                <span>{timeTitle}<em className="spots-red-color">{this.props.minutes + ":" + this.props.seconds + ":" + this.props.milliseconds}</em> </span>
            );
        }

    }
});

var TimeBox = React.createClass({
    TimeUp: function(){
        let mark = '00:00:000';
        this.props.onChange('timeup', mark);
        console.log("时间到!");
    },
    render: function(){
        let self = this;
        let unplaying = {
            condition:{
                status: (this.props.status==='playing') ? false : true
            }
        }
        // let playing = {
        //     condition:{
        //         status: this.props.status==='playing' ? true : false
        //     }
        // }
        let isShowTime = {
            condition:{
                status: (this.props.status==='playing') ? true : false
            }
        }

        let startTime = this.props.score.start_time;
        let endTime = this.props.score.start_time+this.props.data.score.totalTime;

        let getPlayersNum = function(){
            if(!self.props.participants) return null;
            return (
                <div className="spots-game-title-sub-txt">已有<span className="spots-red-color">{self.props.participants}</span>人参与</div>
            )
        }

        return (
            <div className="spots-game-time-box">
                <div className="spots-game-title">
                    <div className="spots-game-title-img"></div>
                    <div className="spots-game-title-txt">参与即有奖品</div>
                    <TimeShow {...unplaying}>
                        <div className="spots-game-title-txt">排名越靠前奖励越丰厚</div>
                    </TimeShow>
                        {getPlayersNum()}

                        <TimeShow {...isShowTime}>
                            <div className="spots-game-title-txt">
                                <CountDown
                                    callback={this.TimeUp}
                                    data={{
                                        startTime: startTime,
                                        endTime: endTime
                                    }}
                                    component={CountDownContent}
                                />
                                <span className="u-ml_10">还需查找<em className="spots-red-color">{this.props.pointsLength}</em>处</span>
                            </div>
                        </TimeShow>

                </div>
            </div>
        )
    }
});

module.exports = TimeBox;
