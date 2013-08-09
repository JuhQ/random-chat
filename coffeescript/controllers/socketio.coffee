module.exports = (server) ->
  ###
  io = require('socket.io').listen server,
    "browser client minification": true
    log: false

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

    socket.on "reset-counter", (data) ->
      redisClient.set "count", 0

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

      youtube id, ->
        socket.emit "youtube", id
  ###
