/*
 * Swipe 2.0
 *
 * Brad Birdsall
 * Copyright 2013, MIT License
 *
*/

function Swipe(container, options) {

  "use strict";

  // utilities
  var noop = function() {}; // simple no operation function
  var offloadFn = function(fn) { setTimeout(fn || noop, 0) }; // offload a functions execution

  // check browser capabilities
  var browser = {
    addEventListener: !!window.addEventListener,
    touch: ('ontouchstart' in window) || window.DocumentTouch && document instanceof DocumentTouch,
    transitions: (function(temp) {
      var props = ['transformProperty', 'WebkitTransform', 'MozTransform', 'OTransform', 'msTransform'];
      for ( var i in props ) if (temp.style[ props[i] ] !== undefined) return true;
      return false;
    })(document.createElement('swipe'))
  };

  // quit if no root element
  if (!container) return;
  var element = $(container).children()[0];
  var slides, slidePos, width;
  options = options || {};
  var index = parseInt(options.startSlide, 10) || 0;
  var speed = options.speed || 400;
  options.continuous = options.continuous || true; // 连续滚动

  function setup() {

    // cache slides
    slides = [].slice.call($(element).children());

    // create an array to store current positions of each slide
    slidePos = new Array(slides.length);

    // determine width of each slide
    width = container.getBoundingClientRect().width || container.offsetWidth;

    element.style.width = (slides.length * width) + 'px';

    // stack elements
    var pos = slides.length;
    while(pos--) {

      var slide = slides[pos];

      slide.style.width = width + 'px';
      slide.setAttribute('data-index', pos);

      if (browser.transitions) {
        slide.style.left = (pos * -width) + 'px';
        move(pos, index > pos ? -width : (index < pos ? width : 0), 0);
      }

    }

    if (!browser.transitions) element.style.left = (index * -width) + 'px';

    container.style.visibility = 'visible';

  }

  function prev() {

    if (index) slide(index-1);
    else if (options.continuous) slide(slides.length-1);

  }

  function next() {

    if (index < slides.length - 1) slide(index+1);
    else if (options.continuous) slide(0);

  }

  function slide(to, slideSpeed) {

    // do nothing if already on requested slide
    if (index == to) return;

    if (browser.transitions) {

      var diff = Math.abs(index-to) - 1;
      var direction = Math.abs(index-to) / (index-to); // 1:right -1:left

      while (diff--) move((to > index ? to : index) - diff - 1, width * direction, 0);

      move(index, width * direction, slideSpeed || speed);
      move(to, 0, slideSpeed || speed);

    } else {

      animate(index * -width, to * -width, slideSpeed || speed);

    }

    index = to;

    offloadFn(options.callback && options.callback(index, slides[index]));

  }

  function move(index, dist, speed) {

    translate(index, dist, speed);
    slidePos[index] = dist;

  }

  function translate(index, dist, speed) {

    var slide = slides[index];
    var style = slide && slide.style;

    if (!style) return;

    style.webkitTransitionDuration =
    style.MozTransitionDuration =
    style.msTransitionDuration =
    style.OTransitionDuration =
    style.transitionDuration = speed + 'ms';

    style.webkitTransform = 'translate(' + dist + 'px,0)' + 'translateZ(0)';
    style.msTransform =
    style.MozTransform =
    style.OTransform = 'translateX(' + dist + 'px)';

  }

  function animate(from, to, speed) {

    // if not an animation, just reposition
    if (!speed) {

      element.style.left = to + 'px';
      return;

    }

    var startTime = +new Date();
    var timer = setInterval(function() {

      var timeElap = +new Date() - startTime;

      if (timeElap > speed) {

        element.style.left = to + 'px';

        if (delay) begin();

        options.transitionEnd && options.transitionEnd.call(event, index, slides[index]);

        clearInterval(timer);
        return;

      }

      element.style.left = (( (to - from) * (Math.floor((timeElap / speed) * 100) / 100) ) + from) + 'px';

    }, 4);

  }

  // setup auto slideshow
  var delay = options.auto || 0;
  var interval;

  function begin() {

    delay = options.auto || 0;
    clearTimeout(interval);
    interval = setTimeout(next, delay);

  }

  function stop() {

    delay = 0;
    clearTimeout(interval);

  }


  // setup initial vars
  var start = {};
  var delta = {};
  var isScrolling;

  // setup event capturing
  var events = {

    handleEvent: function(event) {

      switch (event.type) {
        case 'touchstart': this.start(event); break;
        case 'touchmove': this.move(event); break;
        case 'touchend': offloadFn(this.end(event)); break;
        case 'webkitTransitionEnd':
        case 'msTransitionEnd':
        case 'oTransitionEnd':
        case 'otransitionend':
        case 'transitionend': offloadFn(this.transitionEnd(event)); break;
        case 'resize': offloadFn(setup.call()); break;
      }

      if (options.stopPropagation) event.stopPropagation();

    },
    start: function(event) {

      var touches = event.touches[0];

      // measure start values
      start = {

        // get initial touch coords
        x: touches.pageX,
        y: touches.pageY,

        // store time to determine touch duration
        time: +new Date

      };

      // used for testing first move event
      isScrolling = undefined;

      // reset delta and end measurements
      delta = {};

      // attach touchmove and touchend listeners
      element.addEventListener('touchmove', this, false);
      element.addEventListener('touchend', this, false);

    },
    move: function(event) {

      // ensure swiping with one touch and not pinching
      if ( event.touches.length > 1 || event.scale && event.scale !== 1) return

      if (options.disableScroll) event.preventDefault();

      var touches = event.touches[0];

      // measure change in x and y
      delta = {
        x: touches.pageX - start.x,
        y: touches.pageY - start.y
      }

      // determine if scrolling test has run - one time test
      if ( typeof isScrolling == 'undefined') {
        isScrolling = !!( isScrolling || Math.abs(delta.x) < Math.abs(delta.y) );
      }

      // if user is not trying to scroll vertically
      if (!isScrolling) {

        // prevent native scrolling
        event.preventDefault();

        // stop slideshow
        stop();

        // increase resistance if first or last slide
        delta.x =
          delta.x /
            ( (!index && delta.x > 0               // if first slide and sliding left
              || index == slides.length - 1        // or if last slide and sliding right
              && delta.x < 0                       // and if sliding at all
            ) ?
            ( Math.abs(delta.x) / width + 1 )      // determine resistance level
            : 1 );                                 // no resistance if false

        // translate 1:1
        translate(index-1, delta.x + slidePos[index-1], 0);
        translate(index, delta.x + slidePos[index], 0);
        translate(index+1, delta.x + slidePos[index+1], 0);

      }

    },
    end: function(event) {

      // measure duration
      var duration = +new Date - start.time;

      // determine if slide attempt triggers next/prev slide
      var isValidSlide =
            Number(duration) < 250               // if slide duration is less than 250ms
            && Math.abs(delta.x) > 20            // and if slide amt is greater than 20px
            || Math.abs(delta.x) > width/2;      // or if slide amt is greater than half the width

      // determine if slide attempt is past start and end
      var isPastBounds =
            !index && delta.x > 0                            // if first slide and slide amt is greater than 0
            || index == slides.length - 1 && delta.x < 0;    // or if last slide and slide amt is less than 0

      // determine direction of swipe (true:right, false:left)
      var direction = delta.x < 0;

      // if not scrolling vertically
      if (!isScrolling) {

        if (isValidSlide && !isPastBounds) {

          if (direction) {

            move(index-1, -width, 0);
            move(index, slidePos[index]-width, speed);
            move(index+1, slidePos[index+1]-width, speed);
            index += 1;

          } else {

            move(index+1, width, 0);
            move(index, slidePos[index]+width, speed);
            move(index-1, slidePos[index-1]+width, speed);
            index += -1;

          }

          options.callback && options.callback(index, slides[index]);

        } else {

          move(index-1, -width, speed);
          move(index, 0, speed);
          move(index+1, width, speed);

        }

      }

      // kill touchmove and touchend event listeners until touchstart called again
      element.removeEventListener('touchmove', events, false)
      element.removeEventListener('touchend', events, false)

    },
    transitionEnd: function(event) {

      if (parseInt(event.target.getAttribute('data-index'), 10) == index) {

        if (delay) begin();

        options.transitionEnd && options.transitionEnd.call(event, index, slides[index]);

      }

    }

  }

  // trigger setup
  setup();

  // start auto slideshow if applicable
  if (delay) begin();


  // add event listeners
  if (browser.addEventListener) {

    // set touchstart event on element
    if (browser.touch) element.addEventListener('touchstart', events, false);

    if (browser.transitions) {
      element.addEventListener('webkitTransitionEnd', events, false);
      element.addEventListener('msTransitionEnd', events, false);
      element.addEventListener('oTransitionEnd', events, false);
      element.addEventListener('otransitionend', events, false);
      element.addEventListener('transitionend', events, false);
    }

    // set resize event on window
    window.addEventListener('resize', events, false);

  } else {

    window.onresize = function () { setup() }; // to play nice with old IE

  }

  // expose the Swipe API
  return {
    getItems: function () {
      return slides;
    },
    setup: function() {

      setup();

    },
    slide: function(to, speed) {

      slide(to, speed);

    },
    prev: function() {

      // cancel slideshow
      stop();

      prev();

    },
    next: function() {

      stop();

      next();

    },
    getPos: function() {

      // return current index position
      return index;

    },
    kill: function() {

      // cancel slideshow
      stop();

      // reset element
      element.style.width = 'auto';
      element.style.left = 0;

      // reset slides
      var pos = slides.length;
      while(pos--) {

        var slide = slides[pos];
        slide.style.width = '100%';
        slide.style.left = 0;

        if (browser.transitions) translate(pos, 0, 0);

      }

      // removed event listeners
      if (browser.addEventListener) {

        // remove current event listeners
        element.removeEventListener('touchstart', events, false);
        element.removeEventListener('webkitTransitionEnd', events, false);
        element.removeEventListener('msTransitionEnd', events, false);
        element.removeEventListener('oTransitionEnd', events, false);
        element.removeEventListener('otransitionend', events, false);
        element.removeEventListener('transitionend', events, false);
        window.removeEventListener('resize', events, false);

      }
      else {

        window.onresize = null;

      }

    }
  }

}


