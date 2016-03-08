React = require 'react'
liteFlux = require 'lite-flux'
storeName = 'presales-home'
Store = require './_stores/presales-home'
Action = Store.getAction()
View = React.createClass
    mixins: [liteFlux.mixins.storeMixin(storeName)]
    checkout: () ->
        $form = $(@refs['form'])

        if SP.isLogined()
            $form.submit()
        else
            # 登录框
            SP.login ->
                $form.submit()

    render: ->
        store = @state[storeName]
        current = store.current_detail
        skuPicker = store.skuPicker
        sku = skuPicker.selected_sku
        batches = current.batches
        time = ''
        batches.map (item, i) =>
            # 找到当前批次
            if item.id is current.next_valid_batch_id
                # hasCurrentBatches = yes
                # 开售前
                time = item.begin_at.split(' ')[0]
        <div className="ui-modal__box presales-coupon-modal">
            <div className="ui-modal__title">
                {current.coupon.goods_sku_price.price}元购买代金劵
            </div>
            <div className="common-modal-box__content ui-modal__inner u-clearfix">
                <div className="u-clearfix">
                    <div className="span7">
                        <img className="u-img-w-100 u-img-max-w" src={current.thumbs.media.full_path} />
                    </div>
                    <div className="span5">
                        <h5>代金劵：<span className="u-f36 u-color_red">￥{current.coupon.couponTask.value}</span></h5>
                        <div className="u-mb_10">限购单品：{current.goods.title}</div>
                        <div className="u-mb_10">在正式开售之前开放特惠服务，即支付{current.coupon.goods_sku_price.price}元即可在销售时享受{current.coupon.couponTask.value}元的优惠</div>
                        <a href="/article/#{current.article_id}" className="presales-link">活动规则</a>
                    </div>
                </div>
                <footer className="u-text-center u-clearfix u-mt_10">
                    <div className="span3">
                        <div className="u-color_red u-f18">{current.coupon_sold_count}</div>
                        <div className="u-color_gray">已购买人数</div>
                    </div>
                    <div className="span3">
                        <div className="u-color_red u-f18">{time}</div>
                        <div className="u-color_gray">预计开售时间</div>
                    </div>
                    <div className="span3">
                        <div className="u-color_red u-f18">{current.presale_price_tip}</div>
                        <div className="u-color_gray">预售价</div>
                    </div>
                    <div className="span3">
                        <form id="j-buy-now-form" className="u-none" action="/quickbuy" method="POST" ref="form">
                            <input type="hidden" name="item" defaultValue={current.coupon_id} />
                            <input type="hidden" name="is_multiple" defaultValue={0} />
                            <input type="hidden" name="quantity" defaultValue={1} />
                        </form>
                        <span className="btn btn-larger-big btn-color-red" onClick={@checkout}>我要购券</span>
                    </div>
                </footer>
            </div>
        </div>

module.exports = View;
