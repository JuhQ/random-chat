(function() {
  var RedisStore, app, clientsObject, cluster, express, googleapis, http, i, io, numCPUs, path, pub, redis, redisClient, routes, server, sub;

  express = require("express");

  routes = require("./routes");

  http = require("http");

  path = require("path");

  googleapis = require('googleapis');

  app = express();

  server = http.createServer(app);

  app.configure(function() {
    app.set("port", process.env.PORT || 3099);
    app.set("views", __dirname + "/views");
    app.set("view engine", "ejs");
    app.use(express.favicon());
    app.use(express.logger("dev"));
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.cookieParser("asdf"));
    app.use(express.session());
    app.use(app.router);
    return app.use(express["static"](path.join(__dirname, "public")));
  });

  app.configure("development", function() {
    return app.use(express.errorHandler());
  });

  app.get("/", routes.index);

  app.get("/mad/test", routes.test);

  cluster = require("cluster");

  numCPUs = require("os").cpus().length;

  io = require('socket.io').listen(server, {
    "browser client minification": true,
    log: false
  });

  RedisStore = require("socket.io/lib/stores/redis");

  redis = require("redis");

  pub = redis.createClient();

  sub = redis.createClient();

  redisClient = redis.createClient();

  io.set("store", new RedisStore({
    redisPub: pub,
    redisSub: sub,
    redisClient: redisClient
  }));

  clientsObject = {};

  io.sockets.on("connection", function(socket) {
    var lastMessage, messageSent;
    clientsObject[socket.id] = socket;
    messageSent = null;
    lastMessage = null;
    redisClient.get("count", function(err, reply) {
      var clients;
      if (reply === null) {
        clients = 0;
      }
      return redisClient.set("count", Number(reply) + 1);
    });
    socket.on("join", function(data) {
      var room;
      room = data.r;
      socket.join(room);
      socket.emit("join", room);
      return redisClient.get("count", function(err, reply) {
        if (reply === null) {
          reply = 0;
        }
        return io.sockets["in"](room).emit('clients', reply);
      });
    });
    socket.on("disconnect", function() {
      redisClient.get("count", function(err, reply) {
        var clients;
        if (reply === null) {
          clients = 1;
        }
        return redisClient.set("count", Number(reply) - 1);
      });
      return delete clientsObject[socket.id];
    });
    socket.on("leave", function(data) {
      socket.leave(data.r);
      return socket.emit("leave", data.r);
    });
    socket.on("message", function(data) {
      var _ref;
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
      io.sockets["in"](data.r).emit('message', data);
      messageSent = true;
      return setTimeout(function() {
        messageSent = false;
      }, 3000);
    });
    return socket.on("youtube-set", function(data) {
      var googleApiKey, id;
      id = data.id.trim();
      if (!id.length) {
        return;
      }
      googleApiKey = "AIzaSyDftKyCTCHfNw02mbE20RtLP28IX6ME_-g";
      googleapis.discover("youtube", "v3").execute(function(err, client) {
        var asd;
        asd = client.youtube.videos.list({
          part: "snippet",
          id: id
        }).withApiKey(googleApiKey);
        return asd.execute(function(err, response) {
          var description, title;
          title = response.items[0].snippet.title;
          description = response.items[0].snippet.description.substring(0, 100);
          console.log("description", description);
          console.log("title", title);
          return console.log("id", id);
        });
      });
      return socket.emit("youtube", id);
    });
  });

  if (cluster.isMaster) {
    i = 0;
    while (i < numCPUs) {
      cluster.fork();
      i++;
    }
    cluster.on("exit", function(worker, code, signal) {
      return console.log("worker " + worker.process.pid + " died");
    });
  } else {
    server.listen(app.get("port"), function() {
      return console.log("Express server listening on port " + app.get("port"));
    });
  }

}).call(this);
