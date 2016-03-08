import TimeShow from 'modules/react-time-show/time-show';
import CountDown from 'modules/react-count-down/count-down';
import DATE from 'modules/sp/date';

var CountDownContent = React.createClass({
    render: function(){
        if(this.props.days === 0 && this.props.hours === 0 && this.props.minutes === 0 && this.props.seconds === 0){
            return (
                <div className="spots-banner-timer-show u-clearfix">
                    <div className="spots-banner-timer-hours">00</div>
                    <div className="spots-banner-timer-minutes">00</div>
                    <div className="spots-banner-timer-seconds">00</div>
                </div>
            );
        } else{
            return (
                <div className="spots-banner-timer-show u-clearfix">
                    <div className="spots-banner-timer-hours">{this.props.hours}</div>
                    <div className="spots-banner-timer-minutes">{this.props.minutes}</div>
                    <div className="spots-banner-timer-seconds">{this.props.seconds}</div>
                </div>
            );
        }

    }
});

export default class Banner extends React.Component {
    renderPrizes() {

        let data = [];
        if(this.props.scene){
            // 调整参与奖位置
            this.props.scene.prizes.push(this.props.scene.prizes[0]);
            delete this.props.scene.prizes[0];

            this.props.scene.prizes.map(function(prize, index){
                if(prize){
                    let title = '';
                    if(prize.begin_position==-1){
                        title =  "参与奖"
                    }else{
                        title = prize.begin_position + '-' + prize.end_position + '名';
                    }
                    let goodsName = '';
                    switch (prize.prize_type) {
                        // 积分
                        case 0:
                            goodsName = '';
                            break;
                        // 优惠券
                        case 1:
                            goodsName = '<p>有效期至</p><p>'+prize.prize_description+'</p>';
                            break;
                        // 实物商品
                        case 2:
                            goodsName = '<p>'+prize.prize_name+'</p>'+'<p>售价：￥'+prize.prize_price+'</p>';
                            break;
                        default:
                            break;
                    }

                    let goodsUrl = null
                    if (prize.prize_sku) {
                        goodsUrl = '/item/' + prize.prize_sku + '.html';
                        goodsName = '<a style="color: inherit" href="'+ goodsUrl +'" target="_blank">' + goodsName + '</a>'
                    }
                    if (prize.prize_type == 0) {
                        goodsUrl = '/member/point/mall'
                    }

                    data.push({
                        title: title,
                        media: prize.prize_img_url,
                        goodsUrl: goodsUrl,
                        goodsName: goodsName
                    });
                }
            })
        }

        return data.map(function(item,index){
            let colorClass = 'prize-head'+(index+1);

            let image = <img src={item.media} />;

            if (item.goodsUrl) {
                image = (
                    <a href={item.goodsUrl} target="_blank">
                        { image }
                    </a>
                )
            }

            return (
                <div key={index} className={"spots-gift " + colorClass}>
                    <div className="spots-gift-title">{item.title}</div>
                    <div className="spots-gift-img">
                        { image }
                    </div>
                    <div className="spots-gift-txt">
                        <p dangerouslySetInnerHTML={{__html:item.goodsName}}></p>
                    </div>
                </div>
            )
        });
    }
    TimeUp() {
        window.location.reload();
    }
    renderCountdown() {
        let scene = this.props.scene;
        if(!scene) return null;

        let begin_at_arrr = scene.begin_at.match(/\-(\w+)/gi);

        let waitTime = {
            end: scene.begin_at
        }

        let doingTime = {
            start: scene.begin_at,
            end: scene.end_at
        }

        let endShow = {
            condition:{
                status: (!this.props.next && DATE.gt(this.props.scene.end_at) ) ? true : false
            }
        }


        return (
            <div className="spots-banner-timer">
                <div className="spots-banner-timer-sub-title">
                    {begin_at_arrr[0].replace('-','')}月{begin_at_arrr[1].replace('-','')}日游戏场次（{scene.title}）
                </div>
                <TimeShow {...endShow}>
                    <div>
                        <div className="spots-banner-timer-title">游戏已结束</div>
                        <div className="spots-banner-timer-show u-clearfix">
                            <div className="spots-banner-timer-hours">00</div>
                            <div className="spots-banner-timer-minutes">00</div>
                            <div className="spots-banner-timer-seconds">00</div>
                        </div>
                    </div>
                </TimeShow>
                <TimeShow {...waitTime} >
                    <div>
                        <div className="spots-banner-timer-title">距离游戏开始时间还剩：</div>
                        <CountDown
                            showDay={false}
                            callback={this.TimeUp}
                            data={{
                                startTime: DATE.getTime(),
                                endTime: DATE.getTime(scene.begin_at)
                            }}
                            component={CountDownContent}
                        />
                    </div>
                </TimeShow>
                <TimeShow {...doingTime} >
                    <div>
                        <div className="spots-banner-timer-title">距离游戏关闭时间还剩：</div>
                        <CountDown
                            showDay={false}
                            callback={this.TimeUp}
                            data={{
                                startTime: DATE.getTime(scene.begin_at),
                                endTime: DATE.getTime(scene.end_at)
                            }}
                            component={CountDownContent}
                        />
                    </div>
                </TimeShow>

            </div>
        )
    }
    render() {

        return (
            <div className="spots-banner-wrap u-clearfix">
                <div className="spots-banner">
                    <div className="spots-gifts u-clearfix">
                        {this.renderPrizes()}
                    </div>
                </div>
                {this.renderCountdown()}
            </div>
        )
    }
}
