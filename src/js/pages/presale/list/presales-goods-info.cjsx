
liteFlux = require 'lite-flux'

Store = require './_stores/presales-home'
Action = Store.getAction()
storeName = 'presales-home'
WindowListenable = require 'modules/components/mixins/window-listenable'
GoodsInfo = require('./goods-info.cjsx');

modal = React.createClass
    mixins: [liteFlux.mixins.storeMixin(storeName), WindowListenable]

    windowListeners:
        'resize': 'setHeight'
    setHeight: () ->
        $box = $(@refs['box']).parents('.ui-modal__content')
        $win = $ window
        $box.parents('.ui-modal__dialog').css
            'overflow': 'auto'
            'background': '#fff'
        $box.css
            'maxHeight': $win.height() - 100 + 'px'

    componentDidMount: ->
        @setHeight()

    render: ->

        store = @state[storeName]
        current = store.current_detail
        if current is null
            return <div></div>
        server_time = store.server_time
        skuPicker = store.skuPicker
        sku = skuPicker.selected_sku



        <div className="ui-modal__box presales-goods-info-modal" ref="box">
            <div className="ui-modal__title">
                商品购买
            </div>
            <div className="common-modal-box__content ui-modal__inner u-clearfix">
                <div className="goods-img span6">
                    <img src={sku.has_cover.media.full_path} />
                </div>
                <div className="span6">
                    <GoodsInfo />
                </div>
            </div>
            <div className="flow-img">
                <img src="#{staticPrefix}/images/presales-flow.png" />
            </div>
        </div>

module.exports = modal;
