(function() {
  define(["views/index"], function(Index) {
    return Backbone.Router.extend({
      routes: {
        "": "room",
        ":room": "room"
      },
      view: null,
      room: function(room) {
        if (this.view) {
          this.view.leaveRoom();
        }
        if (!this.view) {
          this.view = new Index();
        }
        return this.view.setOptions({
          room: room
        });
      }
    });
  });

}).call(this);
