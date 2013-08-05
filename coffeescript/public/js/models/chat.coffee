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

      @messages = $(".messages")
      @window = $(window)

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

      @username = u
      m = message.substring(0,1000)
      m = m.trim()

      return @showSpam(m) if @messageSent
    
      _gaq.push(['_trackPageview'])
      return unless m.length
      return @showSpam(m) if @lastMessage is m

      @socket.emit "message", {u, m, r}

      @messageSent = true
      @lastMessage = m

      @timeout = setTimeout ->
        that.messageSent = false
        return
      , 3000
      return

    showSpam: (m) ->
      @showMessage u: @username, m: m

    showMessage: (data) ->
      that = @
      me = @username is data.u
      m = _.escape data.m
      m = that.linkify m
      color = data.u.toString(16).substring(0,6)
      @messages.append _.template Template, {m, me, color}

      last = $(".message:last").offset().top
      @window.scrollTop last

    listenChat: ->
      that = @
      @socket.on "message", (data) ->
        that.showMessage(data)

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
        $(".room").val(room)

    listenLeave: ->
      @socket.on "leave", (room) ->


    joinRoom: (r) ->
      @socket.emit "join",
        {r}

    leaveRoom: (r) ->
      @socket.emit "leave",
        {r}

    linkify: (str) ->
      re = [
            "#([a-z0-9]+)"
            "&gt;&gt;([0-9]+)"
          ]
      re = new RegExp(re.join("|"), "gi")
      str.replace re, (match, twitler, ylilauta) ->
        return "<a href=\"/#" + twitler + "\">#" + twitler + "</a>" if twitler
        return "<a href=\"http://ylilauta.org/scripts/redirect.php?id=" + ylilauta + "\">&gt;&gt;" + ylilauta + "</a>" if ylilauta

        match
