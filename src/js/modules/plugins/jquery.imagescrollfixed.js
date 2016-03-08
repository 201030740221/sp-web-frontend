/*
@date 2016-02-03
@author axu
@param options.scrollTopBegin 指定开始的scrollTop
@param options.viewHeight 指定窗口高度，'origin' 或者一个大于0的数值，默认为窗口高度
*/

(function($) {
  var $win = $(window);
  var winHeight = $win.height();

  $.imageScrollFixed = function(el, options) {
    var _this = this;
    options = $.extend({}, $.imageScrollFixed.defaultOptions, options);

    _this.$el = $(el);
    _this.el = el;
    _this.$el.data("imageScrollFixed", _this);

    _this.init = function() {
      _this.$img = _this.$el.find('img').eq(0);
      _this.imgOffsetLeft = _this.$img.offset().left;

      var originHeight = _this.$el.height();
      if (options.viewHeight === 'origin' && originHeight < winHeight) {
        _this.$el.height(originHeight);
      }
      else if (options.viewHeight > 0)  {
        _this.$el.height(options.viewHeight);
      }
      else {
        _this.$el.height(winHeight);
      }

      _this.offsetTop = _this.$el.offset().top;
      _this.offsetBottom = _this.offsetTop + _this.$el.height();
    };

    _this.scrolled = function(scrollTop) {

      if (scrollTop < options.scrollTopBegin) {
        _this.$img.css({
          position: 'static',
        });
        _this.$el.removeClass('active');
        return null;
      }

      if((_this.offsetTop < (scrollTop + winHeight)) && (scrollTop < _this.offsetBottom)) {
        _this.$img.css({
          display: 'block',
          position: 'fixed',
          top: 0,
          left: _this.imgOffsetLeft,
          zIndex: -1
        });
        _this.$el.addClass('active');
      }
      else {
        _this.$img.hide();
        // _this.$img.css({
        //   // position: 'static',
        //   display: 'none'
        // });
        _this.$el.removeClass('active');
      }
    };

    // _this.init();
  };

  $.imageScrollFixed.defaultOptions = {
    scrollTopBegin: 0
  };

  $.fn.imageScrollFixed = function(options) {
    var scrollCallbacks = $.Callbacks();
    var initCallbacks = $.Callbacks();

    this.each(function(index) {
      var item = new $.imageScrollFixed(this, options);
      scrollCallbacks.add(item.scrolled);
      initCallbacks.add(item.init);
    });

    $win.on('scroll.imageScrollFixed', function(e) {
      var scrollTop = $win.scrollTop();
      scrollCallbacks.fire(scrollTop);
    }).on('resize', function() {
      winHeight = $win.height();
      initCallbacks.fire();
    }).trigger('resize');

    return this;
  };

})(jQuery);
