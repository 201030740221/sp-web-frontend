export default class MoreTips extends React.Component {
    render() {
        let img = require('images/activity/eleven-2015/eleven-main-act.jpg');
        let additional = this.props.additional;
        if(!additional) return null;
        return (
            <div className="spots-game-more u-clearfix">
                <div className="spots-game-title">
                    <div className="spots-game-title-img"></div>
                    <div className="spots-game-title-txt">{additional.additional_title}</div>
                </div>
                <div className="spots-box-shadow eleven-more-tips-box u-mt_30">
                    <div className="eleven-more-tips" dangerouslySetInnerHTML={{__html:additional.additional_content}}>
                    </div>
                    <div className="eleven-cr">
                        最终解释权归斯品所有
                    </div>
                </div>
            </div>
        )
    }
}
