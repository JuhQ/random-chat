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
          return e.preventDefault();
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
        var clearForm, command, input, message, room;
        event.preventDefault();
        input = $(event.target).find("input[name='message']");
        message = input.val();
        if (!message) {
          return;
        }
        clearForm = function() {
          input.val("");
          return input.focus();
        };
        command = message.match(/\/(nick|join|j) ([#-_A-Za-z0-9]+)/i);
        if (command) {
          this.commands(command);
          clearForm();
          return;
        }
        clearForm();
        room = $(".room").val();
        return this.model.send(this.username, message, room);
      },
      commands: function(command) {
        var _ref;
        if ((_ref = command[1]) === "join" || _ref === "j") {
          Backbone.history.navigate("#" + command[2].replace("#", ""));
        } else if (command[1] === "nick") {
          this.username = command[2];
        }
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
