/*! modernizr 3.0.0 (Custom Build) | MIT *
 * http://modernizr.com/download/?-csstransforms-csstransforms3d !*/
!function(e,n,t){function r(e,n){return typeof e===n}function o(){var e,n,t,o,s,i,f;for(var a in y){if(e=[],n=y[a],n.name&&(e.push(n.name.toLowerCase()),n.options&&n.options.aliases&&n.options.aliases.length))for(t=0;t<n.options.aliases.length;t++)e.push(n.options.aliases[t].toLowerCase());for(o=r(n.fn,"function")?n.fn():n.fn,s=0;s<e.length;s++)i=e[s],f=i.split("."),1===f.length?Modernizr[f[0]]=o:(!Modernizr[f[0]]||Modernizr[f[0]]instanceof Boolean||(Modernizr[f[0]]=new Boolean(Modernizr[f[0]])),Modernizr[f[0]][f[1]]=o),C.push((o?"":"no-")+f.join("-"))}}function s(){return"function"!=typeof n.createElement?n.createElement(arguments[0]):_?n.createElementNS.call(n,"http://www.w3.org/2000/svg",arguments[0]):n.createElement.apply(n,arguments)}function i(){var e=n.body;return e||(e=s(_?"svg":"body"),e.fake=!0),e}function f(e,t,r,o){var f,a,u,l,p="modernizr",d=s("div"),c=i();if(parseInt(r,10))for(;r--;)u=s("div"),u.id=o?o[r]:p+(r+1),d.appendChild(u);return f=s("style"),f.type="text/css",f.id="s"+p,(c.fake?c:d).appendChild(f),c.appendChild(d),f.styleSheet?f.styleSheet.cssText=e:f.appendChild(n.createTextNode(e)),d.id=p,c.fake&&(c.style.background="",c.style.overflow="hidden",l=S.style.overflow,S.style.overflow="hidden",S.appendChild(c)),a=t(d,e),c.fake?(c.parentNode.removeChild(c),S.style.overflow=l,S.offsetHeight):d.parentNode.removeChild(d),!!a}function a(e,n){return!!~(""+e).indexOf(n)}function u(e){return e.replace(/([a-z])-([a-z])/g,function(e,n,t){return n+t.toUpperCase()}).replace(/^-/,"")}function l(e){return e.replace(/([A-Z])/g,function(e,n){return"-"+n.toLowerCase()}).replace(/^ms-/,"-ms-")}function p(n,r){var o=n.length;if("CSS"in e&&"supports"in e.CSS){for(;o--;)if(e.CSS.supports(l(n[o]),r))return!0;return!1}if("CSSSupportsRule"in e){for(var s=[];o--;)s.push("("+l(n[o])+":"+r+")");return s=s.join(" or "),f("@supports ("+s+") { #modernizr { position: absolute; } }",function(e){return"absolute"==getComputedStyle(e,null).position})}return t}function d(e,n,o,i){function f(){d&&(delete k.style,delete k.modElem)}if(i=r(i,"undefined")?!1:i,!r(o,"undefined")){var l=p(e,o);if(!r(l,"undefined"))return l}for(var d,c,m,v,h,y=["modernizr","tspan"];!k.style;)d=!0,k.modElem=s(y.shift()),k.style=k.modElem.style;for(m=e.length,c=0;m>c;c++)if(v=e[c],h=k.style[v],a(v,"-")&&(v=u(v)),k.style[v]!==t){if(i||r(o,"undefined"))return f(),"pfx"==n?v:!0;try{k.style[v]=o}catch(g){}if(k.style[v]!=h)return f(),"pfx"==n?v:!0}return f(),!1}function c(e,n){return function(){return e.apply(n,arguments)}}function m(e,n,t){var o;for(var s in e)if(e[s]in n)return t===!1?e[s]:(o=n[e[s]],r(o,"function")?c(o,t||n):o);return!1}function v(e,n,t,o,s){var i=e.charAt(0).toUpperCase()+e.slice(1),f=(e+" "+P.join(i+" ")+i).split(" ");return r(n,"string")||r(n,"undefined")?d(f,n,o,s):(f=(e+" "+T.join(i+" ")+i).split(" "),m(f,n,t))}function h(e,n,r){return v(e,t,t,n,r)}var y=[],g={_version:"3.0.0",_config:{classPrefix:"",enableClasses:!0,enableJSClass:!0,usePrefixes:!0},_q:[],on:function(e,n){var t=this;setTimeout(function(){n(t[e])},0)},addTest:function(e,n,t){y.push({name:e,fn:n,options:t})},addAsyncTest:function(e){y.push({name:null,fn:e})}},Modernizr=function(){};Modernizr.prototype=g,Modernizr=new Modernizr;var C=[],S=n.documentElement,w="CSS"in e&&"supports"in e.CSS,x="supportsCSS"in e;Modernizr.addTest("supports",w||x);var _="svg"===S.nodeName.toLowerCase(),b=g.testStyles=f,z="Moz O ms Webkit",P=g._config.usePrefixes?z.split(" "):[];g._cssomPrefixes=P;var T=g._config.usePrefixes?z.toLowerCase().split(" "):[];g._domPrefixes=T;var E={elem:s("modernizr")};Modernizr._q.push(function(){delete E.elem});var k={style:E.elem.style};Modernizr._q.unshift(function(){delete k.style}),g.testAllProps=v,g.testAllProps=h,Modernizr.addTest("csstransforms3d",function(){var e=!!h("perspective","1px",!0),n=Modernizr._config.usePrefixes;if(e&&(!n||"webkitPerspective"in S.style)){var t;Modernizr.supports?t="@supports (perspective: 1px)":(t="@media (transform-3d)",n&&(t+=",(-webkit-transform-3d)")),t+="{#modernizr{left:9px;position:absolute;height:5px;margin:0;padding:0;border:0}}",b(t,function(n){e=9===n.offsetLeft&&5===n.offsetHeight})}return e}),Modernizr.addTest("csstransforms",function(){return-1===navigator.userAgent.indexOf("Android 2.")&&h("transform","scale(1)",!0)}),o(),delete g.addTest,delete g.addAsyncTest;for(var A=0;A<Modernizr._q.length;A++)Modernizr._q[A]();e.Modernizr=Modernizr}(window,document);

