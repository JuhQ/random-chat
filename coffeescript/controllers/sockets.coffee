module.exports = (server) ->
  sockjs = require("sockjs")
  send = sockjs.createServer()
  clients = sockjs.createServer()

  broadcast = {}
  clientBroadcast = {}
  clientsCount = 0

  send.on "connection", (conn) ->
    broadcast[conn.id] = conn
    conn.on "close", ->
      delete broadcast[conn.id]

    conn.on "data", (m) ->
      for id of broadcast
        broadcast[id].write m

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