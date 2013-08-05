define [
  "underscore"
  "backbone"
  "socketio"
  "text!templates/message.html"
  ], (
  _
  Backbone
  io
  Template
  ) ->
  Backbone.Model.extend
    initialize: (options) ->
      @messageSent = null
      @lastMessage = null
      @socket = io.connect("http://" + window.location.host)
      @listenChat()

      @listenCount()
      @listenJoin()
      @listenLeave()


    setOptions: (options) ->
      that = @
      @joinRoom options.room
      @oldroom = options.room
      @clientCount(options.room)

      clearInterval @clientInterval
      @clientInterval = setInterval ->
        that.clientCount(options.room)
      , 2000
      return


    send: (u, message, r) ->
      that = @
      return if @messageSent
    
      _gaq.push(['_trackPageview'])
      @username = u
      m = message.substring(0,1000)
      m = m.trim()
      return unless m.length
      return if @lastMessage is m
      console.log "sending", m
      @lastMessage = m
      @socket.emit "message",
        {u, m, r}
      @messageSent = true

      @timeout = setTimeout ->
        that.messageSent = false
        return
      , 3000
      return

    listenChat: ->
      that = @
      messages = $(".messages")
      chat = $(window)
      @socket.on "message", (data) ->
        console.log "receive", data
        me = that.username is data.u
        m = _.escape data.m
        m = that.linkify m
        color = data.u.toString(16).substring(0,6)
        messages.append _.template Template, {m, me, color}

        last = $(".message:last").offset().top
        chat.scrollTop last

    listenCount: ->
      that = @
      count = $(".count")
      @socket.on "clients", (clients) ->
        count.text clients

    clientCount: (r) ->
      @socket.emit "count",
        {r}

    listenJoin: ->
      that = @
      @socket.on "join", (room) ->
        console.log '$(".room").val()"', $(".room").val()

        $(".room").val(room)
        console.log "join", room

    listenLeave: ->
      @socket.on "leave", (room) ->
        console.log "leave", room

    joinRoom: (r) ->
      @socket.emit "join",
        {r}

    leaveRoom: (r) ->
      @socket.emit "leave",
        {r}

    linkify: (str) ->
      
      # order matters
      re = [
            "\\b((?:https?|ftp)://[^\\s\"'<>]+)\\b"
            "\\b(www\\.[^\\s\"'<>]+)\\b"
            "\\b(\\w[\\w.+-]*@[\\w.-]+\\.[a-z]{2,6})\\b"
            "#([a-z0-9]+)"
          ]
      re = new RegExp(re.join("|"), "gi")
      str.replace re, (match, url, www, mail, twitler) ->
        return "<a href=\"" + url + "\">" + url + "</a>"  if url
        return "<a href=\"http://" + www + "\">" + www + "</a>"  if www
        return "<a href=\"mailto:" + mail + "\">" + mail + "</a>"  if mail
        return "<a href=\"/#" + twitler + "\">#" + twitler + "</a>"  if twitler
        
        # shouldnt get here, but just in case
        match

