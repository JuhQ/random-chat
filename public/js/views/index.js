(function() {
  define(["jquery", "underscore", "backbone", "models/chat", "collections/boards"], function($, _, Backbone, Model, BoardsCollection) {
    return Backbone.View.extend({
      el: "body",
      events: {
        "submit form": "sendMessage"
      },
      mainRoom: "random",
      random: function(min, max) {
        return min + Math.round(Math.random() * (max - min));
      },
      initialize: function() {
        this.username = String(this.random(0, (new Date()).getTime())).substring(0, 10);
        this.username = Number(this.username);
        $("input[name='message']").bind("paste", function(e) {
          e.preventDefault();
          return alert("homo älä pastee");
        });
      },
      setOptions: function(options) {
        var room;
        room = options.room || this.mainRoom;
        if (!this.model) {
          this.model = new Model();
        }
        this.model.setOptions({
          room: room
        });
        return this.setBoards(room);
      },
      leaveRoom: function() {
        this.model.leaveRoom($(".room").val());
        return this.$(".messages").html("");
      },
      sendMessage: function(event) {
        var input, message, room;
        event.preventDefault();
        input = $(event.target).find("input[name='message']");
        message = input.val();
        if (!message) {
          return;
        }
        input.val("");
        input.focus();
        room = $(".room").val();
        return this.model.send(this.username, message, room);
      },
      setBoards: function(room) {
        var board, rooms;
        if (!this.boards) {
          this.boards = new BoardsCollection();
        }
        board = this.boards.find(function(model) {
          return model.get("boardurl") === room;
        });
        if (board) {
          $(".room-name").text(board.get("boardname"));
        } else {
          $(".room-name").text(room);
        }
        rooms = $(".rooms");
        rooms.html("");
        return this.boards.each(function(model) {
          return rooms.append('<a href="#' + model.get("boardurl") + '">' + model.get("boardname") + '</a> ');
        });
      }
    });
  });

}).call(this);
