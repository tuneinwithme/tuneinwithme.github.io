// Generated by CoffeeScript 1.7.1
(function() {
  var Main, app,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  app = window.Tuneinwithme;

  Main = (function(_super) {
    __extends(Main, _super);

    function Main() {
      return Main.__super__.constructor.apply(this, arguments);
    }

    Main.prototype.init = function() {
      return app.view.trigger('ready');
    };

    return Main;

  })(app.Base);

  app.main = new Main;

}).call(this);
