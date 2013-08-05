(function() {
  define(["underscore", "backbone", "socketio", "text!templates/message.html"], function(_, Backbone, io, Template) {
    return Backbone.Model.extend({
      initialize: function(options) {
        this.messageSent = null;
        this.lastMessage = null;
        this.socket = io.connect("http://" + window.location.host);
        this.listenChat();
        this.listenCount();
        this.listenJoin();
        return this.listenLeave();
      },
      setOptions: function(options) {
        var that;
        that = this;
        this.joinRoom(options.room);
        this.oldroom = options.room;
        this.clientCount(options.room);
        clearInterval(this.clientInterval);
        this.clientInterval = setInterval(function() {
          return that.clientCount(options.room);
        }, 2000);
      },
      send: function(u, message, r) {
        var m, that;
        that = this;
        if (this.messageSent) {
          return;
        }
        _gaq.push(['_trackPageview']);
        this.username = u;
        m = message.substring(0, 1000);
        m = m.trim();
        if (!m.length) {
          return;
        }
        if (this.lastMessage === m) {
          return;
        }
        console.log("sending", m);
        this.lastMessage = m;
        this.socket.emit("message", {
          u: u,
          m: m,
          r: r
        });
        this.messageSent = true;
        this.timeout = setTimeout(function() {
          that.messageSent = false;
        }, 3000);
      },
      listenChat: function() {
        var chat, messages, that;
        that = this;
        messages = $(".messages");
        chat = $(window);
        return this.socket.on("message", function(data) {
          var color, last, m, me;
          console.log("receive", data);
          me = that.username === data.u;
          m = _.escape(data.m);
          m = that.linkify(m);
          color = data.u.toString(16).substring(0, 6);
          messages.append(_.template(Template, {
            m: m,
            me: me,
            color: color
          }));
          last = $(".message:last").offset().top;
          return chat.scrollTop(last);
        });
      },
      listenCount: function() {
        var count, that;
        that = this;
        count = $(".count");
        return this.socket.on("clients", function(clients) {
          return count.text(clients);
        });
      },
      clientCount: function(r) {
        return this.socket.emit("count", {
          r: r
        });
      },
      listenJoin: function() {
        var that;
        that = this;
        return this.socket.on("join", function(room) {
          console.log('$(".room").val()"', $(".room").val());
          $(".room").val(room);
          return console.log("join", room);
        });
      },
      listenLeave: function() {
        return this.socket.on("leave", function(room) {
          return console.log("leave", room);
        });
      },
      joinRoom: function(r) {
        return this.socket.emit("join", {
          r: r
        });
      },
      leaveRoom: function(r) {
        return this.socket.emit("leave", {
          r: r
        });
      },
      linkify: function(str) {
        var re;
        re = ["\\b((?:https?|ftp)://[^\\s\"'<>]+)\\b", "\\b(www\\.[^\\s\"'<>]+)\\b", "\\b(\\w[\\w.+-]*@[\\w.-]+\\.[a-z]{2,6})\\b", "#([a-z0-9]+)"];
        re = new RegExp(re.join("|"), "gi");
        return str.replace(re, function(match, url, www, mail, twitler) {
          if (url) {
            return "<a href=\"" + url + "\">" + url + "</a>";
          }
          if (www) {
            return "<a href=\"http://" + www + "\">" + www + "</a>";
          }
          if (mail) {
            return "<a href=\"mailto:" + mail + "\">" + mail + "</a>";
          }
          if (twitler) {
            return "<a href=\"/#" + twitler + "\">#" + twitler + "</a>";
          }
          return match;
        });
      }
    });
  });

}).call(this);
