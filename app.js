(function() {
  var RedisStore, app, clients, cluster, express, http, i, io, numCPUs, path, pub, redis, redisClient, routes, server, sub;

  express = require("express");

  routes = require("./routes");

  http = require("http");

  path = require("path");

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

  clients = 0;

  io.sockets.on("connection", function(socket) {
    clients++;
    socket.on("join", function(data) {
      socket.join(data.r);
      return socket.emit("join", data.r);
    });
    socket.on("disconnect", function() {
      return clients--;
    });
    socket.on("leave", function(data) {
      socket.leave(data.r);
      return socket.emit("leave", data.r);
    });
    socket.on("count", function(data) {
      return socket.emit('clients', clients);
    });
    return socket.on("message", function(data) {
      var _ref;
      if (!((_ref = data.m) != null ? _ref.length : void 0)) {
        return;
      }
      data.m = data.m.substring(0, 1000);
      data.m = data.m.trim();
      if (!data.m.length) {
        return;
      }
      return io.sockets["in"](data.r).emit('message', data);
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
