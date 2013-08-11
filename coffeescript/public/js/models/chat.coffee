define [
  "underscore"
  "backbone"
  "sockjs"
  "text!templates/message.html"
  ], (
  _
  Backbone
  socks
  Template
  ) ->
  Backbone.Model.extend
    initialize: (options) ->
      @host = "http://#{window.location.host}"
      @messages = $(".messages")
      @window = $(window)

      @messageSent = null
      @lastMessage = null

      @connect(options.room)
      @listenChat()
      @listenCount()

    connect: (room) ->
      that = @
      @sock = new SockJS("#{@host}/send")
      @sock.onopen = ->
        that.sock.send JSON.stringify {u: "", m: "", r: room}

      return

    listenChat: ->
      that = @
      @sock.onmessage = (e) ->
        that.showMessage(JSON.parse e.data)
      return

    listenCount: ->
      sock = new SockJS("#{@host}/clients")
      count = $(".count")
      sock.onmessage = (e) ->
        count.text (JSON.parse e.data)

      return

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

      @sock.send JSON.stringify {u, m, r}

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
      message = message.replace /(\[le_rainface\])/gi, img + 'static.ylilauta.org/files/ry/thumb/1375913804152820.gif' + style
      message = message.replace /(\[rage\])/gi, img + 'static.ylilauta.org/files/os/orig/136600298030015.png' + style
      message = message.replace /(\[poni\])/gi, img + 'static.ylilauta.org/files/2x/orig/137349973989444.gif' + style
      message = message.replace /(\[mario\])/gi, img + 'kikki.alilauta.org/original/30994.gif' + style

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


      color = if isNaN data.u
        @toHex(data.u).substring(0,6)
      else
        data.u.toString(16).substring(0,6)

      @messages.append _.template Template, {m: message, me, color, username}

      $(".message:first").remove() if $(".message").length > 20
      @messages.scrollTop 1337

    toHex: (str) ->
      hex = ""
      i = 0

      while i < str.length
        hex += "" + str.charCodeAt(i).toString(16)
        i++
      hex

    linkify: (str) ->
      re = [
            "#([a-z0-9_-]+)"
            "&gt;&gt;([0-9]+)"
          ]
      re = new RegExp(re.join("|"), "gi")
      str.replace re, (match, twitler, ylilauta) ->
        return "<a href=\"/##{twitler}\">##{twitler}</a>" if twitler
        return "<a href=\"http://ylilauta.org/scripts/redirect.php?id=#{ylilauta}\">&gt;&gt;#{ylilauta}</a>" if ylilauta

        match
