var CollocationSummary = React.createClass({

    getDefaultProps: function () {
        return {
            type: 'goods'
        };
    },

    handleSettlement: function () {
        var quantity = 0, price = 0, origin = 0, save = 0;

        var goodsList = this.props.data.list;
        var discountType = this.props.data.discountType;
        var discountInfo = this.props.data.discountInfo;

        var discountKey = [];
        var discountMap = {};

        //计算原价
        goodsList.map(function (item, index) {
            if (item.selected) {
                quantity++;
                var itemPrice = SP.Math.Mul(item.sku.price, item.count, 2);
                origin = SP.Math.Add(origin, itemPrice, 2);
            }
        });

        //打折
        if (discountType === 1) {
            var discount = 0;
            discountInfo.map(function (item, index) {
                discountKey.push(item.goods_quantity);
                discountMap[item.goods_quantity] = parseFloat(item.discount);
            });
            var max = Math.max.apply(null, discountKey);

            if (quantity > max) {
                discount = discountMap[max];
            }
            else if (discountMap[quantity] !== undefined) {
                discount = discountMap[quantity];
            }
            else {
                discount = 1;
            }

            price = SP.Math.Mul(origin, discount, 2);
            save = SP.Math.Sub(origin, price, 2);
        }
        else if (discountType === 2) {
            discountInfo.map(function (item, index) {
                discountMap[item.goods_sku_id] = item.price;
            });

            goodsList.map(function (item, index) {
                var id = item.sku.id;
                var itemPrice = 0;

                if (item.selected) {
                    if (discountMap[id] !== undefined) {
                        itemPrice = SP.Math.Mul(discountMap[id], item.count, 2);
                    }
                    else {
                        itemPrice = SP.Math.Mul(item.sku.price, item.count, 2);
                    }

                    price = SP.Math.Add(price, itemPrice, 2);
                }
            });

            save = SP.Math.Sub(origin, price, 2);
        }

        if (discountType === 2 && quantity < 2) {  //主题搭配只选一件商品时不打折
            price = origin;
            save = '0.00';
        }

        return {
            quantity: quantity,
            price: price,
            origin: origin,
            save: save
        };
    },
    getParams: function () {
        var items = {};

        items.id = this.props.data.collocationId;
        items.items = {};
        var hasSelected = false;

        this.props.data.list.map(function (item, index) {
            if (item.selected) {
                items.items[item.sku.id] = item.count;
                hasSelected = true;
            }
        });
        // 主题搭配，如果未选择任何商品
        if (!hasSelected) {
            return null;
        }

        var data = {
            is_multiple: 1,
            items: JSON.stringify(items),
            quantity: 1
        };

        return data;
    },
    buyNow: function () {
        // 立即购买
        var data = this.getParams()

        ,   itemsInput = React.findDOMNode(this.refs.purchaseNowItems)
        ,   form = React.findDOMNode(this.refs.purchaseNowForm);

        if (!data) {
            SP.notice.error('您还未选择商品');
            return;
        }

        itemsInput.value = data.items;
        var $form = $(form)

        var token = window.csrf_token
        ,   $input = $form.find('input[name=_token]');

        if (!$input.length) {
            $input = '<input type="hidden" name="_token" value="' + token + '" />';
        } else {
            $input.val(token);
        }

        $form.append($input);

        if (!SP.isLogined()) {
            SP.login(function () {
                form.submit();
            });
            return;
        }

        form.submit();
    },
    buy: function () {
        // 加入购物车
        var data = this.getParams();

        if (!data) {
            SP.notice.error('您还未选择商品');
            return;
        }

        webapi.cart.add(data)
            .then(function (res) {
                if (res.code === 0) {
                    location.href = '/cart';
                }
                else {
                    SP.notice.error(res.msg);
                }
            })
            .fail(function (res) {
                SP.notice.error(res.msg);
            });
    },

    render: function () {

        var map = this.handleSettlement();

        var analyticsTheme = window.analyticsTheme || {};

        // 主题搭配使用的视图
        if (this.props.type === 'theme') {
            return (
                <form ref="purchaseNowForm" className="purchase grid grid-2" action="/quickbuy" method="post">
                    <div className="price-show">
                        <input type="hidden" name="is_multiple" value="1"/>
                        <input type="hidden" name="quantity" value="1"/>
                        <input type="hidden" name="items" ref="purchaseNowItems"/>
                        <p>已选择<em className="num">{map.quantity}</em>款商品</p>
                        <span className="desc">搭配价格：</span><em className="num">￥{map.price}</em>
                        <span className="desc u-ml_10">节省：</span><em className="num">￥{map.save}</em>
                    </div>
                    <div className="action">
                        <a className="btn btn-larger-big purchase-now" name={analyticsTheme.buyNow} href="javascript:void(0);" onClick={this.buyNow}>立即购买</a>
                        <a className="btn btn-larger-big btn-color-orange" name={analyticsTheme.addToCart} href="javascript:void(0);" onClick={this.buy}>加入购物车</a>
                    </div>
                </form>
            );
        }
        // 单个商品返回的视图
        return (
            <div className="collocation-summary u-fr">
                <p>已选择<span className="ui-emphasis">{map.quantity}</span>款商品</p>

                <p className="u-color_gray">搭配价格：<span className="u-color_price">¥ {map.price}</span></p>

                <p className="u-color_gray">原价：<span className="ui-deprecated">¥ {map.origin}</span></p>

                <p className="u-color_gray">节省：<span className="u-color_price">¥ {map.save}</span></p>
                <button className="btn btn-larger-big btn-color-orange" onClick={this.buy}>一键购买</button>
            </div>
        );
    }
});

module.exports = CollocationSummary;
