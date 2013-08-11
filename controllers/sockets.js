(function() {
  module.exports = function(server) {
    var clientCount, clients, publisher, redis, send, sockjs, userCountClient;
    sockjs = require("sockjs");
    redis = require("redis");
    publisher = redis.createClient();
    userCountClient = redis.createClient();
    clientCount = redis.createClient();
    clientCount.subscribe("count");
    send = sockjs.createServer();
    clients = sockjs.createServer();
    send.on("connection", function(conn) {
      var lastMessage, messageSent, redisClient;
      redisClient = redis.createClient();
      messageSent = null;
      lastMessage = null;
      redisClient.on("message", function(channel, message) {
        return conn.write(message);
      });
      conn.on("close", function() {
        return redisClient.end();
      });
      return conn.on("data", function(data) {
        var room, _ref;
        data = JSON.parse(data);
        room = data.r || "";
        redisClient.subscribe(room);
        if (!((_ref = data.m) != null ? _ref.length : void 0)) {
          return;
        }
        if (messageSent) {
          return;
        }
        if (lastMessage === data.m) {
          return;
        }
        lastMessage = data.m;
        data.m = data.m.substring(0, 1000);
        data.m = data.m.trim();
        if (!data.m.length) {
          return;
        }
        messageSent = true;
        setTimeout(function() {
          messageSent = false;
        }, 3000);
        return publisher.publish(room, JSON.stringify(data));
      });
    });
    clients.on("connection", function(conn) {
      var broadcastCount;
      userCountClient.get("clientCount", function(err, reply) {
        if (reply === null || null) {
          reply = 0;
        }
        return userCountClient.set("clientCount", Number(reply) + 1);
      });
      clientCount.on("message", function(channel, message) {
        return conn.write(message);
      });
      broadcastCount = function() {
        return userCountClient.get("clientCount", function(err, reply) {
          if (reply === null || err) {
            reply = 0;
          }
          return publisher.publish("count", reply);
        });
      };
      broadcastCount();
      return conn.on("close", function() {
        return userCountClient.get("clientCount", function(err, reply) {
          if (reply === null || null) {
            reply = 1;
          }
          userCountClient.set("clientCount", Number(reply) - 1);
          return broadcastCount();
        });
      });
    });
    send.installHandlers(server, {
      prefix: "/send"
    });
    return clients.installHandlers(server, {
      prefix: "/clients"
    });
  };

}).call(this);
