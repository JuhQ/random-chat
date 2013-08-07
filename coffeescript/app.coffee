express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")
googleapis = require('googleapis')
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

clientsObject = {}
io.sockets.on "connection", (socket) ->
  clientsObject[socket.id] = socket
  messageSent = null
  lastMessage = null

  redisClient.get "count", (err, reply) ->
    clients = 0 if reply is null
    redisClient.set "count", Number(reply) + 1

  socket.on "join", (data) ->
    room = data.r
    socket.join room
    socket.emit "join", room

    redisClient.get "count", (err, reply) ->
      reply = 0 if reply is null
      io.sockets.in(room).emit('clients', reply)

  socket.on "disconnect", () ->
    redisClient.get "count", (err, reply) ->
      clients = 1 if reply is null
      redisClient.set "count", Number(reply) - 1
    delete clientsObject[socket.id]

  socket.on "leave", (data) ->
    socket.leave data.r
    socket.emit "leave", data.r

  socket.on "message", (data) ->
    return unless data.m?.length
    return if messageSent

    return if lastMessage is data.m
    lastMessage = data.m

    data.m = data.m.substring(0,1000)
    data.m = data.m.trim()
    return unless data.m.length
    io.sockets.in(data.r).emit('message', data)

    messageSent = true
    setTimeout ->
      messageSent = false
      return
    , 3000


  socket.on "youtube-set", (data) ->
    id = data.id.trim()
    return unless id.length

    googleApiKey = "AIzaSyDftKyCTCHfNw02mbE20RtLP28IX6ME_-g"
    googleapis.discover("youtube", "v3").execute (err, client) ->
      asd = client.youtube.videos.list(part: "snippet", id: id).withApiKey(googleApiKey)
      asd.execute (err, response) ->

        title = response.items[0].snippet.title
        description = response.items[0].snippet.description.substring(0, 100)

        console.log "description", description
        console.log "title", title
        console.log "id", id

    socket.emit "youtube", id



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
