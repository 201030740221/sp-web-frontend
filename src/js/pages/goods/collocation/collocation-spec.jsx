var handleSkuMap = require('./handle-sku-map');

var CollocationSpec = React.createClass({
    mixins: [handleSkuMap],
    getInitialState: function () {
        return {
            selected: this.getSpecKey(),
            count: this.props.data.count,
            isEditing: false,
            onSale: true
        };
    },

    newSkuSn: '',

    componentDidMount: function () {
        $(document).on('spec.edit', function (e, id) {
            if (id === this.props.data.goodsId) {
                this.setState({
                    isEditing: !this.state.isEditing
                });
            }
        }.bind(this));
    },

    componentWillUnmount: function () {
        $(document).off('spec.edit');
    },

    getSpecKey: function (attribute_key) {
        var activeItems = [];
        var keys = attribute_key || this.props.data.sku.attribute_key;
        keys = keys.split(',');

        this.props.data.skuData.map(function (item1, index) {
            item1.value.map(function (item2, index) {
                var key = item2.attribute_id + '-' + item2.id;
                if (keys.indexOf(key) !== -1) {
                    activeItems.push(item2);
                }
            });
        });

        return activeItems;
    },

    getSkuMap: function () {
        this.SKUResult = {};
        this.initSKU(this.props.data.goodsSku);
    },

    querySku: function (values) {
        var keyArray = [];
        var sortFunc = function (a, b) {
            return parseInt(a) - parseInt(b);
        };
        values.map(function (item, index) {
            keyArray.push(item.id);
        });
        keyArray = keyArray.sort(sortFunc).join(';');
        this.getSkuMap();
        if (this.SKUResult[keyArray]) {
            return this.SKUResult[keyArray];
        }
        return null;
    },

    handleSelect: function (item) {
        var selected = this.state.selected.filter(function (stateItem) {
            return item.attribute_id !== stateItem.attribute_id;
        });
        selected.push(item);

        var sku = this.querySku(selected);

        if (sku && sku.status) {
            this.newSkuSn = sku.skuSn;
            this.setState({
                selected: selected,
                onSale: true
            });
        }
        else {
            sku = this.querySku([item]);
            if (sku && sku.status) {
                this.newSkuSn = sku.skuSn;
                this.props.data.goodsSku.map(function (item1, index) {
                    if (item1.sku_sn === sku.skuSn) {
                        this.setState({
                            selected: this.getSpecKey(item1.attribute_key),
                            onSale: true
                        });
                    }
                }.bind(this));
            }
            else {
                SP.notice.error('该款已下架！');
                this.setState({
                    // selected: [item],
                    onSale: false
                });
            }
        }
    },

    handleCount: function (sku, trigger) {
        var count = this.state.count;
        if (trigger === '+') {
            count++;
        }
        else if (trigger === '-') {
            if (count < 2) {
                return null;
            }
            else {
                count--;
            }
        }

        this.setState({
            count: count
        });
    },

    handleSpec: function (done, id) {
        var data = {};
        data.goodsId = id;

        if (done === 'cancel') {
            this.setState({
                selected: this.getSpecKey(),
                count: this.props.data.count
            });
        }
        else if (done === 'sure') {
            if (!this.state.onSale) {
                SP.notice.error('该款已下架！');
                return null;
            }
            data.skuSn = this.newSkuSn;
            data.count = this.state.count;
            $(document).trigger('spec.done', data);
        }

        this.setState({
            isEditing: !this.state.isEditing
        });
    },

    render: function () {
        var _this = this;

        var specs = this.props.data.skuData.map(function (item1, index) {
            if (!item1.value.length) {
                return null;
            }
            return (
                <div key={item1.id} className="spec">
                    <span className="title">{item1.name}：</span>
                    {item1.value.map(function (item2, index) {
                        var classString = 'spec__item';
                        classString += _this.state.selected.indexOf(item2) !== -1 ? ' _active' : '';
                        return (
                            <span key={item2.id}
                                  className={classString}
                                  onClick={_this.handleSelect.bind(null, item2)}>{item2.attribute_value}</span>
                        )
                    })}
                </div>
            )
        });

        var amount = function () {
            // 配合双11活动，14号之前禁止掉数量选择功能
            // if (DATE.lt('2015-11-14 0:0:0')) {
            return null;
            // }

            return (
                <div className="quantity">
                    <span className="title">数量：</span>
                    <span className="ui-emphasis">{this.state.count}</span>
                    <span className="quantity__item"
                          onClick={this.handleCount.bind(null, this.props.data.goodsId, '+')}>+</span>
                    <span className="quantity__item"
                          onClick={this.handleCount.bind(null, this.props.data.goodsId, '-')}>－</span>
                </div>
            )
        }.bind(this);

        return (
            <div className="collocation__spec" style={{display: this.state.isEditing ? 'block' : 'none'}}>
                {specs}
                {amount()}
                <div className="select">
                    <span className="select__item"
                          onClick={this.handleSpec.bind(null, 'sure', this.props.data.goodsId)}>确定</span>
                    <span className="u-color_gray">|</span>
                    <span className="select__item"
                          onClick={this.handleSpec.bind(null, 'cancel', this.props.data.goodsId)}>取消</span>
                </div>
            </div>
        )
    }
});

module.exports = CollocationSpec;
