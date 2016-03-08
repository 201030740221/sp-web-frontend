require('modules/plugins/jquery.form')
require('modules/plugins/jquery.disable')

window.WEB_SOCKET_SWF_LOCATION = '/static/assets/WebSocketMain.swf'
var socket = require('modules/websocket/websocket');
var countdown = require('./countdown');
var captchaTpl = require('./tpl-captcha.hbs');
var Validator = require('Validator');
var validator = new Validator();
var goodsDetial = require('../../goods/detail/page');
goodsDetial.init('flash-sale-detail')

//倒计时
// var fiveDay = 5 * 24 * 60 * 60 * 1000
// var currentTime = new Date().getTime()
// ,   startTime = currentTime + fiveDay
var fixTime
,   $flashSaleTime = $('#j-flash-time')
,   startTime = $flashSaleTime.data('begintime') * 1000
,   endTime = $flashSaleTime.data('endtime') * 1000; // = countdown($('#j-flash-time'), currentTime, startTime);

var isSuccess = false
,   isParticipated = false;

// console.log('页面读取秒杀结束时间： ' ,new Date(endTime))

var flashSale = {
    'id': $('input[name=flash_sale_id]').val()
};
flashSale.constants = {
    CODE_FLASHSALE_INVALID_REQUEST: '1',
    CODE_FLASHSALE_READY:'101',
    CODE_FLASHSALE_STARTED: '102',
    CODE_FLASHSALE_ENDED: '103',
    CODE_FLASHSALE_FROZEN: '104',
    CODE_FLASHSALE_AVAILABLE: '105',
    CODE_FLASHSALE_RESERVED: '106',
    CODE_FLASHSALE_ALREADY_PARTICIPATED: '107',
    CODE_FLASHSALE_STILL_HAVE_A_CHANCE: '108',

    CODE_FLASHSALE_LOOT_RESERVED: '201',
    CODE_FLASHSALE_LOOT_FAILED: '202',
    CODE_FLASHSALE_LOOT_CAPTCHA_ERROR: '203',

    CODE_FLASHSALE_ACTION_UNFREEZE: '301'
};
// 按钮: 灰色不可用（即将开始，已秒完，秒杀结束， 还有机会） 可用（立即秒杀，立即付款，）
// 根据返回服务器时间执行倒计时
flashSale.constantNames = {
    '1': '未登录或flashSaleId有误', // 按钮为即将开始，提示请登录，正常倒计时，
    '101': '准备开始', // 按钮为即将开始，根据返回服务器时间，正常倒计时
    '102': '进行中', // 按钮为 立即秒杀，显示离结束倒计时，点击后输入验证码，send_loot到socket，然后根据socket返回，跳转下单或提示失败
    '103': '已结束', // 按钮为 秒杀结束， 倒计时0分0秒
    '104': '(冻结)已抢完,还有机会', // 走108流程
    '105': '机会来了',  // 走 102 流程
    '106': '已抢到,快付款', // 按钮为 立即付款，点击后走201流程（后端再判断是否下单或直接支付）
    '107': '已抢过', // 按钮为 已秒完，显示 离秒杀结束倒计时
    '108': '已抢完,还有机会', // 按钮 还有机会，显示 离秒杀结束倒计时
    '201': '抢购操作反馈-成功', // 成功，提交参数 type, flashSaleID 到下单页
    '202': '抢购操作反馈-失败', // 失败，提示秒杀失败，走107流程
    '203': '抢购操作反馈-失败-验证码错误', // 失败，提示验证码错误，并刷新验证码，焦点到输入框
    '301': '特殊操作-解冻' // 走 102 流程
};
var $saleBtn = $('#flash-sale-btns')
,   sale_btns = {
    '101': '<button class="btn disabled">即将开始</button>',
    '102': '<button class="btn checkout">立即秒杀</button>',
    '103': '<button class="btn disabled">秒杀结束</button>',
    '106': '<button class="btn to-pay">立即付款</button>',
    '107': '<button class="btn disabled">已参与秒杀</button>',
    '108': '<button class="btn disabled">还有机会</button>'
};
sale_btns['1'] = sale_btns['101'];
sale_btns['104'] = sale_btns['108'];
sale_btns['105'] = sale_btns['301'] = sale_btns['102'];
sale_btns['301'] = sale_btns['102'];
sale_btns['201'] = sale_btns['202'] = sale_btns['107'];

