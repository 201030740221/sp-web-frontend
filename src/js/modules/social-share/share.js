var weiboUrlPrefix = 'http://service.weibo.com/share/'+(/android|webos|ip(hone|ad|od)|opera (mini|mobi|tablet)|iemobile|windows.+(phone|touch)|mobile|fennec|kindle (Fire)|Silk|maemo|blackberry|playbook|bb10\; (touch|kbd)|Symbian(OS)|Ubuntu Touch/i.test(navigator.userAgent)?'mobile':'share')+'.php?';
var isInWeixin = false;

//  weibo options
//  
//  title或text [类型String] 分享内容，无需encodeURI
//  url [类型String] 分享链接，无需encodeURI
//  pic [类型String] 分享图片的url，无需encodeURI。新浪的接口多张图片尚未完全开放，暂时只能分享一张
//  ralateUid [类型String 或 Number] 相关微博Uid，如果有此项，分享内容会自动 @相关微博
//  appkey [类型String 或 Number] 分享来源的appkey，如果有此项，会在微博正文地下，显示“来自XXX”
//  
//  weixin options
//  
//  appid 公众号id，发送给朋友需要此id，分享到朋友圈不需要
//  title: 标题
//  desc: 分享内容
//  link: 分享链接
//  img_url: 图片地址
var translateOpts = function (options, social) {
    var opts = {};

    // weibo和weixin相同部分

    if (social == 'weibo') {
        opts.title = options.weibo_content;
        opts.url = options.link;
        opts.pic = options.image;
        opts.appkey = options.weiboAppKey;
        opts.ralateUid = options.weiboRalateUid;
    }

    if (social == 'weixin') {
        opts.title = options.weixin_title;
        opts.appid = options.weixinAppId;
        opts.desc = options.weixin_content;
        opts.link = options.link;
        opts.img_url = options.image;
    }

    return opts;
}

var getWeiboShareUrl = function (options) {
    var key, urlArray = [];

    for (key in options) {
        switch (key) {
            case 'url':
            case 'pic':
            case 'title':
                urlArray.push(key + '=' + encodeURIComponent(options[key]));
                break;
            case 'ralateUid':
            case 'appkey':
                urlArray.push(key + '=' + options[key]);
                break;
        }
    }
    return weiboUrlPrefix + urlArray.join('&');
}
/**
 * 微博、微信分享
 * @param {[type]} options 可设置项如下
var options = {
    'link': '分享链接',
    'image': '分享图片地址',

    'weixinAppId': null,  // 微信为appid
    'winxin_title': '微信分享标题',
    'weixin_content': '微信分享内容'

    'weiboAppKey': '1229563682', // 微博为appKey
    'weibo_content': '新浪分享内容',
    'weiboRalateUid': ''  // 相关微博Uid，如果有此项，分享内容会自动 @相关微博
}
 */
function Share(options, shared) {
    this.options = options;
    this.shared = shared || function () {};

    options.link = options.link || location.href;
    options.weiboAppKey = options.weiboAppKey || '1229563682';

    document.addEventListener('WeixinJSBridgeReady', function onBridgeReady() {
        isInWeixin = true;
        weixinOpts = translateOpts(options, 'weixin');

        // 发送给好友 
        WeixinJSBridge.on('menu:share:appmessage', function(argv) {
            WeixinJSBridge.invoke('sendAppMessage', weixinOpts, function (res) {
                alert(res.err_msg)
                shared();
            });
        });

        // 分享到朋友圈 
        WeixinJSBridge.on('menu:share:timeline', function(argv) {
            WeixinJSBridge.invoke('shareTimeline', weixinOpts, function (res) {
                alert(res.err_msg)
                shared();
            });
        });
    }, false);
};
/**
 * 新浪分享方法
 * @return {[type]} [description]
 */
Share.prototype.toWeibo = function() {
    var shareUrl = getWeiboShareUrl(translateOpts(this.options, 'weibo'));
    window.open(shareUrl);
    this.shared();
};
/**
 * 微信分享方法
 * @param  {[Function]} tip 可选，自定义弹出提示
 */
Share.prototype.toWeixin = function(tip) {
    var options = this.options;
    if (tip) {
        tip.call(this, isInWeixin);
        return;
    }

    if (isInWeixin) {
        alert('请点击右上角，选择分享到好友或朋友圈');
        return;
    }

    // PC端弹框
    if (window.jQuery && jQuery.Modal) {
        var $content = $(['<div style="padding: 10px;height: 120px;">',
                '<img alt="二维码" width="100" style="float:left;margin: 0 10px 0 0;" />',
                '<p style="padding-top: 10px;overflow: hidden;font-size: 14px;">打开微信，点击“发现”，使用“扫一扫”功能扫码二维码。<br> 打开页面后点击右上角的“...” 分享到微信好友或者朋友圈。</p>',
            '</div>'
        ].join(''));

        var $qrcode = $content.find('img');

        if (this.weixin_qrcode_modal) {
            this.weixin_qrcode_modal.show();
            return;
        } 

        webapi.tools.qrcode({
            url: options.link
        }).then(function (src) {
            $qrcode.attr('src', src);

            this.weixin_qrcode_modal = $.Modal({
                'title': '分享到微信',
                'content': $content[0].outerHTML,
                'width': 360
            }); 
        }.bind(this));
    };

    this.shared();
};

module.exports = Share;
