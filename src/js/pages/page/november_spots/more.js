export default class More extends React.Component {
    render() {
        let more_activity = this.props.more_activity;
        if(!more_activity) return null;
        return (
            <div className="spots-game-more u-mt_50 u-clearfix">
                <div className="spots-game-title">
                    <div className="spots-game-title-img"></div>
                    <div className="spots-game-title-txt">{more_activity.more_activity_title}</div>
                </div>
                <div className="u-mt_30">
                    <a href={more_activity.more_activity_href}>
                        <img style={{width: '100%'}} src={more_activity.more_activity_thumb_url} />
                    </a>
                </div>
            </div>
        )
    }
}
