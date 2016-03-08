var CouponModal = require ('modules/coupon/coupon-modal-box-v2');
$(function()
{
    var couponModal = null;
    $(".handle_coupon").click(function () {
        if(!couponModal){
            couponModal = new CouponModal({
                width: '540px',
                top: 170,
                mask: true,
                closeBtn: true,
                couponCodeCallback: function (_res) {
                    setTimeout(function () {
                        window.location.reload();
                    }, 1000)
                }
            });
        }
        couponModal.show();
    });

});
