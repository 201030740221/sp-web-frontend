import TimeShow from 'modules/react-time-show/time-show';
import ModalBox from 'modules/react-modal-box/index.cjsx';
import WeixinShare from './weixin-share-modal-box.js';
import Share from 'modules/social-share/share';

class GameWeixinShare extends React.Component {
    render(){
        return (
            <WeixinShare
                url={"http://www.sipin.com/activity/november"}
                tips={'打开微信，扫描二维码<br />分享到微信好友或者朋友圈<br />即可获得额外游戏时间'} />
        )
    }
}


export default class GameBody extends React.Component {

    constructor(props) {
        super(props);
        this.state = {};
        this.errorAreaTimer = null;
    }

    handlerErrorPoint(e) {

        function guidGenerator() {
            var S4 = function() {
                return ((1 + Math.random())*0X10000|0).toString(16).substring(1);
            };
            return (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4());
        }

        this.errorAreaTimer = null;
        this.props.onChange('errorClick',{
            clientX: e.clientX,
            clientY: e.clientY
        });
        let id = guidGenerator();
        let time = Math.floor(this.props.score.error_cut_time/1000);
        let $errorArea = $('<div class="spots-game-errorArea" id="errorArea'+id+'"><div class="spots-red-color">找错了T_T</div><div class="spots-red-color">-'+time+'s</div></div>')
        $($errorArea).insertAfter('.spots-game-wrap').css({
            left: e.clientX-25,
            top: $(window).scrollTop() + e.clientY - 15
        }).addClass('zoomIn animated').show();

        this.errorAreaTimer = setTimeout(function(){
            $("#errorArea"+id).removeClass('zoomIn animated').hide();
        },1000);
    }

    handlerSuccesPoint(index) {
        this.props.onChange('selected', index);
    }

    componentDidMount() {

    }

    runStartAminate(callback){
        let $startAminate = $(".spots-game-start")
        $startAminate.show();
        let time = 3;
        let timer = setInterval(function(){
            if(time<=0){
                clearInterval(timer);
                $startAminate.hide();
                callback();
            }
            $('.spots-game-start-num').hide();
            $('.spots-game-start-num-'+time).addClass('zoomIn animated').show();
            time--;
        },1000);
    }

    // startGame
    onStartGame(id){
        let self = this;
        if(this.props.status!=='ready'){
            return;
        }

        webapi.activity.spotSceneInfo(this.props.spotId, this.props.scene.id).then(function(res){
            if(res && !res.code){
                if(res.data.is_played){
                    self.props.onChange("played");
                }else{
                    self.runStartAminate(function(){
                        self.props.onChange("start", res.data);
                    });
                }
            }else{
                if(res.code===1){
                    SP.notice.error(res.msg);
                }else{
                    SP.login(function(){
                        window.location.reload();
                    });
                }

            }
        });

    }

    addWeixinShare(id){
        let weixinShareModalBox = new ModalBox({
            width: 350,
            top: 100,
            mask: true,
            closeBtn: true,
            component: <GameWeixinShare />
        });

        weixinShareModalBox.show();

        //增加时间
        if( SP.isLogined() ){
            SP.storage.set('november-spots-weixin', id+'_'+SP.member.name );
        }

    }

    addWeiBoShare(id){
        let weiboShare = new Share({
            'link': location.href,
            'image': this.props.scene.origin_img_url,
            'weibo_content': this.props.scene.weibo_share_content || '玩找茬赢大奖，斯品11月，游戏大奖，折扣秒杀，更多福利，斯品不止是双十一'
        });
        weiboShare.toWeibo();
        // 记录
        if( SP.isLogined() ){
            SP.storage.set('november-spots-weibo', id+'_'+SP.member.name );
        }
    }

