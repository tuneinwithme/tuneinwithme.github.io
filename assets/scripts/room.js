// Generated by CoffeeScript 1.7.1
(function() {
  var app,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  app = window.Tuneinwithme;

  app.Room = (function(_super) {
    __extends(Room, _super);

    function Room() {
      return Room.__super__.constructor.apply(this, arguments);
    }

    Room.prototype.init = function(id, active) {
      var url;
      this.id = id;
      this.active = active;
      url = "https://tuneinwithme.firebaseio.com/rooms/" + this.id + "/song/uri";
      console.log("room:", url);
      this.firedata = new Firebase(url);
      this.on('focus', (function(_this) {
        return function() {
          var _ref;
          if (_this === _this["class"].current) {
            return;
          }
          _this["class"].previous = _this["class"].current;
          _this["class"].current = _this;
          if ((_ref = _this["class"].previous) != null) {
            _ref.trigger('blur');
          }
          app.view.trigger('change-room');
          console.log("room: new! " + _this.id);
          _this.active = true;
          return _this.firedata.on('value', function(data) {
            var currentSong;
            console.log("room: incoming song data", data.val());
            if (!(data && data.val())) {
              return;
            }
            currentSong = app.Song.get(data.val());
            return currentSong.trigger('focus');
          });
        };
      })(this));
      this.on('blur', (function(_this) {
        return function() {
          _this.active = false;
          return _this.firedata.off();
        };
      })(this));
      return this.on('change-song', (function(_this) {
        return function() {
          var _ref;
          return _this.firedata.set((_ref = app.Song.current) != null ? _ref.id : void 0);
        };
      })(this));
    };

    Room.all = {};

    Room.get = function(id) {
      if (!(id in Room.all)) {
        Room.all[id] = new Room(id);
      }
      return Room.all[id];
    };

    Room.current = null;

    Room.previous = null;

    return Room;

  })(app.Base);

}).call(this);