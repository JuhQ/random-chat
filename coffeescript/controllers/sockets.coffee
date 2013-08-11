module.exports = (server) ->
  sockjs = require("sockjs")
  redis = require("redis")

  # Redis publisher
  publisher = redis.createClient()

  send = sockjs.createServer()
  clients = sockjs.createServer()

  send.on "connection", (conn) ->
    redisClient = redis.createClient()

    messageSent = null
    lastMessage = null

    # When we see a message on chat_channel, send it to the browser
    redisClient.on "message", (channel, message) ->
      conn.write message

    conn.on "data", (data) ->
      data = JSON.parse data

      room = data.r or ""

      redisClient.subscribe room

      return unless data.m?.length
      return if messageSent
  
      return if lastMessage is data.m
      lastMessage = data.m
  
      data.m = data.m.substring(0,1000)
      data.m = data.m.trim()
      return unless data.m.length
  
      messageSent = true
      setTimeout ->
        messageSent = false
        return
      , 3000

      publisher.publish room, JSON.stringify data

  clients.on "connection", (conn) ->
    redisClient = redis.createClient()
    clientCount = redis.createClient()
    redisClient.subscribe "count"

    clientCount.get "clientCount", (err, reply) ->
      reply = 0 if reply is null
      clientCount.set "clientCount", Number(reply) + 1

    redisClient.on "message", (channel, message) ->
      conn.write message

    broadcastCount = () ->
      clientCount.get "clientCount", (err, reply) ->
        reply = 0 if reply is null
        publisher.publish "count", reply

    broadcastCount()
    conn.on "close", ->
      clientCount.get "clientCount", (err, reply) ->
        reply = 1 if reply is null
        clientCount.set "clientCount", Number(reply) - 1

        broadcastCount()


  send.installHandlers server, prefix: "/send"
  clients.installHandlers server, prefix: "/clients"