flashSale.ready = function (data) {
    $saleBtn.html(sale_btns[flashSale.constants.CODE_FLASHSALE_READY]);
    
    $('#countdown-wrap .flash-buy__title').html('离秒杀开始时间还有')
    if (fixTime) {
        fixTime(data.time)
    } else {
        fixTime = countdown($flashSaleTime.show(), data.time, startTime, function() {
            flashSale.goon(data);
        });
    }
}
flashSale.goon = function (data) {
    $('#countdown-wrap .flash-buy__title').html('离秒杀结束时间还有')

    $saleBtn.html(sale_btns[flashSale.constants.CODE_FLASHSALE_STARTED]);
    
    var $flashSaleTimeClone = $flashSaleTime.show().clone(false).addClass('time_clone');
    $flashSaleTime.replaceWith($flashSaleTimeClone);
    countdown($flashSaleTimeClone, data.time, endTime, function() {
        flashSale.end();
    });
}
flashSale.chance = function (data) {
    flashSale.goon(data)
    $saleBtn.html(sale_btns[flashSale.constants.CODE_FLASHSALE_STILL_HAVE_A_CHANCE]);
}
flashSale.end = function () {
    var $flashSaleTimeClone = $flashSaleTime.show().clone(false);
    $flashSaleTimeClone.html('<span class="ui-emphasis">0</span>分<span class="ui-emphasis">0</span>秒')
    $('#countdown-wrap').html('离秒杀结束时间还有').append($flashSaleTimeClone);

    if (isSuccess) {
        return;
    }

    $saleBtn.html(sale_btns[flashSale.constants.CODE_FLASHSALE_ENDED]);
    isParticipated = true;
}
flashSale.participated = function (data) {
    flashSale.goon(data)

    $saleBtn.html(sale_btns[flashSale.constants.CODE_FLASHSALE_ALREADY_PARTICIPATED]);
}
flashSale.fail = function (data) {
    SP.notice.error('手慢了，没秒到！')
    // console.log('fail: ', data)
}
flashSale.success = function (data) {
    if (SP.isLogined()) {
        $("#j-buy-now-form").submit()
    } else {
        SP.login(function () {
            $("#j-buy-now-form").submit()
        });
    }
        
    return false    
}

var actions = {}
actions[flashSale.constants.CODE_FLASHSALE_INVALID_REQUEST] = function (data) {
    // if (!SP.isLogined())
    //     SP.login();
    flashSale.ready(data);
}
actions[flashSale.constants.CODE_FLASHSALE_READY] = function (data) {
    flashSale.ready(data);
}
actions[flashSale.constants.CODE_FLASHSALE_STARTED] = function (data) {
    flashSale.goon(data);
}
actions[flashSale.constants.CODE_FLASHSALE_ENDED] = function (data) {
    // 活动结束
    flashSale.end(data)
}
actions[flashSale.constants.CODE_FLASHSALE_AVAILABLE] = actions[flashSale.constants.CODE_FLASHSALE_ACTION_UNFREEZE] =function (data) {
    // 活动继续
    flashSale.goon(data)
}
actions[flashSale.constants.CODE_FLASHSALE_STILL_HAVE_A_CHANCE] = function (data) {
    // 还有机会
    flashSale.chance(data)
}
actions[flashSale.constants.CODE_FLASHSALE_FROZEN] = actions[flashSale.constants.CODE_FLASHSALE_FROZEN] = function (data) {
    // 104/108
    flashSale.end(data)
}
actions[flashSale.constants.CODE_FLASHSALE_RESERVED] = function (data) {
    SP.notice.success('秒杀成功！请及时付款。');

    isSuccess = true;

    $('#countdown-wrap .flash-buy__title').html('离秒杀结束时间还有')

    countdown($flashSaleTime.show(), data.time, endTime, function() {
        flashSale.end();
    });
}
actions[flashSale.constants.CODE_FLASHSALE_ALREADY_PARTICIPATED] = function (data) {
    flashSale.participated(data);
    isParticipated = true;
}
actions[flashSale.constants.CODE_FLASHSALE_LOOT_RESERVED] = function (data) {
    // 抢成功
    flashSale.success(data)
}
actions[flashSale.constants.CODE_FLASHSALE_LOOT_FAILED] = function (data) {
    // 抢失败
    flashSale.fail(data);
}
actions[flashSale.constants.CODE_FLASHSALE_LOOT_CAPTCHA_ERROR] = function () {
    // 验证码错误
    $saleBtn.find('.flash-sale-captcha-img').trigger('click');
    $('#flash-sale-captcha-input').val('').focus();
    SP.notice.error('验证码错误，请重新输入')
}

flashSale.actions = actions;

var socket_url = SP.config.websocket || 'ws://push.sipin.test2';
var channel = new socket({
    url: socket_url
});
channel.on('open', function () {
    // console.log('opening socket...')
});
channel.on('close', function () {
    // console.log('closing socket...')
    if (SP.isLogined() && !isParticipated) {
        channel.reconnect()
    }
});
channel.on('message', function (resp, e) {
    // console.log('resp: ', resp)
    var code = resp.code
    ,   data = resp.data || {}
    ,   action = flashSale.actions[code];

    // php时间戳单位是秒
    if (!data.time)
        data.time = + new Date;
    else 
        data.time *= 1000

    $saleBtn.html(sale_btns[code]);

    if (action) {
        action(data);
    }

    // console.log('页面读取秒杀结束时间 in onmessage： ' ,new Date(endTime))
    // console.log('::: ', !data.time , 'endTime: ', new Date(endTime), '  current time:', new Date(data.time * 1000))

    // if (code != flashSale.constants.CODE_FLASHSALE_ENDED && endTime < data.time) {
    //     flashSale.end()
    //     return;
    // }
});
channel.on('loot', function (resp, e) {
    // console.log('resp: ', resp)
    var code = resp.code
    ,   data = resp.data || {}
    ,   action = flashSale.actions[code];

    if (action) {
        action(data);
    }
})

