express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")
app = express()
server = http.createServer(app)
app.configure ->
  app.set "port", process.env.PORT or 3099
  app.set "views", __dirname + "/views"
  app.set "view engine", "ejs"
  app.use express.favicon()
  app.use express.logger("dev")
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


cluster = require("cluster")
numCPUs = require("os").cpus().length

io = require('socket.io').listen(server, {
  "browser client minification": true
  log: false
})
RedisStore = require("socket.io/lib/stores/redis")
redis = require("redis")
pub = redis.createClient()
sub = redis.createClient()
redisClient = redis.createClient()

io.set "store", new RedisStore(
  redisPub: pub
  redisSub: sub
  redisClient: redisClient
)

clients = 0
io.sockets.on "connection", (socket) ->
  clients++
  socket.on "join", (data) ->
    socket.join data.r
    socket.emit "join", data.r

  socket.on "disconnect", () ->
    clients--

  socket.on "leave", (data) ->
    socket.leave data.r
    socket.emit "leave", data.r

  socket.on "count", (data) ->
    #clients = io.sockets.clients(data.r).length
    socket.emit('clients', clients)

  socket.on "message", (data) ->
    return unless data.m?.length
    data.m = data.m.substring(0,1000)
    data.m = data.m.trim()
    return unless data.m.length
    io.sockets.in(data.r).emit('message', data)


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
