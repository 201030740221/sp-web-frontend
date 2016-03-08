var liteModalBox = require('liteModalBox');
var sinaWeiboShare = require('modules/sinaWeiboShare/sinaWeiboShare');

var shareModal = new liteModalBox({
    top: 250,
    width: 400,
    mask: true,
    title: '扫描二维码：分享到微信',
    contents: '<div id="comment-service-tmpl"></div>',
    closeBtn: true,
    maskClose: true
});

$('#comment-service-tmpl').html([
    '<div class="clearfix">',
        '<img id="weixin-qrcode-referral-img" alt="二维码" width="100" class="u-fl u-mr_10"/>',
        '<p class="u-pt_10">打开微信，点击“发现”，<br>使用“扫一扫”，<br>将生成的页面分享出去即可。</p>',
    '</div>'
].join(''));

function _alert(msg) {
    alert(msg);
}
function copyToClipboard(txt) {
    if (window.clipboardData) {
        window.clipboardData.clearData();
        clipboardData.setData("Text", txt);
        _alert("复制成功！");

    } else if (window.netscape) {
        try {
            netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
        } catch (e) {
            _alert("被浏览器拒绝！\n请在浏览器地址栏输入'about:config'并回车\n然后将 'signed.applets.codebase_principal_support'设置为'true'");
        }
        var clip = Components.classes['@mozilla.org/widget/clipboard;1'].createInstance(Components.interfaces.nsIClipboard);
        if (!clip)
            return;
        var trans = Components.classes['@mozilla.org/widget/transferable;1'].createInstance(Components.interfaces.nsITransferable);
        if (!trans)
            return;
        trans.addDataFlavor("text/unicode");
        var str = new Object();
        var len = new Object();
        var str = Components.classes["@mozilla.org/supports-string;1"].createInstance(Components.interfaces.nsISupportsString);
        var copytext = txt;
        str.data = copytext;
        trans.setTransferData("text/unicode", str, copytext.length * 2);
        var clipid = Components.interfaces.nsIClipboard;
        if (!clip)
            return false;
        clip.setData(trans, null, clipid.kGlobalClipboard);
        _alert("复制成功！");
    } else {
        _alert('您的浏览器不支持自动复制，请您手动复制！');
    }
}
function selection($target){
    if ($target[0].select)
        return $target[0].select();
    if (document.selection) {
        var range = $target[0].createTextRange()
        range.moveStart("character",0);
        range.select();
    }
}

var $link = $('#referral-link')
,   link = $link.val();

var shareData = {
    title: '送礼啦！ 推荐好友注册拿积分，积分换礼品。现在登录斯品家居商城成功推荐一位好友注册即可获得500积分，更有Apple Watch大奖等你抽，快来参与吧！',// 分享标题
    link: link, // 分享链接
    imgUrl: 'http://7viii7.com2.z0.glb.qiniucdn.com/2015/07/11/f4d8332b_weibo_referral.jpg', // 分享图标
    weiboAppKey: "1229563682"
};

var $qrcode = $('#weixin-qrcode-referral-img');
webapi.tools.qrcode({
    url: link
}).then(function (src) {
    $qrcode.attr('src', src)
}, function () {
    $qrcode.attr('src', 'http://www.sipin.com/static/images/qrcode/weixin-sipin-life-s.png')
});

$(document).on('click', '#select-referral-link', function () {
    selection($link);
    copyToClipboard(link);
}).on('click', '.share-weixin', function () {
    shareModal.show();

}).on('click', '.share-weibo', function(){
    sinaWeiboShare.action({
        text: shareData.title,
        url: shareData.link,
        pic: shareData.imgUrl, // 分享图标
        appkey: shareData.weiboAppKey
    });
});
