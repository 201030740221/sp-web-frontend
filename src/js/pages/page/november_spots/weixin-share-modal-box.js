export default class WeixinShareModalbox extends React.Component {
    constructor(props){
        super(props);
        this.state = {
            src: null,
            tips: props.tips || '打开微信，扫描二维码<br />分享到微信好友或者朋友圈'
        }
    }

    componentDidMount() {
        let self = this;
        webapi.tools.qrcode({
            url: self.props.url
        }).then(function(src){
            self.setState({
                src: src
            })
        });
    }

    render() {

        return (
            <div className="ui-modal__box prize-info-modal">
                <div className="ui-modal__title">
                    推荐到微信
                </div>
                <div className="common-modal-box__content ui-modal__inner u-clearfix">
                    <div id="share-to-weixin-tmpl">
                        <div className="u-clearfix u-mb_20">
                            <img id="weixin-qrcode-referral-img" alt="二维码" width="100" src={this.state.src} className="u-fl u-mr_10" />
                            <p className="u-pt_10" dangerouslySetInnerHTML={{__html: this.state.tips}}></p>
                        </div>
                    </div>
                </div>
            </div>
        )
    }
}
