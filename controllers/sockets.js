(function() {
  module.exports = function(server) {
    var broadcast, clientBroadcast, clients, clientsCount, send, sockjs;
    sockjs = require("sockjs");
    send = sockjs.createServer();
    clients = sockjs.createServer();
    broadcast = {};
    clientBroadcast = {};
    clientsCount = 0;
    send.on("connection", function(conn) {
      broadcast[conn.id] = conn;
      conn.on("close", function() {
        return delete broadcast[conn.id];
      });
      return conn.on("data", function(m) {
        var id, _results;
        _results = [];
        for (id in broadcast) {
          _results.push(broadcast[id].write(m));
        }
        return _results;
      });
    });
    clients.on("connection", function(conn) {
      var broadcastCount;
      clientBroadcast[conn.id] = conn;
      clientsCount++;
      broadcastCount = function() {
        var id, _results;
        _results = [];
        for (id in clientBroadcast) {
          _results.push(clientBroadcast[id].write(clientsCount));
        }
        return _results;
      };
      broadcastCount();
      return conn.on("close", function() {
        delete clientBroadcast[conn.id];
        clientsCount--;
        return broadcastCount();
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
