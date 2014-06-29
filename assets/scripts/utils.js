// Generated by CoffeeScript 1.7.1
(function() {
  'use strict';
  var app,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __slice = [].slice;

  app = window.Tuneinwithme = {};

  app.Base = (function() {
    function Base() {
      this.bindings = {};
      this["class"] = this.constructor;
      this.init.apply(this, arguments);
    }

    Base.prototype.init = function() {
      throw new Error('Base is abstract');
    };

    Base.prototype.on = function(event, callback) {
      if (!(event in this.bindings)) {
        this.bindings[event] = [];
      }
      return this.bindings[event].push(callback);
    };

    Base.prototype.trigger = function(thread, event) {
      var callback, _i, _len, _ref, _results;
      if (!(thread && event)) {
        throw new Error('Both thread and event are required for obj.trigger. Use obj.triggerThread if you want to start a new thread.');
      }
      if (!(event in this.bindings)) {
        thread["continue"]();
      }
      _ref = this.bindings[event];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        _results.push(thread.stackAndContinue(function() {
          return callback(thread);
        }));
      }
      return _results;
    };

    Base.prototype.triggerThread = function(event) {
      var thread;
      thread = new app.Thread("" + this["class"] + " " + event);
      thread.run((function(_this) {
        return function() {
          return _this.trigger(thread, event);
        };
      })(this));
      return thread;
    };

    return Base;

  })();

  app.Thread = (function() {
    function Thread(name) {
      this.name = name;
      this.done = __bind(this.done, this);
      this.error = __bind(this.error, this);
      this["continue"] = __bind(this["continue"], this);
      this.run = __bind(this.run, this);
      this.vars = {};
      this.running = false;
    }

    Thread.prototype.run = function(functions, errorFunction) {
      this.functions = functions;
      this.errorFunction = errorFunction;
      if (!(this.functions instanceof Array)) {
        this.functions = [this.functions];
      }
      if (this.functions[0] === void 0) {
        throw new Error("Cannot run empty thread.");
      }
      this.i = 0;
      this._unfinish();
      return this["continue"]();
    };

    Thread.prototype["continue"] = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (this.i < this.functions.length) {
        return (_ref = this.functions)[this.i++].apply(_ref, args);
      } else {
        return this._finish();
      }
    };

    Thread.prototype.error = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (this.errorFunction) {
        this.errorFunction.apply(this, args);
      } else {
        console.warn("Error function doesn't exist for thread.");
      }
      return this._finish();
    };

    Thread.prototype.done = function() {
      return this._finish();
    };

    Thread.prototype._unfinish = function() {
      var current;
      this.running = true;
      current = this.constructor.current;
      return current.push(this);
    };

    Thread.prototype._finish = function() {
      var current, t, _ref;
      if (!this.running) {
        throw new Error("Can't continue terminated thread.");
      }
      this.running = false;
      current = this.constructor.current;
      if ((t = current.indexOf(this)) > -1) {
        return ([].splice.apply(current, [t, t - t + 1].concat(_ref = [])), _ref);
      } else {
        throw new Error("Internal error: Can't remove thread from unfinished list. Have thread.running or Thread.current been manually modified?");
      }
    };

    Thread.prototype.queue = function(functions) {
      var _ref;
      if (!(functions instanceof Array)) {
        functions = [functions];
      }
      return (_ref = this.functions).push.apply(_ref, functions);
    };

    Thread.prototype.queueAndContinue = function(functions) {
      this.queue(functions);
      return this["continue"]();
    };

    Thread.prototype.stack = function(functions) {
      var _ref;
      if (!(functions instanceof Array)) {
        functions = [functions];
      }
      return (_ref = this.functions).splice.apply(_ref, [this.i, 0].concat(__slice.call(functions)));
    };

    Thread.prototype.stackAndContinue = function(functions) {
      this.stack(functions);
      return this["continue"]();
    };

    Thread.current = [];

    return Thread;

  })();

}).call(this);
