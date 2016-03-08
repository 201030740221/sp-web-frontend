var Input = React.createClass({
    getDefaultProps: function () {
        return {
            canUsePlaceholder: 'placeholder' in document.createElement('input')
        }
    },
    onClick: function (e) {
        var $wrap = e.target.parentNode;

        if (! $wrap) return;

        var $input = $wrap.querySelector('input')
        ,   $label = $wrap.querySelector('.placeholder-label');

        if ($label) {
            $label.style.display = 'none';
        }
        
        $input.focus();
    },
    onBlur: function (e) {
        var $input = e.target
        ,   $wrap = $input.parentNode
        ,   $label = $wrap.querySelector('.placeholder-label')
        ,   onblur = this.props.onBlur;

        if ($label && !$input.value.replace(/\s+/g, '')) {
            $label.style.display = 'block'
        }

        onblur && onblur.call($input, e)
    },
    onFocus: function (e) {
        var $input = e.target
        ,   $wrap = $input.parentNode
        ,   $label = $wrap.querySelector('.placeholder-label')
        ,   onfocus = this.props.onFocus;

        if ($label) {
            $label.style.display = 'none';
        }
        onfocus && onfocus.call($input, e);
    }, 
    render: function() {
        var  _input = <input {...this.props} />
        ,   placeholder = this.props.placeholder;

        if (!this.props.canUsePlaceholder && placeholder) {

            _input = (
                <span className="placeholder-wrap" onClick={this.onClick}>
                    <input {...this.props}  onBlur={this.onBlur} onFocus={this.onFocus} />
                    <i className="placeholder-label">{placeholder}</i>
                </span>
            )
        }

        return _input;
    }

});

module.exports = Input;