// var sipinConfig = require('sipinConfig')

require('cookie')

var webapi = require('sipin-web-api')({
    host: sipinConfig.apiHost,
    headers: {
        'X-XSRF-TOKEN': function (options) {
            var token = null
            if (options.method.toLowerCase() != 'get') {
                token = $.cookie('XSRF-TOKEN');
            }

            return token;
        }
    }
})

if (window.jQuery) {
    jQuery.ajaxPrefilter(function (options, originOptions, xhr) {
        if (options.type != 'GET' && xhr.readyState === 0) {
            xhr.setRequestHeader('X-XSRF-TOKEN', $.cookie('XSRF-TOKEN') || '');
        }

        return true
    })
    // form提交增加csrf
    $(document).on('submit.csrf_token', 'form', function () {
        if($(this).attr('method')!=="get"){
            var token = window.csrf_token || $.cookie('XSRF-TOKEN')
            ,   $input = $(this).find('input[name=_token]');

            if (!$input.length) {
                $input = '<input type="hidden" name="_token" value="' + token + '" />';
            } else {
                $input.val(token);
            }

            $(this).append($input);
        }
    })
}

module.exports = webapi;
