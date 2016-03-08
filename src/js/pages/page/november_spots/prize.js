import ModalBox from 'modules/react-modal-box/index.cjsx';
import PrizeInfo from './prize-info.js'
import DATE from 'modules/sp/date';

export default class Prize extends React.Component {

    constructor(props){
        super(props);
        this.state = {}
    }

    componentDidMount(){

    }

    showPrize(){
        let self = this;
        let memberPrizes = this.props.memberPrizes;
        let prizes = [];
        memberPrizes.map(function(item){
            if(item.prizes){
                item.prizes.map(function(prize){
                    if(prize.prize_type===2){
                        prizes.push(prize);
                    }
                });
            }

        });

        let PrizeInfoComponent = React.createClass({
            render: function(){
                return (
                    <PrizeInfo
                        next={self.props.next}
                        scene={self.props.scene}
                        spotId = {self.props.spotId}
                        isMatter={true}
                        item={memberPrizes.scene}
                        prizes={prizes} />
                );
            }
        });


        let prizeModalBox = new ModalBox({
            width: 750,
            top: 100,
            mask: true,
            closeBtn: true,
            component: <PrizeInfoComponent />
        });

        prizeModalBox.show();
    }

    login(){
        SP.login(function(){
            window.location.reload();
        });
    }

    renderMark() {

        let sourceData = this.props.memberPrizes.length?this.props.memberPrizes:this.props.scenes;
        let data = [];
        if(!sourceData) return null;

        if(this.props.memberPrizes.length){
            sourceData.map(function(item){

                // 判断起止日期是否是同一天
                var beginDate = DATE.parse(item.scene.begin_at)
                ,   endDate = DATE.parse(item.scene.end_at)
                ,   titleDate = DATE.format(beginDate,'MM月d');

                if (endDate.getDate() > beginDate.getDate()) {
                    titleDate += '~' + endDate.getDate();
                }

                titleDate += '日';

                let prizes = '';
                item.prizes.map(function(item1){

                    let title = item1.position;

                    let content = '';

                    if(item1.position==="参与奖"){
                        content = item1.prize_name+item1.prize_quantity+'积分'
                        content = '<p>'+ title + ': ' + content +'</p>';
                    }else if(item.position==="已作废"){
                        content = '<p class="spots-red-color">怀疑采用了非正常手段，奖励取消</p>';
                    }else{
                        content = item1.prize_name
                        content = '<p>'+ title+ ' ' + content+'</p>';
                    }
                    prizes +=content;
                });

                data.push({
                    title: item.scene.title,
                    time: titleDate +' '+DATE.format(DATE.parse(item.scene.begin_at),'hh:mm')+'-'+DATE.format(DATE.parse(item.scene.end_at),'hh:mm'),
                    mark: item.position,
                    prize: prizes
                });
            });
        }else {
            sourceData.map(function(item){
                // 判断起止日期是否是同一天
                var beginDate = DATE.parse(item.begin_at)
                ,   endDate = DATE.parse(item.end_at)
                ,   titleDate = DATE.format(beginDate,'MM月d');

                if (endDate.getDate() > beginDate.getDate()) {
                    titleDate += '~' + endDate.getDate();
                }

                titleDate += '日';

                data.push({
                    title: item.title,
                    time: titleDate +' '+DATE.format(DATE.parse(item.begin_at),'hh:mm')+'-'+DATE.format(DATE.parse(item.end_at),'hh:mm'),
                    mark: '',
                    prize: ''
                });
            });
        }



        return data.map(function(item, index){
            let indexClass = index%2===0?'even':'odd';
            let mark = (<span>{item.mark}</span>);
            if(item.mark==="已作废"){
                mark= (<span className="spots-red-color">{item.mark}</span>);
            }
            return (
                <tr key={index} className={"table-item "+indexClass}>
                    <td>{item.title}</td>
                    <td>{item.time}</td>
                    <td>{item.mark?mark:'没有排名成绩'}</td>
                    <td dangerouslySetInnerHTML={{__html:item.prize}}></td>
                </tr>
            )
        });
    }

    render() {
        let self = this;
        let getPrizes = function(){

            let hasPrizes = false;
            self.props.memberPrizes.map(function(item){
                if(item.prizes){
                    item.prizes.map(function(prize){
                        if(prize.prize_type === 2){
                            hasPrizes = true;
                        }
                    });
                }

            });

            if( SP.isLogined() && hasPrizes ){
                return (
                    <div className="spots-game-title-btns">
                        <a href="javascript:;" onClick={self.showPrize.bind(self)}>领取实物奖品</a>
                    </div>
                )
            }
            return null;
        }
        let loginArea = function(){
            if(!SP.isLogined() && self.props.scenes){
                return (
                    <div className="spots-game-list-login">
                        <div className="spots-game-list-login-tips">亲，奖品和排名要登录了才能看得到哦~</div>
                        <div className="spots-game-list-login-btn">
                            <a href="javascript:;" onClick={self.login}>马上登录</a>
                        </div>
                    </div>
                )
            }
        }

        return (
            <div className="spots-game-prize-wrap two2 u-mt_50 u-clearfix">
                <div className="spots-game-title">
                    <div className="spots-game-title-img"></div>
                    <div className="spots-game-title-txt">排名与奖励</div>
                    {getPrizes()}
                </div>
                <div className="spots-game-list u-mt_30">
                    {loginArea()}
                    <table>
                        <tbody>
                            <tr className="table-title">
                                <th width="350" style={{textIndent:0,padding:'0px 10px'}}>游戏场景</th>
                                <th>游戏时间</th>
                                <th>游戏奖项</th>
                                <th>获得奖品</th>
                            </tr>
                            {this.renderMark()}
                        </tbody>
                    </table>
                </div>
            </div>
        )
    }
}