/**
 * jquery.gallery.js
 * http://www.codrops.com
 *
 * Copyright 2011, Pedro Botelho / Codrops
 * Free to use under the MIT license.
 *
 * Date: Mon Jan 30 2012
 */

(function( $, undefined ) {

    var sider_opacity = 0.5;
    
    /*
     * Gallery object.
     */
    $.Gallery               = function( options, element ) {
    
        this.$el    = $( element );
        this._init( options );
        
    };
    
    $.Gallery.defaults      = {
        current     : 0,    // index of current item
        autoplay    : false,// slideshow on / off
        interval    : 2000  // time between transitions
    };
    
    $.Gallery.prototype     = {
        _init               : function( options ) {
            
            this.options        = $.extend( true, {}, $.Gallery.defaults, options );
            
            // support for 3d / 2d transforms and transitions
            this.support3d      = Modernizr.csstransforms3d;
            this.support2d      = Modernizr.csstransforms;
            this.supportTrans   = this.support3d;

            this.$wrapper       = this.$el.find('.dg-wrapper');
            
            this.$items         = this.$wrapper.children();
            this.itemsCount     = this.$items.length;
            
            this.$nav           = this.$el.find('nav');
            this.$navPrev       = this.$nav.find('.dg-prev');
            this.$navNext       = this.$nav.find('.dg-next');
            
            // minimum of 3 items
            if( this.itemsCount < 3 ) {
                    
                this.$nav.remove();
                return false;
            
            }   
            
            this.current        = this.options.current;
            
            this.isAnim         = false;
            
            this.$items.css({
                'opacity'   : 0,
                'visibility': 'hidden'
            });
            
            this._validate();
            
            this._layout();
            
            // load the events
            this._loadEvents();
            
            // slideshow
            if( this.options.autoplay ) {
            
                this._startSlideshow();
            
            }
            
        },
        _validate           : function() {
        
            if( this.options.current < 0 || this.options.current > this.itemsCount - 1 ) {
                
                this.current = 0;
            
            }   
        
        },
        _layout             : function() {
            
            // current, left and right items
            this._setItems();
            
            // current item is not changed
            // left and right one are rotated and translated
            var leftCSS, rightCSS, currentCSS;
            
            if( this.support3d && this.supportTrans ) {
            
                leftCSS     = {
                    '-webkit-transform' : 'translateX(-350px) translateZ(-200px) rotateY(45deg)',
                    '-moz-transform'    : 'translateX(-350px) translateZ(-200px) rotateY(45deg)',
                    '-o-transform'      : 'translateX(-350px) translateZ(-200px) rotateY(45deg)',
                    '-ms-transform'     : 'translateX(-350px) translateZ(-200px) rotateY(45deg)',
                    'transform'         : 'translateX(-350px) translateZ(-200px) rotateY(45deg)'
                };
                
                rightCSS    = {
                    '-webkit-transform' : 'translateX(350px) translateZ(-200px) rotateY(-45deg)',
                    '-moz-transform'    : 'translateX(350px) translateZ(-200px) rotateY(-45deg)',
                    '-o-transform'      : 'translateX(350px) translateZ(-200px) rotateY(-45deg)',
                    '-ms-transform'     : 'translateX(350px) translateZ(-200px) rotateY(-45deg)',
                    'transform'         : 'translateX(350px) translateZ(-200px) rotateY(-45deg)'
                };
                
                leftCSS.opacity     = sider_opacity;
                leftCSS.visibility  = 'visible';
                rightCSS.opacity    = sider_opacity;
                rightCSS.visibility = 'visible';
            
            }
            else if( this.support2d && this.supportTrans ) {
                
                leftCSS     = {
                    '-webkit-transform' : 'translate(-350px) scale(0.8)',
                    '-moz-transform'    : 'translate(-350px) scale(0.8)',
                    '-o-transform'      : 'translate(-350px) scale(0.8)',
                    '-ms-transform'     : 'translate(-350px) scale(0.8)',
                    'transform'         : 'translate(-350px) scale(0.8)'
                };
                
                rightCSS    = {
                    '-webkit-transform' : 'translate(350px) scale(0.8)',
                    '-moz-transform'    : 'translate(350px) scale(0.8)',
                    '-o-transform'      : 'translate(350px) scale(0.8)',
                    '-ms-transform'     : 'translate(350px) scale(0.8)',
                    'transform'         : 'translate(350px) scale(0.8)'
                };
                
                currentCSS  = {
                    'z-index'           : 999
                };
                
                leftCSS.opacity     = sider_opacity;
                leftCSS.visibility  = 'visible';
                rightCSS.opacity    = sider_opacity;
                rightCSS.visibility = 'visible';
            
            }
            
            this.$leftItm.css( leftCSS || {} );
            this.$rightItm.css( rightCSS || {} );
            
            this.$currentItm.css( currentCSS || {} ).css({
                'opacity'   : 1,
                'visibility': 'visible'
            }).addClass('dg-center');
            
        },
        _setItems           : function() {
            
            this.$items.removeClass('dg-center');
            
            this.$currentItm    = this.$items.eq( this.current );
            this.$leftItm       = ( this.current === 0 ) ? this.$items.eq( this.itemsCount - 1 ) : this.$items.eq( this.current - 1 );
            this.$rightItm      = ( this.current === this.itemsCount - 1 ) ? this.$items.eq( 0 ) : this.$items.eq( this.current + 1 );
            
            if( !this.support3d && this.support2d && this.supportTrans ) {
            
                this.$items.css( 'z-index', 1 );
                this.$currentItm.css( 'z-index', 999 );
            
            }
            
            // next & previous items
            if( this.itemsCount > 3 ) {
            
                // next item
                this.$nextItm       = ( this.$rightItm.index() === this.itemsCount - 1 ) ? this.$items.eq( 0 ) : this.$rightItm.next();
                this.$nextItm.css( this._getCoordinates('outright') );
                
                // previous item
                this.$prevItm       = ( this.$leftItm.index() === 0 ) ? this.$items.eq( this.itemsCount - 1 ) : this.$leftItm.prev();
                this.$prevItm.css( this._getCoordinates('outleft') );
            
            }
            
        },
        _loadEvents         : function() {
            
            var _self   = this;
            
            this.$navPrev.on( 'click.gallery', function( event ) {
                
                if( _self.options.autoplay ) {
                
                    clearTimeout( _self.slideshow );
                    _self.options.autoplay  = false;
                
                }
                
                _self._navigate('prev');
                return false;
                
            });
            
            this.$navNext.on( 'click.gallery', function( event ) {
                
                if( _self.options.autoplay ) {
                
                    clearTimeout( _self.slideshow );
                    _self.options.autoplay  = false;
                
                }
                
                _self._navigate('next');
                return false;
                
            });
            
            this.$wrapper.on( 'webkitTransitionEnd.gallery transitionend.gallery OTransitionEnd.gallery', function( event ) {
                
                _self.$currentItm.addClass('dg-center');
                _self.$items.removeClass('dg-transition');
                _self.isAnim    = false;
                
            });
            
        },
        _getCoordinates     : function( position ) {
            
            if( this.support3d && this.supportTrans ) {
            
                switch( position ) {
                    case 'outleft':
                        return {
                            '-webkit-transform' : 'translateX(-450px) translateZ(-300px) rotateY(45deg)',
                            '-moz-transform'    : 'translateX(-450px) translateZ(-300px) rotateY(45deg)',
                            '-o-transform'      : 'translateX(-450px) translateZ(-300px) rotateY(45deg)',
                            '-ms-transform'     : 'translateX(-450px) translateZ(-300px) rotateY(45deg)',
                            'transform'         : 'translateX(-450px) translateZ(-300px) rotateY(45deg)',
                            'opacity'           : 0,
                            'visibility'        : 'hidden'
                        };
                        break;
                    case 'outright':
                        return {
                            '-webkit-transform' : 'translateX(450px) translateZ(-300px) rotateY(-45deg)',
                            '-moz-transform'    : 'translateX(450px) translateZ(-300px) rotateY(-45deg)',
                            '-o-transform'      : 'translateX(450px) translateZ(-300px) rotateY(-45deg)',
                            '-ms-transform'     : 'translateX(450px) translateZ(-300px) rotateY(-45deg)',
                            'transform'         : 'translateX(450px) translateZ(-300px) rotateY(-45deg)',
                            'opacity'           : 0,
                            'visibility'        : 'hidden'
                        };
                        break;
                    case 'left':
                        return {
                            '-webkit-transform' : 'translateX(-350px) translateZ(-200px) rotateY(45deg)',
                            '-moz-transform'    : 'translateX(-350px) translateZ(-200px) rotateY(45deg)',
                            '-o-transform'      : 'translateX(-350px) translateZ(-200px) rotateY(45deg)',
                            '-ms-transform'     : 'translateX(-350px) translateZ(-200px) rotateY(45deg)',
                            'transform'         : 'translateX(-350px) translateZ(-200px) rotateY(45deg)',
                            'opacity'           : sider_opacity,
                            'visibility'        : 'visible'
                        };
                        break;
                    case 'right':
                        return {
                            '-webkit-transform' : 'translateX(350px) translateZ(-200px) rotateY(-45deg)',
                            '-moz-transform'    : 'translateX(350px) translateZ(-200px) rotateY(-45deg)',
                            '-o-transform'      : 'translateX(350px) translateZ(-200px) rotateY(-45deg)',
                            '-ms-transform'     : 'translateX(350px) translateZ(-200px) rotateY(-45deg)',
                            'transform'         : 'translateX(350px) translateZ(-200px) rotateY(-45deg)',
                            'opacity'           : sider_opacity,
                            'visibility'        : 'visible'
                        };
                        break;
                    case 'center':
                        return {
                            '-webkit-transform' : 'translateX(0px) translateZ(0px) rotateY(0deg)',
                            '-moz-transform'    : 'translateX(0px) translateZ(0px) rotateY(0deg)',
                            '-o-transform'      : 'translateX(0px) translateZ(0px) rotateY(0deg)',
                            '-ms-transform'     : 'translateX(0px) translateZ(0px) rotateY(0deg)',
                            'transform'         : 'translateX(0px) translateZ(0px) rotateY(0deg)',
                            'opacity'           : 1,
                            'visibility'        : 'visible'
                        };
                        break;
                };
            
            }
            else if( this.support2d && this.supportTrans ) {
            
                switch( position ) {
                    case 'outleft':
                        return {
                            '-webkit-transform' : 'translate(-450px) scale(0.7)',
                            '-moz-transform'    : 'translate(-450px) scale(0.7)',
                            '-o-transform'      : 'translate(-450px) scale(0.7)',
                            '-ms-transform'     : 'translate(-450px) scale(0.7)',
                            'transform'         : 'translate(-450px) scale(0.7)',
                            'opacity'           : 0,
                            'visibility'        : 'hidden'
                        };
                        break;
                    case 'outright':
                        return {
                            '-webkit-transform' : 'translate(450px) scale(0.7)',
                            '-moz-transform'    : 'translate(450px) scale(0.7)',
                            '-o-transform'      : 'translate(450px) scale(0.7)',
                            '-ms-transform'     : 'translate(450px) scale(0.7)',
                            'transform'         : 'translate(450px) scale(0.7)',
                            'opacity'           : 0,
                            'visibility'        : 'hidden'
                        };
                        break;
                    case 'left':
                        return {
                            '-webkit-transform' : 'translate(-350px) scale(0.8)',
                            '-moz-transform'    : 'translate(-350px) scale(0.8)',
                            '-o-transform'      : 'translate(-350px) scale(0.8)',
                            '-ms-transform'     : 'translate(-350px) scale(0.8)',
                            'transform'         : 'translate(-350px) scale(0.8)',
                            'opacity'           : sider_opacity,
                            'visibility'        : 'visible'
                        };
                        break;
                    case 'right':
                        return {
                            '-webkit-transform' : 'translate(350px) scale(0.8)',
                            '-moz-transform'    : 'translate(350px) scale(0.8)',
                            '-o-transform'      : 'translate(350px) scale(0.8)',
                            '-ms-transform'     : 'translate(350px) scale(0.8)',
                            'transform'         : 'translate(350px) scale(0.8)',
                            'opacity'           : sider_opacity,
                            'visibility'        : 'visible'
                        };
                        break;
                    case 'center':
                        return {
                            '-webkit-transform' : 'translate(0px) scale(1)',
                            '-moz-transform'    : 'translate(0px) scale(1)',
                            '-o-transform'      : 'translate(0px) scale(1)',
                            '-ms-transform'     : 'translate(0px) scale(1)',
                            'transform'         : 'translate(0px) scale(1)',
                            'opacity'           : 1,
                            'visibility'        : 'visible'
                        };
                        break;
                };
            
            }
            else {
            
                switch( position ) {
                    case 'outleft'  : 
                    case 'outright' : 
                    case 'left'     : 
                    case 'right'    :
                        return {
                            'opacity'           : 0,
                            'visibility'        : 'hidden'
                        };
                        break;
                    case 'center'   :
                        return {
                            'opacity'           : 1,
                            'visibility'        : 'visible'
                        };
                        break;
                };
            
            }
        
        },
        _navigate           : function( dir ) {
            
            if( this.supportTrans && this.isAnim )
                return false;
                
            this.isAnim = true;
            
            switch( dir ) {
            
                case 'next' :
                    
                    this.current    = this.$rightItm.index();
                    
                    // current item moves left
                    this.$currentItm.addClass('dg-transition').css( this._getCoordinates('left') );
                    
                    // right item moves to the center
                    this.$rightItm.addClass('dg-transition').css( this._getCoordinates('center') ); 
                    
                    // next item moves to the right
                    if( this.$nextItm ) {
                        
                        // left item moves out
                        this.$leftItm.addClass('dg-transition').css( this._getCoordinates('outleft') );
                        
                        this.$nextItm.addClass('dg-transition').css( this._getCoordinates('right') );
                        
                    }
                    else {
                    
                        // left item moves right
                        this.$leftItm.addClass('dg-transition').css( this._getCoordinates('right') );
                    
                    }
                    break;
                    
                case 'prev' :
                
                    this.current    = this.$leftItm.index();
                    
                    // current item moves right
                    this.$currentItm.addClass('dg-transition').css( this._getCoordinates('right') );
                    
                    // left item moves to the center
                    this.$leftItm.addClass('dg-transition').css( this._getCoordinates('center') );
                    
                    // prev item moves to the left
                    if( this.$prevItm ) {
                        
                        // right item moves out
                        this.$rightItm.addClass('dg-transition').css( this._getCoordinates('outright') );
                    
                        this.$prevItm.addClass('dg-transition').css( this._getCoordinates('left') );
                        
                    }
                    else {
                    
                        // right item moves left
                        this.$rightItm.addClass('dg-transition').css( this._getCoordinates('left') );
                    
                    }
                    break;  
                    
            };
            
            this._setItems();
            
            if( !this.supportTrans )
                this.$currentItm.addClass('dg-center');
            
        },
        _startSlideshow     : function() {
        
            var _self   = this;
            
            this.slideshow  = setTimeout( function() {
                
                _self._navigate( 'next' );
                
                if( _self.options.autoplay ) {
                
                    _self._startSlideshow();
                
                }
            
            }, this.options.interval );
        
        },
        destroy             : function() {
            
            this.$navPrev.off('.gallery');
            this.$navNext.off('.gallery');
            this.$wrapper.off('.gallery');
            
        }
    };
    
    var logError            = function( message ) {
        if ( this.console ) {
            console.error( message );
        }
    };
    
    $.fn.gallery            = function( options ) {
    
        if ( typeof options === 'string' ) {
            
            var args = Array.prototype.slice.call( arguments, 1 );
            
            this.each(function() {
            
                var instance = $.data( this, 'gallery' );
                
                if ( !instance ) {
                    logError( "cannot call methods on gallery prior to initialization; " +
                    "attempted to call method '" + options + "'" );
                    return;
                }
                
                if ( !$.isFunction( instance[options] ) || options.charAt(0) === "_" ) {
                    logError( "no such method '" + options + "' for gallery instance" );
                    return;
                }
                
                instance[ options ].apply( instance, args );
            
            });
        
        } 
        else {
        
            this.each(function() {
            
                var instance = $.data( this, 'gallery' );
                if ( !instance ) {
                    $.data( this, 'gallery', new $.Gallery( options, this ) );
                }
            });
        
        }
        
        return this;
        
    };
    
})( jQuery );