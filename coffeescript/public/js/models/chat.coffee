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
      @connect()

      @listenChat()
      @listenCount()
      @listenJoin()
      @listenLeave()
      @listenDisconnect()

    connect: ->
      @socket = io.connect("http://" + window.location.host)
      return

    setOptions: (options) ->
      that = @
      @joinRoom options.room
      @oldroom = options.room

      return

    send: (u, message, r) ->
      that = @

      u = String(u).substring(0,25)
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

      setTimeout ->
        that.messageSent = false
        return
      , 3000
      return

    showSpam: (m) ->
      @showMessage u: @username, m: m

    parseMessage: (message) ->
      message = _.escape message.substring(0,1000)
      message = message.replace(/&#x27;/gi, "'")
      message = @linkify message

      message


    showMessage: (data) ->
      that = @
      me = @username is data.u

      message = @parseMessage data.m

      img = '<img src="http://'
      style = '" style="width:30px;height:30px;" class="img-circle">'

      message = message.replace(/(\[tonninseteli\])/gi, img + 'cdn.userpics.com/upload/tonninseteli.jpg' + style)
      message = message.replace(/(\[hitler\])/gi, img + 'static.ylilauta.org/files/wb/orig/1366214983604638.gif' + style)
      message = message.replace(/(\[ylilauta\])/gi, img + 'meemi.info/images/2/2a/Norppa_ylilauta_175px.png' + style)
      message = message.replace(/(\[es\])/gi, img + 'static.ylilauta.org/files/ux/orig/1365450810932532.jpg' + style)

      username = _.escape String(data.u).substring(0,25)

      username = username.replace(/(\[tonninseteli\])/gi, img + 'cdn.userpics.com/upload/tonninseteli.jpg' + style)
      username = username.replace(/(\[hitler\])/gi, img + 'static.ylilauta.org/files/wb/orig/1366214983604638.gif' + style)
      username = username.replace(/(\[ylilauta\])/gi, img + 'meemi.info/images/2/2a/Norppa_ylilauta_175px.png' + style)
      username = username.replace(/(\[es\])/gi, img + 'static.ylilauta.org/files/ux/orig/1365450810932532.jpg' + style)

      color = data.u.toString(16).substring(0,6)

      @messages.append _.template Template, {m: message, me, color, username}

      $(".message:first").remove() if $(".message").length > 30
      @window.scrollTop $(".message:last").offset().top

    listenDisconnect: ->
      that = @
      @socket.on "disconnect", (data) ->
        that.connect()

    listenChat: ->
      that = @
      @socket.on "message", (data) ->
        that.showMessage(data)

    listenCount: ->
      that = @
      count = $(".count")
      @socket.on "clients", (clients) ->
        count.text clients

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
            "#([a-z0-9_-]+)"
            "&gt;&gt;([0-9]+)"
          ]
      re = new RegExp(re.join("|"), "gi")
      str.replace re, (match, twitler, ylilauta) ->
        return "<a href=\"/#" + twitler + "\">#" + twitler + "</a>" if twitler
        return "<a href=\"http://ylilauta.org/scripts/redirect.php?id=" + ylilauta + "\">&gt;&gt;" + ylilauta + "</a>" if ylilauta

        match
