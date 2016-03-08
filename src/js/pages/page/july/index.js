var ModalBox = require('ModalBox');
var validate = require('validate');
var Tab = require('Tab');
var Lottery = require('../lottery/lottery');

require('./share');
require('./aside');
require('./flash');

//积分兑换模块
var $goodsItem = $('.goods-grid__item');
$goodsItem.on('click', '._activity-btn', function (e) {
    e.preventDefault();

    if ($(this).hasClass('_gray')) {
        return;
    }

    var $theGoodsItem = $(e.delegateTarget);
    var goodsName = $theGoodsItem.find('.goods-info__name').text();
    var point = $theGoodsItem.find('.goods-caption__title').data('point');
    var param = {
        goods_sku_id: $theGoodsItem.data('sku-id'),
        goods_sku_quantity: 1
    };

    if (SP.isLogined()) {
        webapi.cart.add(param)
            .then(function (res) {
                if (res.code === 0) {
                    SP.notice.success('礼品已经成功加入购物车');
                    SP.trigger(SP.events.cart_goods_quantity_update, res.data.total_quantity);
                }
                else {
                    SP.notice.error('积分不足！');
                }
            });
    } else {
        SP.login();
    }
    return false;
});


//签到
var $signBtn = $('#j-sign-btn');
var $remainingTimes = $('#j-lottery__count');
webapi.lottery.checkAttendance(LOTTERY_ID, 0)  //TODO: lottery_id
    .then(function (res) {
        if (res.code === 0 && res.data) {
            $signBtn.addClass('_signed').text('今天已签到');
        }
    })
    .fail(function (res) {
        console.log(res);
    });

$signBtn.on('click', function (e) {
    e.preventDefault();
    if ($signBtn.hasClass('_signed')) {
        return;
    }
    if (SP.isLogined()) {
        webapi.lottery.setAttendance(LOTTERY_ID, 0) //TODO: lottery_id
            .then(function (res) {
                if (res.code === 0) {
                    $signBtn.addClass('_signed').text('今天已签到');
                    $remainingTimes.text(res.data.remaining_times);
                }
            })
            .fail(function (res) {
                SP.notice.error('请求出错，请稍后再试。');
            })
    }
    else {
        SP.login();
    }
});


//抽奖模块
var $lotteryDial = $('#j-lottery-dial');
var $lotteryWrap = $('.lottery-dial__wrap');
var $trigger = $lotteryDial.find('#j-lottery-dial__trigger');
var $prizeList = require('./tpl-prize-list.hbs');
var lottery = null;

webapi.lottery.getPrizeList(LOTTERY_ID)
    .then(function (res) {
        if (res.code === 0) {
            var data = res.data;
            var tpl = $prizeList({
                lists: data
            });
            $(tpl).prependTo($lotteryWrap);
            lottery = new Lottery({
                container: $lotteryDial
            });
        }
    });

SP.helloed.add(function () {
    webapi.lottery.getEligibility(LOTTERY_ID)
        .then(function (res) {
            if (res.code === 0) {
                $remainingTimes.text(res.data.remaining_times);
            }
        })
});

$trigger.on('click', function (e) {
    e.preventDefault();
    if (SP.isLogined()) {
        lottery.getStart(getMyPrize);
    } else {
        SP.login();
    }
});

//抽奖模块右侧Tab
var tab = new Tab({
    target: '.lottery-aside'
});

//抽奖模块右侧轮播滚动
var $winners = $('#j-winners');
//var $scrollInner = $winners.find('.scroll-inner');
var listTpl = require('./tpl-winners-list.hbs');
webapi.lottery.getPublicResult(LOTTERY_ID)
    .then(function (res) {
        var data = res.data;
        var tpl = listTpl({
            lists: data.data
        });
        $winners.html(tpl);
        var ulHeight = $winners.find('ul').height();
        if (ulHeight > 340) {
            autoScroll();
        }
    });

function autoScroll() {
    function run() {
        $winners.find('ul:first').animate({marginTop: '-24px'}, 1500, 'linear', function () {
            $(this).css({marginTop: '0px'}).find('li:first').appendTo(this);
        });
    }

    var timeScroll = setInterval(run, 0);
    $winners.hover(function () {
        clearInterval(timeScroll);
    }, function () {
        timeScroll = setInterval(run, 0);
    });
}

//我的中奖纪录
var $myPrize = $('#j-prize-list');
var myPrizeTpl = require('./tpl-my-prize.hbs');

function getMyPrize() {
    webapi.lottery.getMyResult(LOTTERY_ID, 50)
        .then(function (res) {
            var data = res.data;
            var tpl = myPrizeTpl({
                lists: data.data
            });
            $myPrize.html(tpl);
        });
}

SP.helloed.add(function () {
    if (!SP.isLogined()) {
        $myPrize.html('请<a class="login-trigger">登录</a>后查看。');
    }
    else {
        getMyPrize();
    }
});
