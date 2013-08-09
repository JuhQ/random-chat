module.exports = (server) ->
  sockjs = require("sockjs")
  send = sockjs.createServer()
  clients = sockjs.createServer()

  broadcast = {}
  rooms = {}
  clientBroadcast = {}
  clientsCount = 0

  send.on "connection", (conn) ->
    broadcast[conn.id] = conn

    messageSent = null
    lastMessage = null

    conn.on "close", ->
      delete broadcast[conn.id]

      for id of rooms
        if rooms[id][conn.id]
          delete rooms[id][conn.id]
        unless Object.keys(rooms[id])
          delete rooms[id]


    conn.on "data", (data) ->
      data = JSON.parse data

      room = data.r or ""

      console.log "room", room

      rooms[room] = {} unless rooms[room]
      rooms[room][conn.id] = conn

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

      for id of rooms[room]
        rooms[room][id].write JSON.stringify data
        #broadcast[id].write JSON.stringify data

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