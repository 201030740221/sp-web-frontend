let Banner = require('./banner.js');
let Game = require('./game.js');
let Ranking = require('./ranking.js'); // 奖励
let Prize = require('./prize.js'); // 排名
let Scene = require('./scene.js'); // 游戏场景及大奖一览
let MoreTips = require('./more-tips.js'); // 游戏场景及大奖一览
let More = require('./more.js'); // 游戏场景及大奖一览


class Page extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            spotId: null,
            scene: null,
            more_activity: null,
            additional: null,
            scenes: null,
            sceneContent: null,
            winners: [],
            winners_active: null,
            myself: null,
            next: null,
            participants: null,
            member_prizes: []
        };
    }
    componentDidMount() {
        let self = this;

        let $win = $(window);
        let $document = $(document);
        $win.load(function() {
          var offsetMap;

          $document.on('click', '#sidebar li, .goto-top, .zero .item img', function() {
            var index;
            offsetMap = {
              zero: 0,
              one: $('.one1').offset().top,
              two: $('.two2').offset().top,
              three: $('.three3').offset().top
            };
            index = $(this).data('index');
            return $('html, body').animate({
              'scrollTop': offsetMap[index]
          }, 200);
          });

        });

        $('#cs').on('click', function() {
          if (typeof mechatClick !== 'undefined') {
            mechatClick();
          }
        });

        $win.on('scroll', function() {
          var gotopTimeId, scrollTop;
          clearTimeout(gotopTimeId);
          scrollTop = $win.scrollTop();
          let $sidebar = $('#sidebar');
          let $gotop = $sidebar.find('.goto-top');
          gotopTimeId = null;
          let speed = 100;
          let $item = $sidebar.find('li');
          $item.removeClass('active');
          let offsetMap = {
            zero: 0,
            one: ($('.one1').offset() && $('.one1').offset().top) || 0,
            two: ($('.two2').offset() && $('.two2').offset().top) || 0,
            three: ($('.three3').offset() && $('.three3').offset().top) || 0
          };
          if (scrollTop > offsetMap.three - 300) {
            $item.eq(2).addClass('active');
          } else if (scrollTop > offsetMap.two - 100) {
            $item.eq(1).addClass('active');
          } else if (scrollTop > offsetMap.one - 100) {
            $item.eq(0).addClass('active');
          }
          return gotopTimeId = setTimeout(function() {
            var winHeight;
            winHeight = $win.height();
            if (scrollTop > winHeight) {
              return $gotop.fadeIn(speed);
            } else {
              return $gotop.fadeOut(speed);
            }
          }, 50);
        });

        $win.trigger('scroll');

        webapi.activity.spotCurrent().then(function(res){
            if(res && !res.code){
                self.setState({
                    spotId: res.data.id,
                    scene: res.data.scene,
                    sceneContent:{
                        fail_tip: res.data.fail_tip,
                        rule_content: res.data.rule_content,
                        rule_title: res.data.rule_title,
                        success_tip: res.data.success_tip,
                        tactic_tip: res.data.tactic_tip,
                        title: res.data.title
                    },
                    more_activity: {
                        more_activity_href: res.data.more_activity_href,
                        more_activity_thumb: res.data.more_activity_thumb,
                        more_activity_thumb_url: res.data.more_activity_thumb_url,
                        more_activity_title: res.data.more_activity_title
                    },
                    additional: {
                        additional_content: res.data.additional_content,
                        additional_title: res.data.additional_title
                    },
                    next: res.data.next,
                    participants: res.data.participants
                }, function(){

                    webapi.activity.spotScenes().then(function(res1){
                        if(res1 && !res1.code){

                            self.setState({
                                scenes: res1.data.data
                            },function(){
                                if(res1.data.data.length){
                                    self.updateRanking(res1.data.data[0].spot_id, res1.data.data[0].id);
                                }
                            });
                        }
                    });



                    //
                    if(SP.isLogined()){

                        //个人实物奖品
                        webapi.activity.spotMyPrize( res.data.id, false ).then(function(res2){
                            if(res2 && !res2.code){
                                self.setState({
                                    member_prizes: res2.data
                                });
                            }
                        });
                    }

                });
            }
        });



    }
    changeGameImg(img){
        let scene = this.state.scene;
        scene.game_img_url = img;
        this.setState(scene);
    }
    updateRanking(spot_id, id, index){
        let self = this;

        function getSceneIndex(){
            let index = 0;
            self.state.scenes.map(function(scene,i){
                if(self.state.scene && (self.state.scene.id===scene.id)){
                    index = i;
                    id = scene.id;
                }
            });
            return index;
        }

        if(typeof index !== 'number') getSceneIndex();

        webapi.activity.spotWinners( spot_id, id ).then(function(res){
            if(res && !res.code){
                self.setState({
                    winners: res.data.winners,
                    winners_active: (typeof index === 'number')?index:getSceneIndex(),
                    myself: res.data.myself
                });
            }
        });
    }
    render(){
        let self = this;
        let rankingArea = function(){
            return <Ranking
                updateRanking={self.updateRanking.bind(self)}
                winners_active={self.state.winners_active}
                spotId={self.state.spotId}
                myself={self.state.myself}
                winners={self.state.winners}
                scene={self.state.scene}
                scenes={self.state.scenes}
                sceneContent={self.state.sceneContent} />
        }
        let rqcodeImg = require("images/qrcode/weixin-sipin-life-m.png");
        return (
            <div className="spots-page">
                <Banner scene={this.state.scene} next={this.state.next} />
                <Game
                    updateRanking={this.updateRanking.bind(self)}
                    participants={this.state.participants}
                    next={this.state.next}
                    spotId={this.state.spotId}
                    scene={this.state.scene}
                    changeGameImg={this.changeGameImg.bind(self)}
                    sceneContent={this.state.sceneContent} />
                {rankingArea()}
                <Prize
                    memberPrizes = {this.state.member_prizes}
                    spotId={this.state.spotId}
                    next={this.state.next}
                    scene={this.state.scene}
                    scenes={this.state.scenes} />
                <Scene scenes={this.state.scenes} />
                <MoreTips additional={this.state.additional} />
                <More more_activity={this.state.more_activity} />
                <aside id="sidebar" className="sidebar">
                    <div className="qrcode">
                        <img src={'/static'+rqcodeImg} alt="" />
                        <span>关注斯品生活</span>
                        <span>立享20元现金券</span>
                    </div>
                    <ul>
                        <li data-index="one">
                            <span>游戏区</span>
                        </li>
                        <li data-index="two">
                            <span>排名</span>
                            <span>获奖攻略</span>
                        </li>
                        <li data-index="three">
                            <span>大奖</span>
                            <span>预告</span>
                        </li>
                        <li id="cs">
                            <span>咨询</span>
                            <span>客服</span>
                        </li>
                    </ul>
                    <div className="goto-top" data-index="zero">
                        <em><i className="iconfont" dangerouslySetInnerHTML={{__html: '&#xf012c;'}}></i><br/>TOP</em>
                        <span>回到<br/>顶部</span>
                    </div>
                </aside>
            </div>
        );
    }
}

ReactDom.render( <Page />, document.getElementById('game-container'));
