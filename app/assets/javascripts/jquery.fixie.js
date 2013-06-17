// jquery.fixie.js: Copyright(c) 2013 NDP Software, Andrew J. Peterson
(function ($) {

  // Simple throttle function decorator.
  var throttle = function (fn, milliseconds) {
    var ctx = this,
        timeout = null,
        lastCallAt = (new Date()).valueOf() - milliseconds;

    return function () {
      var args = Array.prototype.slice.call(arguments);
      var now = (new Date()).valueOf();
      if ((now - lastCallAt) >= milliseconds) {
        fn.apply(ctx, args);
        lastCallAt = now;
      }

      if (timeout) {
        clearTimeout(timeout);
      }
      timeout = setTimeout(function () {
        fn.apply(ctx, args);
        lastCallAt = (new Date()).valueOf();
      }, milliseconds);
    }
  };

  /* Returns a fn that should be called repeatedly.
   When it is first called, beforeFn is called, and after
   a break of _milliseconds_, will call afterFn. Repeats
   as needed.
   */
  var beforeAndAfter = function (beforeFn, afterFn, milliseconds) {
    var ctx = this, timeout = null;

    return function () {
      var args = Array.prototype.slice.call(arguments);
      if (!timeout) {
        beforeFn.apply(ctx, args);
      }
      if (timeout) {
        clearTimeout(timeout);
      }
      timeout = setTimeout(function () {
        afterFn.apply(ctx, args);
        timeout = null;
      }, milliseconds);
    }
  };


  /* Finally, what we've been looking for */

  $.fn.fixie = function (options) {

    var config = $.extend({}, $.fn.fixie.defaults, options);

    return $(this).each(function () {

      var $target = $(this);
      var originalY = $target.position().top;


      var applyPinnedClass = function (pinnedNow) {
        $target.toggleClass(config.pinnedToTopClass, pinnedNow);
        if (config.pinnedBodyClass) {
          $('body').toggleClass(config.pinnedBodyClass, pinnedNow);
        }
      }

      var fixIt = function () {

        if (config.topMargin !== undefined && !$target.hasClass(config.pinnedToBottomClass)) {
          if ((window.scrollY - config.pinSlop) > (originalY - config.topMargin)) {
            console.log('pinning to top')
            $target.css({position: 'fixed', top: config.topMargin, bottom: 'auto'});
            applyPinnedClass(true);
          } else {
            console.log('unpinning from top')
            $target.css({position: 'relative', top: 'inherit', bottom: 'auto'});
            applyPinnedClass(false);
          }
        }


        if (config.bottomMargin !== undefined && !$target.hasClass(config.pinnedToTopClass)) {
          console.log('window.scrollY', window.scrollY)
          console.log('window.innerHeight', window.innerHeight, 'window.innerHeight + scrollY', window.innerHeight + window.scrollY)
          $target.css({position: 'relative'});
          var bottom = $target[0].offsetTop + $target[0].offsetHeight
          if ((window.innerHeight + window.scrollY - config.bottomMargin) <
              bottom) {
            console.log('pinning to bottom')
            $target.css({position: 'fixed', bottom: config.bottomMargin, top: 'auto'});
            $target.addClass(config.pinnedToBottomClass)
          } else {
            console.log('unpinning from bottom')
            $target.css({position: 'relative', bottom:'inherit', top: 'inherit'});
            $target.removeClass(config.pinnedToBottomClass)
          }
          console.log($target[0].offsetTop, $target[0].offsetHeight, $target[0].offsetTop + $target[0].offsetHeight)
//          console.log('originalY', originalY)
//          console.dir($target[0])
        }

      };
      $(window).on('scroll', throttle(fixIt, config.throttle));
    });
  };

  $.fn.fixie.defaults = {
    topMargin: undefined, // how close to the top to pin it?
    bottomMargin: undefined,
    pinSlop: 0,    // make the user scroll extra down the page before the element is fixed?
    pinnedToTopClass: '_pinned-to-top', // any css class to add on when pinned
    pinnedToBottomClass: 'pinned-to-bottom', // any css class to add on when pinned
    pinnedBodyClass: undefined,
    throttle: 30                  // how often to adjust position of element
  };


})(jQuery);

