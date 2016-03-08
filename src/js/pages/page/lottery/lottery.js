var layout = require('./tpl-layout.hbs');
var ModalBox = require('ModalBox');
var NewAddress = require('NewAddress');
var lotteryModalBox = null;

function Lottery(options) {
    var $lotteryDial = options.container;
    var $lotteryPrize = $lotteryDial.find(".prize-list__item");
    var $oddDot = $("._dot:odd").find("span");
    var $evenDot = $("._dot:even").find("span").css("backgroundColor", "yellow");
    var remainingTimes = 0;
    var round = 4;
    var speed = 100;
    var total;
    var result;
    var prizeLength = $lotteryPrize.length;
    var isRunning = false;

    var $mask = $("<span></span>");
    $mask.css({
        position: "absolute",
        left: 0,
        top: 0,
        display: "inline-block",
        width: 100 + "%",
        height: 100 + "%"
    });

    $lotteryPrize.append($mask);

    var CSSMask = {
        background: "#000",
        filter: "alpha(opacity=40)",
        "-moz-opacity": 0.4,
        opacity: 0.4
    };

    var CSSMaskReveal = {
        filter: "alpha(opacity=0)",
        "-moz-opacity": 0,
        opacity: 0
    };

    this.getStart = function (callback) {
        var i = 1;
        var j = 1;

        if (isRunning) {
            return;
        }

        webapi.lottery.getEligibility(LOTTERY_ID)  //TODO: lottery_id
            .then(function (res) {
                remainingTimes = res.data.remaining_times;
                if (remainingTimes > 0) {
                    webapi.lottery.draw(LOTTERY_ID)
                        .then(function (res) {
                            if (res.code !== 0) {
                                SP.alert(res.msg);
                                return;
                            }
                            result = res;
                            total = round * prizeLength + result.data.prize_id;
                            isRunning = true;
                            run(speed);
                        }).fail(function (res) {
                            SP.notice.error("请求出错，请稍后再试。");
                        });
                }
                else {
                    SP.notice("明天再来，Apple Watch等着你！");
                }
            }).fail(function () {
                SP.notice.error("请求出错，请稍后再试。");
            });

        function run(speed) {
            setTimeout(function () {
                $lotteryPrize.find("span").css(CSSMask);
                $lotteryPrize.eq(i - 1).find("span").css(CSSMaskReveal);
                i = i < prizeLength ? i + 1 : 1;

                if (i % 2) {
                    $oddDot.css("backgroundColor", "yellow");
                    $evenDot.css("backgroundColor", "white");
                }
                else {
                    $evenDot.css("backgroundColor", "yellow");
                    $oddDot.css("backgroundColor", "white");
                }

                if (j < total - 7) {
                    run(speed);
                    j++;
                }
                else if (j < total) {
                    run(speed + 20);
                    j++;
                }
                else {
                    isRunning = false;
                    handleResult(result);
                    if (typeof callback === 'function') {
                        callback();
                    }
                }
            }, speed)
        }
    }
}

//处理抽奖结果
function handleResult(result) {
    var prizeType = "";
    var prizeImgClass = "";
    var isAddressRequired = false;

    switch (result.data.prize_type) {
        case 0:
            prizeType = "积分";
            prizeImgClass = "prize-point";
            break;
        case 1:
            prizeType = "优惠券";
            prizeImgClass = "prize-coupon";
            break;
        case 2:
            prizeType = "实体商品";
            prizeImgClass = "prize-watch";
            isAddressRequired = true;
            break;
        case 3:
            prizeType = "再来一次";
            isAddressRequired = false;
            break;
        case 4:
            prizeType = "空";
            isAddressRequired = false;
            break;
        case 5:
            prizeType = "实体商品";
            prizeImgClass = "prize-three";
            isAddressRequired = true;
            break;
    }

    var tpl = layout({
        prizeName: result.data.prize_name,
        prizeType: prizeType,
        prizeImgClass: prizeImgClass,
        isAddressRequired: isAddressRequired
    });

    lotteryModalBox = new ModalBox({
        template: tpl,
        width: 550,
        top: 60,
        mask: true,
        maskClose: true,
        closeBtn: true,
        closedCallback: function () {
            lotteryModalBox.destroy();
        }
    });

    setTimeout(function () {
        lotteryModalBox.show();
    }, 800);

    var $count = $("#j-lottery__count");
    $count.text(result.data.remaining_times);

    var $closeBtn = $("#j-result-close");
    if (isAddressRequired) {
        $closeBtn.on("click", function () {
            handleContactInfo(result);
        });
    }
    else {
        $closeBtn.on("click", function () {
            lotteryModalBox.destroy();
        });
    }
}

//处理用户联系信息
function handleContactInfo(result) {
    SP.notice.success("信息提交成功，请耐心等候发货")

    new NewAddress({
        el: "#j-address-form",
        callback: handleAddress,
        cancelCallback: cancelCallback
    });

    function handleAddress(value) {
        var address_id = value[value.length - 1].id;
        webapi.lottery.setAddress(result.data.id, address_id)
            .then(function (res) {
                lotteryModalBox.destroy();
                lmb.show();
            })
    }

    function cancelCallback() {
        lotteryModalBox.destroy();
    }
}

module.exports = Lottery;
