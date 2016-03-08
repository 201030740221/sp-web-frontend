import GameTime from './game-time';
import GameBody from './game-body';
import DATE from 'modules/sp/date';

export default class Game extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            status: 'waiting', // waiting,ready,playing,gameover,end
            score: {},
            mark: '00:00:000',
            rank: '-',
            participation: '',
            points: []

        };

    }

    // 获取未点击过的数目
    getLeftPoints() {
        let ret = {
            clicked: 0,
            length: this.state.points.length
        };
        this.state.points.map(function(point){
            if(point.isClicked){
                ret.clicked++
            }
        });
        return ret;
    }

    // 是否已结束
    isGameOver() {
        // 状态结束
        if( this.state.status==="end" || this.state.score.totalTime<=0 || this.getLeftPoints().clicked===this.getLeftPoints().length ){
            return true;
        }
        return false;
    }

    onChange(status, data) {
        let self = this;
        let scene = this.props.scene;
        let mark = '00:00.000';

        function getMark(time){
            let minutes = Math.floor(time/1000/60);
            let seconds = Math.floor(time/1000)-minutes*60;
            let milliseconds = time-minutes*60*1000-seconds*1000;

            minutes = minutes<10?'0'+minutes:minutes;
            seconds = seconds<10?'0'+seconds:seconds;
            milliseconds = milliseconds<100?'0'+milliseconds: (milliseconds<10&&milliseconds>0?'00'+milliseconds:(milliseconds<=0?'000':milliseconds));

            let mark = minutes+':'+seconds+'.'+milliseconds;
            return mark;
        }

        function setMark(time){
            webapi.activity.spotResult({
                spot_id: self.props.spotId,
                scene_id: self.props.scene.id,
                result: time
            }).then(function(res){
                if(res && !res.code){
                    let state = self.state;
                    state.rank = res.data.position;
                    state.participation = res.data.prize;
                    self.setState(state);
                }else{
                    if(res.code===20002){
                        // 手太快提示
                        SP.notice.error(res.data.errors.result[0]);
                    }else{
                        SP.notice.error(res.msg);
                    }

                }
                self.props.updateRanking(self.props.spotId, self.props.scene.id);
            });
        }

        switch (status) {
            // 已玩过游戏
            case "played":
                SP.notice.success('您已经参与过了本场游戏，请留意下一场游戏开放时间');
                break;
            // 开始游戏
            case "start":
                let points = [];
                let total_time = data.during_time;
                data.items.map(function(item){
                    points.push({
                        left: item.x + '%',
                        top: item.y + '%',
                        isClicked: false,
                        width: item.width+'%',
                        height: item.height+'%'
                    })
                });
                // 如果分享了，加时间
                if(SP.storage.get('november-spots-weixin')==(scene.id+'_'+SP.member.name)){
                    total_time+=data.additional_time
                }
                if(SP.storage.get('november-spots-weibo')==(scene.id+'_'+SP.member.name)){
                    total_time+=data.additional_time
                }

                self.props.changeGameImg(data.game_img_url);

                this.setState({
                    status: "playing",
                    score:{
                        error_num: 0,
                        totalTime: total_time,
                        during_time: data.during_time, // 游戏时间
                        error_cut_time: data.error_cut_time,
                        additional_time: data.additional_time,
                        start_time: DATE.getTime()
                    },
                    points: points,
                    scene: scene
                });
                $('#sidebar').hide();
                break;
            // 时间到
            case "timeup":
                let state = this.state;
                let now = DATE.getTime();
                let use_time = now-state.score.start_time;
                mark = getMark(use_time);
                setMark(-1);
                this.setState({
                    status: "gameover",
                    mark: getMark(use_time)
                });
                $('#sidebar').show();
                break;
            // 选中操作
            case 'selected':
                if(!this.isGameOver()){
                    let state = this.state;
                    state.points[data].isClicked = true;
                    // 是否已完成选择
                    if(this.getLeftPoints().clicked===this.getLeftPoints().length){
                        let now = DATE.getTime();
                        state.status = "success";
                        let use_time = now-state.score.start_time;
                        state.mark = getMark(use_time);
                        setMark(use_time);
                        $('#sidebar').show();
                    }
                    this.setState(state);
                }
                break;
            // 点错操作
            case 'errorClick':
                if(!this.isGameOver()){
                    let score = this.state.score;
                    score.error_num +=1;
                    score.totalTime -= score.error_cut_time;
                    this.setState(score);
                    //console.log('error');
                }
                break;
            default:

        }
    }

    render() {
        let self = this;
        let pointsLength = this.getLeftPoints().length - this.getLeftPoints().clicked;

        let scene = this.props.scene;
        if(!scene) return null;

        let now = DATE.getTime();
        let start = DATE.getTime( scene.begin_at );
        let end = DATE.getTime( scene.end_at );

        let status = 'waiting';
        switch (scene.status) {
            case 1:
                status = 'ready';
                if(this.state.status==="playing"){
                    status = 'playing';
                }
                if(this.state.status==="gameover"){
                    status = 'gameover';
                }
                if(this.state.status==="success"){
                    status = 'success';
                }
                break;
            case 2:
                status = 'end';
                break;
            default:
                break;
        }

        let data = {
            status: status, // ready, doing, end
            score: this.state.score,
            startTime: scene.begin_at, // 场景开放时间
            endTime: scene.end_at,   // 场景关闭时间
            data: {
                sourcePicture: scene.origin_img_url,
                differentPicture: scene.game_img_url,
                points: this.state.points
            }

        };

        return (
            <div className="one1 u-clearfix">
                <GameTime
                    data = {data}
                    status = {data.status}
                    next = {this.props.next}
                    score = {data.score}
                    participants = {this.props.participants}
                    onChange = {this.onChange.bind(this)}
                    pointsLength = {pointsLength} />
                <GameBody
                    sceneContent = {this.props.sceneContent}
                    spotId = {this.props.spotId}
                    next = {this.props.next}
                    scene = {this.props.scene}
                    mark = {this.state.mark}
                    rank = {this.state.rank}
                    participation = {this.state.participation}
                    startTime = {data.startTime}
                    endTime = {data.endTime}
                    data = {data.data}
                    score = {data.score}
                    onChange = {this.onChange.bind(this)}
                    status= {data.status} />
            </div>
        );
    }
};
