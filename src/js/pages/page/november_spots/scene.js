import ModalBox from 'modules/react-modal-box/index.cjsx';
import PrizeInfo from './prize-info.js'
import SmsNotice from './sms-notice.js'

export default class Scene extends React.Component {

    constructor(props){
        super(props);
    }

    showSmsNotice(sceneId) {

        let SmsNoticeComponent = React.createClass({
            render: function(){
                return (
                    <SmsNotice sceneId={sceneId} />
                );
            }
        });

        let smsNoticeModalBox = new ModalBox({
            width: 400,
            top: 100,
            mask: true,
            closeBtn: true,
            component: <SmsNoticeComponent />
        });

        smsNoticeModalBox.show();
    }

    addSmsNotice(sceneId) {
        let self = this;
        this.showSmsNotice(sceneId);
    }

    showPrize(item, prizes) {

        let PrizeInfoComponent = React.createClass({
            render: function(){
                return (
                    <PrizeInfo item={item} prizes={prizes} isCommonShow={true} />
                );
            }
        });

        let prizeModalBox = new ModalBox({
            width: 750,
            top: 100,
            mask: true,
            closeBtn: true,
            component: PrizeInfoComponent
        });

        prizeModalBox.show();
    }

    renderScene() {
        let self = this;
        // let data = [{
        //     media: '/images/activity/eleven-2015/img480-360.jpg',
        //     title: '11月6日 简约餐厅',
        //     status: 1,
        //     url:'111',
        //     isSetSms: false,
        //     prizes: [{
        //         value: '维多利 餐桌'
        //     },{
        //         value: '500元优惠劵'
        //     }]
        // },{
        //     media: '/images/activity/eleven-2015/img480-360.jpg',
        //     title: '11月6日 简约餐厅',
        //     status: 2,
        //     url:'111',
        //     isSetSms: true,
        //     prizes: [{
        //         value: '维多利 餐桌'
        //     },{
        //         value: '500元优惠劵'
        //     }]
        // }];
        if(!this.props.scenes) return null;

        let data = [];
        this.props.scenes.map(function(item){

            let prizeData = [];
            let participate = '';
            let participateValue = '';
            item.prizes.map(function(prize){

                let goodsName = '';
                switch (prize.prize_type) {
                    // 积分
                    case 0:
                        goodsName = prize.prize_name+prize.prize_quantity+'分  '+(prize.end_position-prize.begin_position+1)+'名';
                        participateValue = prize.prize_name+prize.prize_quantity+'分';
                        break;
                    // 优惠券
                    case 1:
                        goodsName = prize.prize_name+' 优惠券 '+(prize.end_position-prize.begin_position+1)+'名';
                        participateValue = prize.prize_name+' 优惠券';
                        break;
                    // 实物商品
                    case 2:
                        goodsName = prize.prize_name+' '+(prize.end_position-prize.begin_position+1)+'名';
                        participateValue = prize.prize_name;
                        break;
                    default:
                        break;
                }


                let title = prize.begin_position + '-' + prize.end_position + '名';
                if(prize.begin_position==-1){
                    participate = {
                        title: "参与奖",
                        media: prize.prize_img_url,
                        goodsName: participateValue
                    };
                    return;
                }


                prizeData.push({
                    title: title,
                    media: prize.prize_img_url,
                    goodsName: goodsName
                })
            });

            // 判断起止日期是否是同一天
            var beginDate = DATE.parse(item.begin_at)
            ,   endDate = DATE.parse(item.end_at)
            ,   titleDate = DATE.format(beginDate,'MM月d');

            if (endDate.getDate() > beginDate.getDate()) {
                titleDate += '~' + endDate.getDate();
            }

            titleDate += '日 ';

            data.push({
                id: item.id,
                media: item.origin_img_url,
                title: titleDate + item.title,
                status: item.status,
                url: item.href,
                isSetSms: false,
                _prizes: item.prizes,
                prizes: prizeData,
                participate: participate
            });
        });

        return data.map(function(item, index){
            let getStatus = function(){
                switch (item.status) {
                    case 1:
                        return (
                            <div className="scene-item-status scene-item-status-ie8 scene-item-status-doing">
                                进行中
                            </div>
                        )
                        break;
                    case 2:
                        return (
                            <div className="scene-item-status scene-item-status-ie8 scene-item-status-end">
                                已结束
                            </div>
                        )
                        break;
                    default:
                        return (
                            <div className="scene-item-status scene-item-status-ie8 scene-item-status-wait">
                                准备中
                            </div>
                        )
                }

            };
            let prizesList = '';
            item.prizes.map(function(prize,index){
                let goodsName = prize.goodsName;
                prizesList += goodsName+ (item.prizes.length==(index+1)?'':' | ');
            });
            let participate = item.participate;

            let setSmsBtn = <a className="spots-item-btn spots-item-sms-btn" href="javascript:;" onClick={self.addSmsNotice.bind(self,item.id)}>短信提醒</a>
            if(item.isSetSms){
                setSmsBtn = <a className="spots-item-btn spots-item-sms-btn spots-item-btn-disabled" href="javascript:;">已设置提醒</a>
            }

            return (
                <div key={index} className="span4 scene-item spots-box-shadow">
                    <div className="scene-item-title">
                        {item.title}
                    </div>
                    <div className="scene-item-img">
                        {getStatus()}
                        <a target="_blank" href={item.url}>
                            <img src={item.media} />
                        </a>
                    </div>
                    <div className="scene-item-ranking u-clearfix">
                        <div className="scene-item-ranking-left">
                            <h3>排名大奖：</h3>
                            <div className="scene-item-all-prize">
                                <p>{prizesList}</p>
                                <p>参与奖：{participate.goodsName}</p>
                            </div>
                        </div>
                        <div className="scene-item-ranking-right">
                            <div className="u-mb_10">
                                <a className="spots-item-btn" href="javascript:;" onClick={self.showPrize.bind(null,{
                                    title: item.title,
                                    begin_at: self.props.scenes[index].begin_at,
                                    end_at: self.props.scenes[index].end_at
                                },item._prizes)}>奖品详情</a>
                            </div>
                            <div>
                                {setSmsBtn}
                            </div>
                        </div>
                    </div>
                </div>
            )
        });
    }

    render() {
        return (
            <div className="scene-wrap three3 u-mt_50">
                <div className="spots-game-title">
                    <div className="spots-game-title-img"></div>
                    <div className="spots-game-title-txt">游戏场景及大奖一览</div>
                </div>
                <div className="scene-list u-mt_30 u-clearfix">
                    {this.renderScene()}
                </div>
            </div>
        )
    }
}
