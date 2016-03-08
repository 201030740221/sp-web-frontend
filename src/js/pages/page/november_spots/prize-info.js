var Checkbox = require('widgets/react-checkbox/react-checkbox');
import DATE from 'modules/sp/date';

export default class PrizeInfo extends React.Component {

    constructor(props){
        super(props);
        this.state = {
            prizes: this.props.prizes || []// 奖品列表
        }
        // 领取实物奖品的时间
        // 如果没有下一场，表示最后一场，取最后一场的奖品确定时间
        // 弹窗共用，所以判断是否传入了scene
        if (!this.props.next && this.props.scene) {
            this.drawTime = this.props.scene.release_time;
            this.isTimeOk = this.drawTime && DATE.gt(this.drawTime);
        }
    }

    componentDidMount() {
    }

    renderItem(){

        let self = this;
        let data = this.state.prizes;

        if(!self.props.isMatter){
            data.push(data[0]);
            delete data[0];
        }

        return data.map(function(item, index){
            if(!item){
                return null;
            }

            if(self.props.isMatter && item.prize_type!==2){
                return null;
            }

            let checkbox = function(){
                if(self.props.isMatter && self.isTimeOk){
                    return <Checkbox checked={true} onChange={null} label='' />
                }
            }
            let title = '';

            if(self.props.isMatter){
                title = item.position
            }else{
                if(item.begin_position===-1){
                    title = item.end_position + '名';
                }else{
                    title = item.begin_position + '-' + item.end_position + '名';
                }

            }

            let content = '';

            let goodsUrl = null
            if (item.prize_sku) {
                goodsUrl = '/item/' + item.prize_sku + '.html';
            }

            if (item.prize_type == 0) {
                goodsUrl = '/member/point/mall'
            }

            if(self.props.isMatter){
                content = item.prize_name
                content = '<p>'+ content +'</p>';
                content += '<p>原价：￥'+item.prize_price+'</p>';
                content += '<p>x1</p>';
            }else{
                switch (item.prize_type) {
                    // 积分
                    case 0:
                        content = item.prize_name+item.prize_quantity+'积分'
                        if (goodsUrl) {
                            content = '<a href="'+ goodsUrl +'" target="_blank">'+ content +'</a>'
                        }
                        content = '<p>'+ content +'</p>';
                        content += '<p>适用范围：斯品商城</p>';
                        break;
                    // 优惠券
                    case 1:
                        content = '<p>'+item.prize_name+' 优惠券 '+'</p>';
                        content += '<p>x1</p>';
                        break;
                    // 实物商品
                    case 2:
                        content = item.prize_name
                        if (goodsUrl) {
                            content = '<a href="'+ goodsUrl +'" target="_blank">'+ content +'</a>'
                        }
                        content = '<p>'+content+'</p>';
                        content += '<p>售价：'+item.prize_price+'</p>';
                        content += '<p>x1</p>';
                        break;
                    default:
                        break;
                }
            }

            let image = <img src={item.prize_img_url} />

            if (goodsUrl) {
                image = (
                    <a href={goodsUrl} target="_blank">
                        { image }
                    </a>
                )
            }

            return (
                <div key={index} className="prize-info-item u-clearfix">
                    {/*checkbox()*/}
                    <div className="prize-info-item-img">
                        { image }
                    </div>
                    <div className="prize-info-item-goods">
                        <h4>{title}</h4>
                        <p dangerouslySetInnerHTML={{__html:content}}></p>
                    </div>
                </div>
            )
        });
    }
    render() {
        let postPrizeUrl = '/loot';
        let img = require('images/activity/eleven-2015/img110-110.jpg');
        let self = this;

        let submitBtn = function(){
            if (self.props.isCommonShow) {
                return null;
            }

            if(self.state.prizes && self.isTimeOk){
                return (
                    <form action={postPrizeUrl} target="_blank" method="post">
                        <input type="hidden" name="spot_id" value={self.props.spotId} />
                        <button type="submit" className="btn btn-primary-larger-big btn-color-orange u-ml_10">马上领取</button>
                    </form>
                )
            }

            if (!self.drawTime) {
                return null
            }

            let drawTime = DATE.format(self.drawTime, 'M月dd日hh:mm');

            return (
                <p className="u-text-center u-mt_10 u-f14">请于{drawTime}后统一领取实物奖，敬请留意</p>
            )
        }

        let getTitle = function(){
            if(self.props.isMatter){
                return (
                    <div className="ui-modal__title">
                        奖品明细
                    </div>
                )
            }else{
                return (
                    <div className="ui-modal__title">
                        {self.props.item.title} 奖品明细（{DATE.format(DATE.parse(self.props.item.begin_at),'MM月dd日')}  {DATE.format(DATE.parse(self.props.item.begin_at),'hh:mm')} -{DATE.format(DATE.parse(self.props.item.end_at),'hh:mm')} ）
                    </div>
                )
            }
        }

        return (
            <div className="ui-modal__box prize-info-modal">
                {getTitle()}
                <div className="common-modal-box__content ui-modal__inner u-pb_30 u-clearfix">
                    <h3 className="u-f18 u-ml_10">排名大奖：</h3>
                    <div className="prize-info-items u-clearfix">
                        {this.renderItem()}
                    </div>

                    <div className="prize-info-submit" >
                        {submitBtn()}
                    </div>
                </div>
            </div>
        )
    }
}
