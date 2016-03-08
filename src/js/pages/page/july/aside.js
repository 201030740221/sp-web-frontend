var $goodsSection = $("#goods-section");
var $referralSection = $("#referral-section");
var $lotterySection = $("#lottery-section");
var $flashSection = $("#flash-section");
var $recSection = $("#recommend-section");
var $nav = $("#j-aside-nav");
var $navItem = $nav.find(".nav__item");

var goodsSectionHeight = $goodsSection.offset().top;
var referralSectionHeight = $referralSection.offset().top;
var lotterySectionHeight = $lotterySection.offset().top;
var flashSectionHeight = $flashSection.offset().top;
var recSectionHeight = $recSection.offset().top;

//var isLock = false;
//$nav.on("click", ".nav__item", function (e) {
//    isLock = true;
//    var target = $(e.target).parent("li");
//    var index = $navItem.index(target);
//    target.siblings().removeClass("_nav-active");
//    target.addClass("_nav-active");
//
//
//});

$(window).on("scroll", function (e) {
    var scrolled = $(window).scrollTop();
    if (scrolled > recSectionHeight - 100) {
        $navItem.eq(4).siblings().removeClass("_nav-active");
        $navItem.eq(4).addClass("_nav-active");
    }
    else if (scrolled > flashSectionHeight - 100) {
        $navItem.eq(3).siblings().removeClass("_nav-active");
        $navItem.eq(3).addClass("_nav-active");
    }
    else if (scrolled > lotterySectionHeight - 100) {
        $navItem.eq(2).siblings().removeClass("_nav-active");
        $navItem.eq(2).addClass("_nav-active");
    }
    else if (scrolled > referralSectionHeight - 100) {
        $navItem.eq(1).siblings().removeClass("_nav-active");
        $navItem.eq(1).addClass("_nav-active");
    }
    else if (scrolled > goodsSectionHeight - 100) {
        $navItem.eq(0).siblings().removeClass("_nav-active");
        $navItem.eq(0).addClass("_nav-active");
    }
});

