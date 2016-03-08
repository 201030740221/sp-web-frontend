var liteModalBox = require('liteModalBox');
var sinaWeiboShare = require('modules/sinaWeiboShare/sinaWeiboShare');

var need_login = function () {
    SP.login()
}

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

function selection($target) {
    if ($target[0].select)
        return $target[0].select();
    if (document.selection) {
        var range = $target[0].createTextRange();
        range.moveStart("character", 0);
        range.select();
    }
}

//推荐模块分享
var shareModal = new liteModalBox({
    top: 250,
    width: 400,
    mask: true,
    title: '推荐到微信',
    contents: '<div id="comment-service-tmpl"></div>',
    closeBtn: true,
    maskClose: true
});

$('#comment-service-tmpl').html([
    '<div class="clearfix">',
    '<img id="weixin-qrcode-referral-img" src="http://www.sipin.com/static/images/qrcode/weixin-sipin-life-s.png" alt="二维码" class="u-fl u-mr_10"/>',
    '<p class="u-pt_10">打开微信，点击“发现”，使用<br>“扫一扫”功能扫描二维码。<br>打开页面后点击右上角的"..."<br/>分享到微信好友或者朋友圈。</p>',
    '</div>'
].join(''));

var $link = $('#j-share-link')
    , link = '';

var $qrcode = $('#weixin-qrcode-referral-img');

var shareData = {
    title: '送礼啦！ 推荐好友注册拿积分，积分换礼品。现在登录斯品家居商城成功推荐一位好友注册即可获得500积分，更有Apple Watch大奖等你抽，快来参与吧！',// 分享标题
    link: link, // 分享链接
    imgUrl: 'http://7viii7.com2.z0.glb.qiniucdn.com/2015/07/15/a4c06ccc_apple-watch.png', // 分享图标
    weiboAppKey: "1229563682"
};

function setReferralQrcode() {
    webapi.tools.qrcode({
        url: link
    }).then(function (src) {
        $qrcode.attr('src', src)
    }, function () {
        $qrcode.attr('src', 'http://www.sipin.com/static/images/qrcode/weixin-sipin-life-s.png')
    });
}

SP.helloed.add(function () {
    if (!SP.isLogined()) {
        return;
    }
    webapi.referral.getShareLink().then(function (res) {
        $link.val(res.data.link);
        shareData.link = link = $link.val();
        setReferralQrcode()
    });
});

$(document).on('click', '#j-copy-link', function (e) {
    e.preventDefault();
    if (SP.isLogined()) {
        selection($link);
        copyToClipboard(link);
    }
    else {
        need_login()    }
}).on('click', '#j-share-weibo', function (e) {
    e.preventDefault();
    if (SP.isLogined()) {
        sinaWeiboShare.action({
            text: shareData.title,
            url: shareData.link,
            pic: shareData.imgUrl, // 分享图标
            appkey: shareData.weiboAppKey
        });
    }
    else {
        need_login()
    }
}).on('click', '#j-share-weixin', function (e) {
    e.preventDefault();
    if (SP.isLogined()) {
        shareModal.show();
    }
    else {
        need_login()
    }
});


//抽奖模块分享
var lotteryShareLink = window.location.href;
var lotteryShareData = {
    title: '免费赢取Apple Watch！快来参与斯品家居商城抽奖活动，100%中奖概率哦！',// 分享标题
    link: lotteryShareLink, // 分享链接
    imgUrl: 'http://7viii7.com2.z0.glb.qiniucdn.com/2015/07/15/a4c06ccc_apple-watch.png', // 分享图标
    weiboAppKey: "1229563682"
};

var lotteryShareModal = new liteModalBox({
    top: 250,
    width: 400,
    mask: true,
    title: '分享获得抽奖次数',
    contents: '<div id="wx-share-tmpl"></div>',
    closeBtn: true,
    maskClose: true
});

$('#wx-share-tmpl').html([
    '<div class="clearfix">',
    '<img id="wx-share-img" src="http://www.sipin.com/static/images/qrcode/weixin-sipin-life-s.png" alt="二维码" class="u-fl u-mr_10"/>',
    '<p class="u-pt_10">打开微信，点击“发现”，使用<br>“扫一扫”功能扫描二维码。<br>打开页面后点击右上角的"..."<br/>分享到微信好友或者朋友圈。</p>',
    '</div>'
].join(''));

var $lotteryQrcode = $("#wx-share-img");
webapi.tools.qrcode({
    url: lotteryShareLink
}).then(function (src) {
    $lotteryQrcode.attr('src', src);
});

var $remainingTimes = $("#j-lottery__count");
$(document).on('click', '#j-lottery-weixin', function (e) {
    e.preventDefault();
    if (SP.isLogined()) {
        lotteryShareModal.show();
        webapi.lottery.setAttendance(LOTTERY_ID, 1)
            .then(function(res) {
                $remainingTimes.text(res.data.remaining_times);
            })
    }
    else {
        need_login()
    }
}).on('click', '#j-lottery-weibo', function (e) {
    e.preventDefault();
    if (SP.isLogined()) {
        sinaWeiboShare.action({
            text: lotteryShareData.title,
            url: lotteryShareData.link,
            pic: lotteryShareData.imgUrl, // 分享图标
            appkey: lotteryShareData.weiboAppKey
        });
        webapi.lottery.setAttendance(LOTTERY_ID, 2)
            .then(function(res) {
                $remainingTimes.text(res.data.remaining_times);
            })
    }
    else {
        need_login()
    }
});
