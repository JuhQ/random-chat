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
      @joinRoom options.room

    send: (u, message, r) ->
      that = @

      u = String(u).substring(0,25)
      @username = u
      m = message.substring(0,1000)
      m = m.trim()

      _gaq.push(['_trackPageview'])

      return unless m.length
      return @showSpam(m) if @messageSent
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

      message = message.replace /(\[tonninseteli\])/gi, img + 'cdn.userpics.com/upload/tonninseteli.jpg' + style
      message = message.replace /(\[hitler\])/gi, img + 'static.ylilauta.org/files/wb/orig/1366214983604638.gif' + style
      message = message.replace /(\[ylilauta\])/gi, img + 'meemi.info/images/2/2a/Norppa_ylilauta_175px.png' + style
      message = message.replace /(\[es\])/gi, img + 'static.ylilauta.org/files/ux/orig/1365450810932532.jpg' + style
      message = message.replace /(\[spurdo\])/gi, img + 'static.ylilauta.org/files/2s/orig/1367332063683775.png' + style
      message = message.replace /(\[nakkivene\])/gi, img + 'static.ylilauta.org/files/45/orig/1370161671660103.png' + style
      message = message.replace /(\[skeletor\])/gi, img + 'static.ylilauta.org/files/33/orig/1366231280662468.jpg' + style

      message = message.replace /(\[dolan\])/gi, img + 'static.ylilauta.org/files/tb/orig/1366557461577278.jpg' + style
      message = message.replace /(\[dolan2\])/gi, img + 'static.ylilauta.org/files/hh/orig/13705610491069.jpg' + style
      message = message.replace /(\[dolan3\])/gi, img + 'static.ylilauta.org/files/mc/orig/1367351888390750.png' + style
      message = message.replace /(\[gooby\])/gi, img + 'static.ylilauta.org/files/q5/thumb/1372413598106457.png' + style
      message = message.replace /(\[gooby2\])/gi, img + 'static.ylilauta.org/files/gb/orig/1366516940725793.png' + style
      message = message.replace /(\[tableflip\])/gi, img + 'static.ylilauta.org/files/be/orig/1372464326784921.jpg' + style
      message = message.replace /(\[turku\])/gi, img + 'static.ylilauta.org/files/4z/thumb/1366709495720484.jpg' + style
      
      

      # copy this for new icons
      # message = message.replace /(\[skeletor\])/gi, img + '' + style



      username = _.escape String(data.u).substring(0,25)

      username = username.replace /(\[tonninseteli\])/gi, img + 'cdn.userpics.com/upload/tonninseteli.jpg' + style
      username = username.replace /(\[hitler\])/gi, img + 'static.ylilauta.org/files/wb/orig/1366214983604638.gif' + style
      username = username.replace /(\[ylilauta\])/gi, img + 'meemi.info/images/2/2a/Norppa_ylilauta_175px.png' + style
      username = username.replace /(\[es\])/gi, img + 'static.ylilauta.org/files/ux/orig/1365450810932532.jpg' + style
      username = username.replace /(\[spurdo\])/gi, img + 'static.ylilauta.org/files/2s/orig/1367332063683775.png' + style
      username = username.replace /(\[nakkivene\])/gi, img + 'static.ylilauta.org/files/45/orig/1370161671660103.png' + style
      username = username.replace /(\[gooby\])/gi, img + 'static.ylilauta.org/files/q5/thumb/1372413598106457.png' + style


      color = data.u.toString(16).substring(0,6)

      @messages.append _.template Template, {m: message, me, color, username}

      $(".message:first").remove() if $(".message").length > 30
      #@window.scrollTop $(".message:last").offset().top
      @messages.scrollTop $(".message:last").offset().top

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
