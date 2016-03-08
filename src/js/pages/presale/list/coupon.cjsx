React = require 'react'
CouponModal = require './coupon-modal'
ModalBox = require 'modules/react-modal-box/index.cjsx'
liteFlux = require 'lite-flux'
storeName = 'presales-home'
Store = require './_stores/presales-home'
Action = Store.getAction()
View = React.createClass
    mixins: [liteFlux.mixins.storeMixin(storeName)]
    showModal: (event)->
        event.preventDefault()

        modal = new ModalBox
            width: 600
            top: 100
            mask: true
            closeBtn: true
            component: <CouponModal />

        modal.show()

    render: ->
        store = @state[storeName]
        current = store.current_detail
        skuPicker = store.skuPicker
        sku = skuPicker.selected_sku
        if current.has_bought_coupon is yes
            buyNode = <td rowSpan={2} className="disabled">已购买</td>
        else
            buyNode = <td rowSpan={2} onClick={@showModal}>我要购券</td>
        <div className="presales-coupon u-mt_60">
            <header>
                <span>
                    限量发售
                    <span className="u-color_red">￥{current.coupon.couponTask.value}</span>
                    代金券，只需
                    <span className="u-color_red">{current.coupon.goods_sku_price.price}元</span>
                </span>
            </header>
            <table>
                <tbody>
                    <tr>
                        <td>
                            <span className="u-f24">￥</span>
                            <span className="u-f36">{current.coupon.couponTask.value}</span>
                        </td>
                        <td>
                            <div className="u-mb_5">限购单品：</div>
                            <div>{current.goods.title}</div>
                        </td>
                        {buyNode}
                    </tr>
                    <tr>
                        <td>
                            已经有
                            <span className="u-color_yellow">{current.coupon_sold_count}</span>
                            人购买
                        </td>
                        <td>
                            <a href="/article/#{current.article_id}">活动规则</a>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
module.exports = View