channel.on('ping', function (data, e) {
    channel.send({type: 'pong'})
})

SP.helloed.add(function () {
    channel.connect(function () {
        channel.send({"type":"connect", "userKey": SP.member.user_key || '', "flashSaleId": flashSale.id || ''})
    })
});

// 秒杀按钮
var captcha_url = SP.config.host + '/api/flash-sale/captcha?flash_sale_id=' + flashSale.id
function get_captcha() {
    return captcha_url + '&user_key=' + SP.member.user_key + '&r=' + new Date()
}
function show_captcha() {
    // 显示验证码
    var $captcha = $saleBtn.find('.flash-sale-captcha')

    if (! $captcha.length) {
        $captcha = captchaTpl({
            captcha: get_captcha()
        })
        $saleBtn.html($captcha)
    }

    $('#flash-sale-captcha-input').focus();
}
function send_loot(captcha) {
    if (!captcha) {
        return
    }
    var req = {"type":"loot","userKey": SP.member.user_key, "flashSaleId": flashSale.id, 'captcha': captcha};

    channel.send(req);
}
function send_status() {
    channel.send({"type":"status","userKey": SP.member.user_key, "flashSaleId": flashSale.id});
}
$saleBtn.on('click', '.checkout', function () {
    if (! SP.isLogined()) {
        SP.login(function () {
            console.log('isclosed: ',channel.isClosed(), channel.ws.readyState )
            if (channel.isClosed()) {
                channel.reconnect()
            }
        });

        return;
    };
    show_captcha();
}).on('click', '.to-pay', function () {
    flashSale.success();
}).on('click', '.flash-sale-captcha-img', function () {

    var $img = $(this).children('img');
    $img.attr('src', get_captcha());

}).on('click', '#flash-sale-sure', function() {

    var $captcha_input = $('#flash-sale-captcha-input')
    ,   captcha = $.trim($captcha_input.val());

    if (!captcha || captcha.length !== 5) {
        $captcha_input.focus();
        return;
    }

    send_loot(captcha);
}).on('keyup', '#flash-sale-captcha-input', function (e) {
    if (e.keyCode === 13) {
        $('#flash-sale-sure').click();
    }
});

$('#flash-sale-refresh').on('click', function () {
    if (! SP.isLogined()) {
        SP.login(function () {
            send_status();
        });

        return;
    };
    send_status();
});

//设置短信通知表单
var $noticeTrigger = $("#j-flash-setting");
var $noticeTriggerCancel = $(".flash-notice__cancel");
var $noticeSection = $("#j-flash-notice");
var $form = $noticeSection.find("form");
var $phoneInput = $form.find("input[name='mobile']");
var $noticeError = $(".notice-error");

function noticed() {
    $noticeTrigger.html('已设置').disable().append(' <span>我们将会在活动当天秒杀前30分钟以短信的形式通知您。</span>');
    $noticeSection.remove();
}

$noticeTrigger.on("click", function (e) {
    e.preventDefault();

    if ($(this).isDisabled()) {
        return;
    }

    var now = +new Date
    ,   diff = startTime - now
    ,   thirdtyMins = 30 * 60 * 1000
    if (diff < thirdtyMins) {
        SP.notice.error('手机提醒时间已结束');
        return;
    }

    if (!SP.isLogined()) {
        SP.login();
        return;
    }

    var pathname = location.pathname
    ,   sliceIndex = pathname.lastIndexOf('/') + 1
    ,   sku_sn_str = pathname.slice(sliceIndex)
    ,   sku_sn = sku_sn_str.replace('.html', '');
    webapi.activity.flashSaleDetail({
        'sid': sku_sn//flashSale.id // 借用手机端获取详情接口，需传sku
    }).then(function (res) {
        if (res.code != 0) {
            // console.log('获取秒杀提醒状态失败：', res.msg)
            return;
        }

        if (res.data && res.data.flashsale.mobile_bound) {
            noticed()
        } else {
            $noticeSection.slideDown();
        }
    })
});

$noticeTriggerCancel.on("click", function (e) {
    e.preventDefault();
    $noticeSection.slideUp();
});

$form.on("submit", function (e) {
    e.preventDefault();

    if ($form.isDisabled()) {
        return;
    }
    
    var params = $form.serializeMap();

    params.mobile = $.trim(params.mobile)

    if (! $.trim(params.mobile)) {
        $noticeError.html('请填写手机号码').show();
        return;
    }
    if (!validator.methods.phone(params.mobile)) {
        $noticeError.html('手机号码格式错误').show();
        return;
    }
    $noticeError.hide();

    webapi.activity.noticeRegister(params).then(function () {
        SP.notice.success('设置提醒成功');
        noticed()

        $form.disable();
    })
});

$phoneInput.on("focus", function(e) {
   $noticeError.hide();
});