    render() {
        let self = this;
        let spotsGameSourcePicture= 'url(' + this.props.data.sourcePicture + ')';
        let spotsGameDifferentPicture = 'url(' + this.props.data.differentPicture + ')';

        let pointsTag = this.props.data.points.map(function(point, index){
            if(!point.isClicked){
                return (
                    <div key={index}
                        onClick={self.handlerSuccesPoint.bind(self, index)}
                        style={{
                            left: point.left,
                            top: point.top,
                            width: point.width,
                            height: point.height
                        }}
                        className="picture-diff-point">
                    </div>
                )
            }else{
                return (
                    <div key={index}
                        style={{
                            left: point.left,
                            top: point.top,
                            width: point.width,
                            height: point.height,
                        }}
                        className="picture-diff-point spots-game-successArea">
                    </div>
                )
            }

        });

        // 左侧图片，应该在没有进行游戏时显示
        let unplaying = {
            condition:{
                status: this.props.status==='playing' ? false : true
            }
        }


        let showRules = {
            condition:{
                status: (this.props.status==='playing'||this.props.status==='gameover'||this.props.status==='success') ? false : true
            }
        }

        //场景还没开始
        let waiting = {
            condition:{
                status: (this.props.status==='waiting') ? true : false
            }
        }

        // 场景已开始，还没开始玩游戏
        let ready = {
            condition:{
                status: (this.props.status==='ready' && !this.props.scene.is_played) ? true : false
            }
        }

        // 场景已开始，正在玩游戏
        let playing = {
            condition:{
                status: this.props.status==='playing' ? true : false
            },
            start:this.props.startTime,
            end:this.props.endTime
        }

        // 游戏胜利
        let success = {
            condition:{
                status: this.props.status==='success' ? true : false
            }
        }

        // 场景已开始，已玩过游戏
        let gameover = {
            condition:{
                status: this.props.status==='gameover' ? true : false
            }
        }

        let is_played = {
            condition:{
                status: this.props.scene.is_played ? true : false
            }
        }

        // 场景已结束
        let end = {
            condition:{
                status: this.props.status==='end' ? true : false
            }
        }

        let endShow = {
            condition:{
                status: (!this.props.next && DATE.gt(this.props.scene.end_at) ) ? true : false
            }
        }

        let begin_at_arrr = this.props.startTime.match(/\-(\w+)/gi);
        let tactic_tip = this.props.sceneContent.tactic_tip;

        tactic_tip = tactic_tip.replace(/\%b\%/gi,'<span class="spots-red-color">');
        tactic_tip = tactic_tip.replace(/\%e\%/gi,'</span>');

        let nextTips = function(){
            if(self.props.next){
                return (
                    <div className="spots-pruple-color">下一个游戏场景将在{DATE.format(DATE.parse(self.props.next.begin_at),'MM月dd日')}开放哦，敬请期待~</div>
                )
            }
        }

        return (
            <div className="spots-game-wrap">
                <div className="spots-game u-clearfix">
                    <div className="spots-game-span">
                        <TimeShow {...unplaying}>
                            <div className="spots-game-source-picture spots-game-source-wrap spots-game-box" style={{backgroundImage: spotsGameSourcePicture }}>

                            </div>
                        </TimeShow>
                        <TimeShow {...playing}>
                            <div className="spots-game-source-picture spots-game-source-wrap spots-game-box" style={{backgroundImage: spotsGameSourcePicture }}>
                                <div className="picture-error-point" onClick={this.handlerErrorPoint.bind(this)} />
                                {pointsTag}
                            </div>
                        </TimeShow>
                    </div>
                    <div className="spots-game-span">
                        <TimeShow {...success}>
                            <div className="spots-game-box spots-game-rules">
                                <div className="spots-game-rules-inner spots-game-result">
                                    <div className="spots-game-result-title">恭喜您顺利通过游戏！</div>
                                    <div className="spots-game-result-content">
                                        <p>用时<span className="spots-red-color">{this.props.mark}</span>，当前排名<span className="spots-red-color">{this.props.rank}</span>位</p>
                                        <p>感谢您的参与，在此先送出参与奖<span className="spots-red-color">{this.props.participation}</span></p>
                                    </div>
                                    <div className="spots-game-result-bottom">
                                        <div>最终排名和丰厚排名奖于场景关闭当天23:00公布哟，请留意微信或本站消息</div>
                                        {nextTips()}
                                    </div>
                                </div>
                            </div>
                        </TimeShow>
                        <TimeShow {...gameover}>
                            <div className="spots-game-box spots-game-rules">
                                <div className="spots-game-rules-inner spots-game-result">
                                    <div className="spots-game-result-title">很遗憾，未能完成游戏</div>
                                    <div className="spots-game-result-content">
                                        <p>用时<span className="spots-red-color">>{this.props.mark}</span></p>
                                        <p>表灰心，斯品送你参与奖<span className="spots-red-color">{this.props.participation}</span>打打气</p>
                                    </div>
                                    <div className="spots-game-result-bottom">
                                        <div>最终排名和丰厚排名奖于场景关闭当天23:00公布哟，请留意微信或本站消息</div>
                                        {nextTips()}
                                    </div>
                                </div>
                            </div>
                        </TimeShow>
                        <TimeShow {...showRules}>
                            <div className="spots-game-box spots-game-rules">
                                <div className="spots-game-start u-none">
                                    <div className="spots-game-start-bg"></div>
                                    <div className="spots-game-start-nums">
                                        <div className="spots-game-start-nums-inner">
                                            <span className="spots-game-start-num spots-game-start-num-3">3</span>
                                            <span className="spots-game-start-num spots-game-start-num-2">2</span>
                                            <span className="spots-game-start-num spots-game-start-num-1">1</span>
                                        </div>
                                    </div>
                                </div>
                                <div className="spots-game-rules-inner">
                                    <div className="spots-game-rules-txt">
                                        <p>游戏场景：{begin_at_arrr[0].replace('-','')}月{begin_at_arrr[1].replace('-','')}日 {this.props.scene.title}</p>
                                        <p className="u-mt_15">游戏攻略：<span  dangerouslySetInnerHTML={{__html:tactic_tip}}></span></p>
                                        <p className="u-mt_15">注：点错的话是要扣时间的哦，请小心下手~</p>
                                    </div>
                                    <div className="spots-game-actions u-mt_50">
                                        <TimeShow {...endShow}>
                                            <a href="javascript:;" className="spots-disabled">游戏已结束</a>
                                        </TimeShow>
                                        <TimeShow {...waiting}>
                                            <a href="javascript:;" className="spots-disabled">游戏即将开始</a>
                                        </TimeShow>
                                        <TimeShow {...is_played}>
                                            <a href="javascript:;" className="spots-disabled">您已经参与过游戏</a>
                                        </TimeShow>
                                        <TimeShow {...ready}>
                                            <a href="javascript:;" onClick={this.onStartGame.bind(this,this.props.scene.id)}>准备好了？马上开始</a>
                                        </TimeShow>
                                    </div>
                                    <div className="spots-game-share u-mt_30">
                                        <div className="tips">告诉你一个秘密，分享活动可获得额外时间奖励，简直赢在起跑线上~</div>
                                        <div className="share-btns u-mt_15 clearfix">
                                            <span className="u-fl spots-share-text">马上分享：</span>
                                            <span className="weixin spots-share-icon u-fl" onClick={this.addWeixinShare.bind(this,this.props.scene.id)}>微信</span>
                                            <span className="weibo spots-share-icon u-fl" onClick={this.addWeiBoShare.bind(this,this.props.scene.id)}>微博</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </TimeShow>
                        <TimeShow TimeShow {...playing}>
                            <div className="spots-game-different-picture spots-game-different-wrap spots-game-box" style={{backgroundImage: spotsGameDifferentPicture }}>
                                <div className="picture-error-point" onClick={this.handlerErrorPoint.bind(this)} />
                                {pointsTag}
                            </div>
                        </TimeShow>
                    </div>
                </div>
            </div>
        );
    }
};
