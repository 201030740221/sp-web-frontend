export default class Ranking extends React.Component {
    constructor(props){
        super(props);
    }
    getSceneWinners(status,id, index){
        let self = this;
        if(status==0) {
            if(self.props.scene.id===id){
                this.props.updateRanking(self.props.spotId, id, index);
                return;
            }else{
                return;
            }
        };
        this.props.updateRanking(self.props.spotId, id, index);
    }
    renderRank(){
        let self = this;

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

        let getWinners = function(){
            return self.props.winners.map(function(item,index){

                let no = "other";
                if(index<3){
                    no = index+1;
                }
                let num = index+1;
                if(num<10){
                    num = '0'+num;
                }
                return (
                    <tr key={index}>
                        <td>
                            <span className={"num-"+no}>{num}</span>
                            <span>{item.member.name}</span>
                        </td>
                        <td>
                            {getMark(parseInt(item.result))}
                        </td>
                    </tr>
                )
            });
        }

        let getMySelf = function(){
            if(!self.props.myself) return (
                <div>
                    <div className="rank-2-title">您当前的排名</div>
                    <div className="rank-2-num">无</div>
                    <div className="rank-2-time"></div>
                </div>
            );
            return (
                <div>
                    <div className="rank-2-title">您当前的排名</div>
                    <div className="rank-2-num">{self.props.myself.position}</div>
                    <div className="rank-2-time">耗时：{getMark(parseInt(self.props.myself.result))}</div>
                </div>
            )
        }

        let getScene = function(){
            if(!self.props.scenes) return null;
            return self.props.scenes.map(function(item, index){

                // 判断起止日期是否是同一天
                var beginDate = DATE.parse(item.begin_at)
                ,   endDate = DATE.parse(item.end_at)
                ,   titleDate = DATE.format(beginDate,'MM月d');

                if (endDate.getDate() > beginDate.getDate()) {
                    titleDate += '~' + endDate.getDate();
                }

                titleDate += '日';

                let classes = 'ranking-tab-menu-style ranking-tab-menu';
                //ranking-tab-menu-hover
                switch (item.status) {
                    case 0:
                        break;
                    default:
                        classes = 'ranking-tab-menu-style ranking-tab-menu-normal'
                        break;
                }

                if(self.props.scene && (item.id === self.props.scene.id)){
                    classes = 'ranking-tab-menu-style ranking-tab-menu-normal'
                }

                if(self.props.winners_active==index){
                    classes +=' ranking-tab-menu-hover';
                }

                return (
                    <div key={index} className={classes} onClick={self.getSceneWinners.bind(self,item.status,item.id, index)} >
                        <p>{titleDate}</p>
                        <p>{item.title}</p>
                    </div>
                )
            });
        }

        return (
            <div>
                <div className="ranking-title">最新排行</div>
                <div className="ranking-content u-clearfix">
                    <div className="ranking-x ranking-1">
                        <div className="ranking-tab-menus">
                            {getScene()}
                        </div>
                    </div>
                    <div className="ranking-x ranking-2">
                        {getMySelf()}
                    </div>
                    <div className="ranking-x ranking-3">
                        <table>
                            <tbody>
                                <tr>
                                    <th className="ranking-3-th1">会员名</th>
                                    <th>完成时间</th>
                                </tr>
                                {getWinners()}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        )
    }
    render() {
        let self = this;
        if(!this.props.sceneContent) return null;

        let renderRankDiv = function(){
            if(SP.isLogined()){
                return self.renderRank();
            }
        }

        return (
            <div className="u-mt_30 u-clearfix">

                {renderRankDiv()}

                <div className="ranking-tips u-mt_30">
                    <h3>{this.props.sceneContent.rule_title}</h3>
                    <div className="ranking-tips-content" dangerouslySetInnerHTML={{__html:this.props.sceneContent.rule_content}}></div>
                </div>

            </div>
        )
    }
}
