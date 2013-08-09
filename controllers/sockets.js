(function() {
  module.exports = function(server) {
    var broadcast, clientBroadcast, clients, clientsCount, rooms, send, sockjs;
    sockjs = require("sockjs");
    send = sockjs.createServer();
    clients = sockjs.createServer();
    broadcast = {};
    rooms = {};
    clientBroadcast = {};
    clientsCount = 0;
    send.on("connection", function(conn) {
      var lastMessage, messageSent;
      broadcast[conn.id] = conn;
      messageSent = null;
      lastMessage = null;
      conn.on("close", function() {
        var id, _results;
        delete broadcast[conn.id];
        _results = [];
        for (id in rooms) {
          if (rooms[id][conn.id]) {
            delete rooms[id][conn.id];
          }
          if (!Object.keys(rooms[id])) {
            _results.push(delete rooms[id]);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      return conn.on("data", function(data) {
        var id, room, _ref, _results;
        data = JSON.parse(data);
        room = data.r || "";
        console.log("room", room);
        if (!rooms[room]) {
          rooms[room] = {};
        }
        rooms[room][conn.id] = conn;
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
        _results = [];
        for (id in rooms[room]) {
          _results.push(rooms[room][id].write(JSON.stringify(data)));
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
