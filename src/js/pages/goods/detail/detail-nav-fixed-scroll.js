// # # #
// # 滚动到一定的位置， 固定横条导航
// # # #

module.exports = function () {
    var $window = $(window);
    var $document = $(document);
    var navFixed = false;
    var $nav = $('.content-hd');
    var $addToCartBtn = $nav.find('.j-add-to-cart');
    var $content = $('.goods-detail-extend-content');

    $window.on('scroll', function() {
        var scrollTop = $document.scrollTop();
        var contentOffsetTop = $content.offset().top;
        var navHeight = $nav.height();

        if (scrollTop > contentOffsetTop + navHeight) {
            if (navFixed) return;
            navFixed = true;
            $nav.addClass('fixed').hide().slideDown(200, 'linear');
            $addToCartBtn.show();
        }
        else {
            navFixed = false;
            $nav.stop().removeClass('fixed');
            $addToCartBtn.hide();
        }
    });
};
