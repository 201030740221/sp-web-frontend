React = require 'react'

View = React.createClass

    render: ->
        <div className="presales-block-3">
            <div className="wrap">
                <header>
                    <h4>购买攻略</h4>
                    <span>越早预定越实惠</span>
                </header>
                <section>
                    <h5>
                        <img src="#{staticPrefix}/images/presales/presales-block-3-icon-1.png" />
                        <span>即将预售</span>
                    </h5>
                    <div>可提前了解产品，一分钱抢购代金券。并可以提前设置提醒。需注册斯品帐号。</div>
                    <footer>
                        <img src="#{staticPrefix}/images/presales/presales-block-3-step-1.png" />
                    </footer>
                </section>
                <section>
                    <h5>
                        <img src="#{staticPrefix}/images/presales/presales-block-3-icon-2.png" />
                        <span>提前登录</span>
                    </h5>
                    <div>根据预售时间准时开售，提前登录斯品商城做好预售购买准备。</div>
                    <footer>
                        <img src="#{staticPrefix}/images/presales/presales-block-3-step-2.png" />
                    </footer>
                </section>
                <section>
                    <h5>
                        <img src="#{staticPrefix}/images/presales/presales-block-3-icon-3.png" />
                        <span>首发预售</span>
                    </h5>
                    <div>仅限一天，以超低折扣进行销售，并且还是闪电发货。</div>
                    <footer>
                        <img src="#{staticPrefix}/images/presales/presales-block-3-step-3.png" />
                    </footer>
                </section>
                <section>
                    <h5>
                        <img src="#{staticPrefix}/images/presales/presales-block-3-icon-4.png" />
                        <span>限量预售</span>
                    </h5>
                    <div>错过了首发预售也没关系，在限量预售阶段同样可以以较低的折扣购买到心仪的产品</div>
                    <footer>
                        <img src="#{staticPrefix}/images/presales/presales-block-3-step-4.png" />
                    </footer>
                </section>
                <section>
                    <h5>
                        <img src="#{staticPrefix}/images/presales/presales-block-3-icon-5.png" />
                        <span>支付定金尾款</span>
                    </h5>
                    <div>按系统规定的时间，支付定金以及尾款，未及时支付可能会取消订单或者延期发货哟。</div>
                    <footer>
                        <img src="#{staticPrefix}/images/presales/presales-block-3-step-5.png" />
                    </footer>
                </section>
                <section>
                    <h5>
                        <img src="#{staticPrefix}/images/presales/presales-block-3-icon-6.png" />
                        <span>评价晒单</span>
                    </h5>
                    <div>收货后进行评价以及晒单，可获得全场优惠券。</div>
                    <footer>
                        <img src="#{staticPrefix}/images/presales/presales-block-3-step-6.png" />
                    </footer>
                </section>
            </div>
        </div>

module.exports = View
