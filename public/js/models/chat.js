(function() {
  define(["underscore", "backbone", "socketio", "text!templates/message.html"], function(_, Backbone, io, Template) {
    return Backbone.Model.extend({
      initialize: function(options) {
        this.messages = $(".messages");
        this.window = $(window);
        this.messageSent = null;
        this.lastMessage = null;
        this.connect();
        this.listenChat();
        this.listenCount();
        this.listenJoin();
        this.listenLeave();
        return this.listenDisconnect();
      },
      connect: function() {
        this.socket = io.connect("http://" + window.location.host);
      },
      setOptions: function(options) {
        return this.joinRoom(options.room);
      },
      send: function(u, message, r) {
        var m, that;
        that = this;
        u = String(u).substring(0, 25);
        this.username = u;
        m = message.substring(0, 1000);
        m = m.trim();
        _gaq.push(['_trackPageview']);
        if (!m.length) {
          return;
        }
        if (this.messageSent) {
          return this.showSpam(m);
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
        setTimeout(function() {
          that.messageSent = false;
        }, 3000);
      },
      showSpam: function(m) {
        return this.showMessage({
          u: this.username,
          m: m
        });
      },
      parseMessage: function(message) {
        message = _.escape(message.substring(0, 1000));
        message = message.replace(/&#x27;/gi, "'");
        message = this.linkify(message);
        return message;
      },
      showMessage: function(data) {
        var color, img, me, message, style, that, username;
        that = this;
        me = this.username === data.u;
        message = this.parseMessage(data.m);
        img = '<img src="http://';
        style = '" style="width:30px;height:30px;" class="img-circle">';
        message = message.replace(/(\[tonninseteli\])/gi, img + 'cdn.userpics.com/upload/tonninseteli.jpg' + style);
        message = message.replace(/(\[hitler\])/gi, img + 'static.ylilauta.org/files/wb/orig/1366214983604638.gif' + style);
        message = message.replace(/(\[ylilauta\])/gi, img + 'meemi.info/images/2/2a/Norppa_ylilauta_175px.png' + style);
        message = message.replace(/(\[es\])/gi, img + 'static.ylilauta.org/files/ux/orig/1365450810932532.jpg' + style);
        message = message.replace(/(\[spurdo\])/gi, img + 'static.ylilauta.org/files/2s/orig/1367332063683775.png' + style);
        message = message.replace(/(\[nakkivene\])/gi, img + 'static.ylilauta.org/files/45/orig/1370161671660103.png' + style);
        message = message.replace(/(\[skeletor\])/gi, img + 'static.ylilauta.org/files/33/orig/1366231280662468.jpg' + style);
        message = message.replace(/(\[dolan\])/gi, img + 'static.ylilauta.org/files/tb/orig/1366557461577278.jpg' + style);
        message = message.replace(/(\[dolan2\])/gi, img + 'static.ylilauta.org/files/hh/orig/13705610491069.jpg' + style);
        message = message.replace(/(\[dolan3\])/gi, img + 'static.ylilauta.org/files/mc/orig/1367351888390750.png' + style);
        message = message.replace(/(\[gooby\])/gi, img + 'static.ylilauta.org/files/q5/thumb/1372413598106457.png' + style);
        message = message.replace(/(\[gooby2\])/gi, img + 'static.ylilauta.org/files/gb/orig/1366516940725793.png' + style);
        message = message.replace(/(\[tableflip\])/gi, img + 'static.ylilauta.org/files/be/orig/1372464326784921.jpg' + style);
        message = message.replace(/(\[turku\])/gi, img + 'static.ylilauta.org/files/4z/thumb/1366709495720484.jpg' + style);
        message = message.replace(/(\[le_rainface\])/gi, img + 'static.ylilauta.org/files/ry/thumb/1375913804152820.gif' + style);
        message = message.replace(/(\[rage\])/gi, img + 'static.ylilauta.org/files/os/orig/136600298030015.png' + style);
        message = message.replace(/(\[poni\])/gi, img + 'static.ylilauta.org/files/2x/orig/137349973989444.gif' + style);
        username = _.escape(String(data.u).substring(0, 25));
        username = username.replace(/(\[tonninseteli\])/gi, img + 'cdn.userpics.com/upload/tonninseteli.jpg' + style);
        username = username.replace(/(\[hitler\])/gi, img + 'static.ylilauta.org/files/wb/orig/1366214983604638.gif' + style);
        username = username.replace(/(\[ylilauta\])/gi, img + 'meemi.info/images/2/2a/Norppa_ylilauta_175px.png' + style);
        username = username.replace(/(\[es\])/gi, img + 'static.ylilauta.org/files/ux/orig/1365450810932532.jpg' + style);
        username = username.replace(/(\[spurdo\])/gi, img + 'static.ylilauta.org/files/2s/orig/1367332063683775.png' + style);
        username = username.replace(/(\[nakkivene\])/gi, img + 'static.ylilauta.org/files/45/orig/1370161671660103.png' + style);
        username = username.replace(/(\[gooby\])/gi, img + 'static.ylilauta.org/files/q5/thumb/1372413598106457.png' + style);
        color = data.u.toString(16).substring(0, 6);
        this.messages.append(_.template(Template, {
          m: message,
          me: me,
          color: color,
          username: username
        }));
        if ($(".message").length > 20) {
          $(".message:first").remove();
        }
        return this.messages.scrollTop(1337);
      },
      listenDisconnect: function() {
        var that;
        that = this;
        return this.socket.on("disconnect", function(data) {
          return that.connect();
        });
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
