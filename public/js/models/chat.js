(function() {
  define(["underscore", "backbone", "socketio", "text!templates/message.html"], function(_, Backbone, io, Template) {
    return Backbone.Model.extend({
      initialize: function(options) {
        this.messages = $(".messages");
        this.window = $(window);
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
        this.username = u;
        m = message.substring(0, 1000);
        m = m.trim();
        if (this.messageSent) {
          return this.showSpam(m);
        }
        _gaq.push(['_trackPageview']);
        if (!m.length) {
          return;
        }
        if (this.lastMessage === m) {
          return this.showSpam(m);
        }
        this.socket.emit("message", {
          u: u,
          m: m,
          r: r
        });
        this.messageSent = true;
        this.lastMessage = m;
        this.timeout = setTimeout(function() {
          that.messageSent = false;
        }, 3000);
      },
      showSpam: function(m) {
        return this.showMessage({
          u: this.username,
          m: m
        });
      },
      showMessage: function(data) {
        var color, last, m, me, message, that, username;
        that = this;
        me = this.username === data.u;
        message = _.escape(data.m);
        message = message.replace("&#x27;", "'");
        message = that.linkify(message);
        message = message.replace("[tonninseteli]", '<img src="http://cdn.userpics.com/upload/tonninseteli.jpg"' + ' style="width:30px;height:30px;">');
        color = data.u.toString(16).substring(0, 6);
        username = data.u;
        m = message;
        this.messages.append(_.template(Template, {
          m: m,
          me: me,
          color: color,
          username: username
        }));
        last = $(".message:last").offset().top;
        return this.window.scrollTop(last);
      },
      listenChat: function() {
        var that;
        that = this;
        return this.socket.on("message", function(data) {
          return that.showMessage(data);
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
          return $(".room").val(room);
        });
      },
      listenLeave: function() {
        return this.socket.on("leave", function(room) {});
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
        re = ["#([a-z0-9_-]+)", "&gt;&gt;([0-9]+)"];
        re = new RegExp(re.join("|"), "gi");
        return str.replace(re, function(match, twitler, ylilauta) {
          if (twitler) {
            return "<a href=\"/#" + twitler + "\">#" + twitler + "</a>";
          }
          if (ylilauta) {
            return "<a href=\"http://ylilauta.org/scripts/redirect.php?id=" + ylilauta + "\">&gt;&gt;" + ylilauta + "</a>";
          }
          return match;
        });
      }
    });
  });

}).call(this);
