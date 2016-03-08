var CollocationSpec = require('./collocation-spec');

var getQiniuThumb = function (img_url) {
    return img_url + '?imageView2/2/w/360/h/360';
}
var CollocationList = React.createClass({
    getInitialState: function () {
        return {
            page: 1,
            pageSize: 3
        }
    },

    getDefaultProps: function () {
        return {
            rowSize: 2 // 主题搭配中的一行几个商品
        }
    },

    componentWillReceiveProps: function (nextProps) {
        if (nextProps.data.collocationId !== this.props.data.collocationId) {
            this.setState({
                page: 1
            })
        }
    },

    switcher: function (dir) {
        var page = this.state.page;
        var length = this.props.data.length;

        if (dir === 'next') {
            if (page * this.state.pageSize >= length) {
                return null
            }
            else {
                page ++
            }
        }
        else if (dir === 'prev') {
            if (page === 1) {
                return null
            }
            else {
                page --
            }
        }

        this.setState({
            page: page
        })
    },

    handleSpec: function (id) {
        $(document).trigger('spec.edit', id);
    },

    render: function () {
        var count = this.props.data.length
        ,   lastSite = count % this.props.rowSize;

        lastSite = lastSite || this.props.rowSize; // 得到最后一行的数目

        var items = this.props.data.map(function (item, i) {
            var check = item.selected ? 'ui-checkbox _active' : 'ui-checkbox';
            var display = 'none';

            if (i >= (this.state.page - 1) * this.state.pageSize && i < this.state.page * this.state.pageSize) {
                display = 'block';
            }

            var actions = '', itemClass = "collocation__item u-fl";

            if (!item.isPrimary) {
                actions = <div className="collocation__action">
                            <span className={check} onClick={this.props.handleSkuSelect.bind(null, item.goodsId)}>搭配购买</span>
                            <span className="u-ml_10 u-mr_10">|</span>
                            <span className="change-sku" onClick={this.handleSpec.bind(null, item.goodsId)}>修改规格</span>
                        </div>
            }

            if (count - lastSite <= i) {
                itemClass += ' last-site'
            }

            item.sku.url = item.sku.url || ('/item/' + item.sku.sku_sn + '.html');

            return (
                <div key={item.goodsId} className={itemClass} style={{display: display}}>
                    <a href={item.sku.url} target="_blank"><img src={item.sku.has_cover ? getQiniuThumb(item.sku.has_cover.media.full_path) : ''} alt={item.title}/></a>
                    <div className="collocation__caption">
                        <h2 className="collocation__title u-ellipse">
                            <a href={item.sku.url} target="_blank">{item.title}</a>
                        </h2>

                        <p className="collocation__text u-ellipse">{item.sku.attribute_name}</p>
                        <p className="collocation__price">
                            原价：<span className="ui-deprecated">¥{item.sku.price}</span>
                        </p>
                        <p className="collocation__count u-color_gold">
                            数量：<span>{item.count}</span>
                        </p>
                        {actions}
                        <CollocationSpec data={item}/>
                    </div>
                </div>
            )
        }.bind(this));

        return (
            <div className="collocation-wrap u-clearfix">
                {items}
                <span className="prev" onClick={this.switcher.bind(null, 'prev')}></span>
                <span className="next" onClick={this.switcher.bind(null, 'next')}></span>
            </div>
        )
    }
});

module.exports = CollocationList;
