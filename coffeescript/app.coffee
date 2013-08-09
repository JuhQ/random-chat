express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")
cluster = require("cluster")
#youtube = require("./controllers/youtube")
numCPUs = require("os").cpus().length

app = express()

app.configure ->
  app.set "port", process.env.PORT or 3099
  app.set "views", __dirname + "/views"
  app.set "view engine", "ejs"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser("asdf")
  app.use express.session()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

app.get "/", routes.index
app.get "/mad/test", routes.test


server = http.createServer(app)
sock = require("./controllers/sockets")(server)
#socketio = require("./controllers/socketio")(server)


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

  server.listen app.get("port"), ->
    console.log "Express server listening on port " + app.get("port")
