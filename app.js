(function() {
  var app, cluster, express, http, numCPUs, path, routes, server, sock;

  express = require("express");

  routes = require("./routes");

  http = require("http");

  path = require("path");

  cluster = require("cluster");

  numCPUs = require("os").cpus().length;

  app = express();

  app.configure(function() {
    app.set("port", process.env.PORT || 3099);
    app.set("views", __dirname + "/views");
    app.set("view engine", "ejs");
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

  server = http.createServer(app);

  sock = require("./controllers/sockets")(server);

  /*
  if cluster.isMaster
    
    # Fork workers.
    i = 0
    while i < numCPUs
      cluster.fork()
      i++
  
    # Revive dead worker
    cluster.on "exit", (worker, code, signal) ->
      console.log "worker " + worker.process.pid + " died"
      #cluster.fork()
  
  else
  */


  server.listen(app.get("port"), function() {
    return console.log("Express server listening on port " + app.get("port"));
  });

}).call(this);