if ( window.jQuery || window.Zepto ) {
  (function($) {
    $.fn.Swipe = function(params) {
      params = $.extend({
        pager: true,
        prev: '.prev',
        next: '.next',
        startSlide: 0,
        auto: 5000
      }, params);

      return this.each(function() {
        var $this = $(this);

        if (params.pager) {
          var _callback = params.callback || function(){};
          params.callback = function (index, element) {
            _callback();
            $this.find('.pointer').eq(index).addClass('active').siblings().removeClass('active');
          }
        }

        var swiper = new Swipe($(this)[0], params);
        $(this).data('Swipe', swiper);

        if (params.pager) {
          var $pager = $('<div class="points"/>')
          ,   points = []
          ,   count = swiper.getItems().length
          ,   i = 0;

          for (; i < count; i++) {
            points.push('<span class="pointer', params.startSlide === i ? ' active' : '' ,'" data-index="', i ,'"/>');
          }

          $pager.html(points.join(''));

          $(this).append($pager);
          $(this).on('click', '.pointer', function () {
            var $point = $(this);

            if ($point.hasClass('active')) {
              return;
            }

            var i = $point.data('index');
            swiper.slide(i);
          });
        }

        $(this).on('click', params.prev, function () {
          swiper.prev();
        }).on('click', params.next, function () {
          swiper.next();
        })
      });
    };

    $.fn.getSwipe = function () {
      return this.data('Swipe');
    }
  })( window.jQuery || window.Zepto )
}


(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        define(function(){
            return factory;
        });
    } else {
        return factory;
    }
}(this, Swipe));
