var CollocationList = require('./collocation-list');
var CollocationSummary = require('./collocation-summary');

var Collocation = React.createClass({
    getInitialState: function () {
        return {
            setIndex: 0,
            goodsList: this.getGoodsList()
        };
    },

    getDefaultProps: function () {
        return {
            'type': 'goods' // or theme， 目前两种：商品搭配，主题搭配
        };
    },

    componentDidMount: function () {
        $(document)
            .on('spec.done', function (e, data) {
                this.updateSku(data);
            }.bind(this));
    },

    componentWillUnmount: function () {
        $(document).off('spec');
    },

    //获取所有套餐信息
    getCollocationInfo: function () {
        var set = [];
        this.props.data.map(function (item, i) {
            set.push({
                id: item.id,
                name: item.goods_collocation.name
            });
        });
        return set;
    },

    getSku: function (goods, skuid) {
        var index = 0
        ,   skuList = goods.goods_sku;

        if (skuid) {
            skuList.every(function (item, i) {
                if (item.id == skuid) {
                    index = i;
                    return false;
                }
                return true;
            });
        }
        else {
            skuList.every(function(item, i) {
                if (item.sku_status) {
                    index = i;
                    return false;
                }
                return true;
            });
        }

        return skuList[index];
    },
    //获取当前套餐商品信息
    getGoodsList: function (index) {
        var setIndex = index ? index : 0;
        var goodsList = {};
        var set = this.props.data[setIndex];
        var goodsInfo = set.goods_collocation.goods_collocation_details;

        goodsList.collocationId = set.goods_collocation.id;
        goodsList.discountType = set.goods_collocation.type;
        goodsList.discountInfo = set.goods_collocation.goods_collocation_rules;

        goodsList.list = [];

        // 主题商品需要过滤一下，拿到相应的信息数组
        // 因为主题商品数组长度可能小于组合商品的信息
        if (this.props.type === 'theme') {
            goodsInfo = goodsInfo.filter(function (item) {
                // set.theme_collocation_goods
                var i = 0
                ,   l = set.theme_collocation_goods.length
                ,   hasThemeGoods = false
                ,   themeGoods;

                for (; i < l; i++) {
                    themeGoods = set.theme_collocation_goods[i];

                    if (themeGoods.goods_sku.goods.id == item.goods.id) {
                        hasThemeGoods = true;
                        // 顺便设定默认skuid
                        item.defaultSkuId = themeGoods.goods_sku.id;
                        break;
                    }
                }

                return hasThemeGoods;
            });
        }

        goodsInfo.forEach(function (item, index) {
            var goodsItem = {};
            // 标记主商品，用于区分主题搭配和商品推荐的主商品
            goodsItem.isPrimary = set.primary_goods_id == item.goods.id;

            // 推荐搭配由调用处提供skuid指定显示(主商品)的sku，主题搭配由数据读取显示指定sku
            var defaultSkuId = goodsItem.isPrimary ? this.props.skuid : null;

            if (this.props.type === 'theme') {
                // 用上面过滤时顺便获取的默认sku
                defaultSkuId = item.defaultSkuId;
            }

            goodsItem.goodsId = item.goods.id;
            goodsItem.sku = this.getSku(item.goods, defaultSkuId);
            goodsItem.title = item.goods.title;
            goodsItem.subtitle = item.goods.subtitle;
            goodsItem.selected = true;
            goodsItem.count = 1;
            goodsItem.goodsSku = item.goods.goods_sku;
            goodsItem.skuData = item.goods.skuData;

            goodsList.list.push(goodsItem);

        }.bind(this));

        return goodsList;
    },

    //选择规格后更新sku
    updateSku: function (data) {
        var goodsList = this.state.goodsList;
        goodsList.list.map(function (item1, index) {
            if (item1.goodsId === data.goodsId) {
                if (data.count) {
                    item1.count = data.count;
                }
                if (data.skuSn) {
                    item1.goodsSku.map(function (item2, index) {
                        if (item2.sku_sn === data.skuSn) {
                            item1.sku = item2;
                        }
                    });
                }
            }
        });
        if (data.skuSn || data.count) {
            this.setState({
                goodsList: goodsList
            });
        }
    },

    //套餐切换
    handleTabEvent: function (index) {
        this.setState({
            setIndex: index,
            goodsList: this.getGoodsList(index)
        });
    },

    //选择某个商品
    handleSkuSelect: function (id) {
        var goodsList = this.state.goodsList;
        goodsList.list.map(function (item, index) {
            if (item.goodsId === id) {
                item.selected = !item.selected;
            }
        });
        this.setState({
            goodsList: goodsList
        });
    },

    render: function () {
        var tabs = this.getCollocationInfo().map(function (item, index) {
            var active = index === this.state.setIndex ? ' _active' : '';
            return <span key={index}
                         className={'tabs__item u-mr_20' + active}
                         onClick={this.handleTabEvent.bind(null, index)}>{item.name}</span>
        }.bind(this));

        return (
            <div className="collocation u-clearfix">
                <h1>搭配商品</h1>
                <div className="collocation-content u-fl u-clearfix">
                    <div className="tabs u-mb_10">{tabs}</div>
                    <CollocationList {...this.props} data={this.state.goodsList.list}
                                     handleSkuSelect={this.handleSkuSelect}/>
                </div>
                <CollocationSummary type={this.props.type} data={this.state.goodsList}/>
            </div>
        )
    }
});

module.exports = Collocation;
