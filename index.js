(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("lodash/forEachRight"), require("lodash/throttle"), require("lodash/debounce"), require("lodash/remove"), require("lodash/merge"));
	else if(typeof define === 'function' && define.amd)
		define(["lodash/forEachRight", "lodash/throttle", "lodash/debounce", "lodash/remove", "lodash/merge"], factory);
	else if(typeof exports === 'object')
		exports["window-event-mediator"] = factory(require("lodash/forEachRight"), require("lodash/throttle"), require("lodash/debounce"), require("lodash/remove"), require("lodash/merge"));
	else
		root["window-event-mediator"] = factory(root["lodash/forEachRight"], root["lodash/throttle"], root["lodash/debounce"], root["lodash/remove"], root["lodash/merge"]);
})(this, function(__WEBPACK_EXTERNAL_MODULE_1__, __WEBPACK_EXTERNAL_MODULE_2__, __WEBPACK_EXTERNAL_MODULE_3__, __WEBPACK_EXTERNAL_MODULE_4__, __WEBPACK_EXTERNAL_MODULE_5__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	
	/*
	Mediator pattern for window event listeners

	Example Usage:
		mediator = require 'window-event-mediator'
		mediator.on 'resize', myCallback
		mediator.off 'scroll', mycallback
	 */
	var WindowEventMediator, debounce, forEachRight, merge, remove, throttle,
	  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

	forEachRight = __webpack_require__(1);

	throttle = __webpack_require__(2);

	debounce = __webpack_require__(3);

	remove = __webpack_require__(4);

	merge = __webpack_require__(5);

	WindowEventMediator = (function() {
	  function WindowEventMediator() {
	    this.fire = bind(this.fire, this);
	    this.set = bind(this.set, this);
	    this.off = bind(this.off, this);
	    this.on = bind(this.on, this);
	  }

	  WindowEventMediator.prototype.handlers = {};

	  WindowEventMediator.prototype.defaults = {
	    throttle: 100,
	    debounce: 0,
	    dispatcher: {
	      scroll: window,
	      "default": window
	    }
	  };


	  /*
	  	Register an event handler with the mediator
	  
	  	event - string - event name ('resize', 'scroll', etc) callback - function
	  	options
	  		throttle [100] - int - milliseconds to throttle
	  		debounce [100] - int - milliseconds to debounce
	   */

	  WindowEventMediator.prototype.on = function(event, callback, options) {
	    options = merge({}, this.defaults, options);
	    return this.set(event, callback, options);
	  };


	  /*
	  	Removes any reference to the event type and callback, regardless of Throttle
	  	or Debounce options.
	  
	  	event - string - event name ('resize', 'scroll', etc)
	  	callback - function
	  	options - target specific throttled/debounced refrences to remove.
	   */

	  WindowEventMediator.prototype.off = function(event, callback, options) {
	    var key, results;
	    if (this.handlers[event] == null) {
	      return;
	    }
	    if (options != null) {
	      options = merge({}, this.defaults, options);
	      key = options.throttle + '-' + options.debounce;
	      if (this.handlers[event][key] != null) {
	        remove(this.handlers[event][key], function(cbs) {
	          return cbs.original === callback;
	        });
	        if (this.handlers[event][key].length === 0) {
	          return delete this.handlers[event][key];
	        }
	      }
	    } else {
	      results = [];
	      for (key in this.handlers[event]) {
	        remove(this.handlers[event][key], function(cbs) {
	          return cbs.original === callback;
	        });
	        if (this.handlers[event][key].length === 0) {
	          results.push(delete this.handlers[event][key]);
	        } else {
	          results.push(void 0);
	        }
	      }
	      return results;
	    }
	  };


	  /*
	  	Create an event container for the window event type and
	  	add the actual listener to the window object
	  
	  	event - string - event name ('resize', 'scroll', etc)
	   */

	  WindowEventMediator.prototype.set = function(event, callback, options) {
	    var dispatcher, key, ref;
	    key = options.throttle + '-' + options.debounce;
	    if (this.handlers[event] == null) {
	      this.handlers[event] = {};
	    }
	    dispatcher = (ref = options.dispatcher[event]) != null ? ref : options.dispatcher["default"];
	    if (!this.handlers[event].hasOwnProperty(key)) {
	      this.handlers[event][key] = [];
	      dispatcher.addEventListener(event, this.fire);
	    }
	    return this.handlers[event][key].push({
	      modified: debounce(throttle(callback, options.throttle), options.debounce),
	      original: callback
	    });
	  };


	  /*
	  	Fires all events for a given window event type, padding the native event
	  	object through to the mediated callback. It must be looped through backwards
	  	so that callbacks which are removed during the loop don't break the
	  	iteration.
	  
	  	e - Event - native event object
	   */

	  WindowEventMediator.prototype.fire = function(e) {
	    return forEachRight(this.handlers[e.type], function(bag) {
	      return forEachRight(bag, function(cbs) {
	        cbs.modified(e);
	        return true;
	      });
	    });
	  };

	  return WindowEventMediator;

	})();

	module.exports = new WindowEventMediator();


/***/ },
/* 1 */
/***/ function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_1__;

/***/ },
/* 2 */
/***/ function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_2__;

/***/ },
/* 3 */
/***/ function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_3__;

/***/ },
/* 4 */
/***/ function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_4__;

/***/ },
/* 5 */
/***/ function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_5__;

/***/ }
/******/ ])
});
;