/**
 * Img, 图片，提供缩略图地址
 * @tofishes
 * @type {[type]}
 * @usage:
 * <Img src="原图地址" w={100} h={100} />
 */
var React = require('react');

var Img = React.createClass({
    propTypes: {
        'w': React.PropTypes.number,
        'h': React.PropTypes.number
    },

    getDefaultProps: function () {
        return {
            'w': null,
            'h': null
        };
    },

    render: function() {
        var src = SP.getThumb(this.props.src, this.props.w, this.props.h);

        return (
            <img {...this.props} src={src} />
        );
    }

});

module.exports = Img;
