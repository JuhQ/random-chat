module.exports = (server) ->
  sockjs = require("sockjs")
  send = sockjs.createServer()
  clients = sockjs.createServer()

  broadcast = {}
  clientBroadcast = {}
  clientsCount = 0

  send.on "connection", (conn) ->
    broadcast[conn.id] = conn

    messageSent = null
    lastMessage = null

    conn.on "close", ->
      delete broadcast[conn.id]

    conn.on "data", (message) ->
      return unless message?.length
      return if messageSent
  
      return if lastMessage is message
      lastMessage = message
  
      message = message.substring(0,1000)
      message = message.trim()
      return unless message.length
  
      messageSent = true
      setTimeout ->
        messageSent = false
        return
      , 3000

      for id of broadcast
        broadcast[id].write message

  clients.on "connection", (conn) ->
    clientBroadcast[conn.id] = conn
    clientsCount++
    broadcastCount = ->
      for id of clientBroadcast
        clientBroadcast[id].write clientsCount

    broadcastCount()
    conn.on "close", ->
      delete clientBroadcast[conn.id]
      clientsCount--
      broadcastCount()



  send.installHandlers server, prefix: "/send"
  clients.installHandlers server, prefix: "/clients"