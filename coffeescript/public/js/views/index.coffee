define [
  "jquery"
  "underscore"
  "backbone"
  "models/chat"
  "collections/boards"
  "views/youtube"
  ], (
  $
  _
  Backbone
  Model
  BoardsCollection
  YoutubeView
  ) ->
  Backbone.View.extend
    el: "body"
    events:
      "submit form#message": "sendMessage"

    mainRoom: "random"

    random: (min, max) ->
      return min + Math.round(Math.random() * (max-min))

    initialize: ->
      _.bindAll this, "resize"
      @username = String(@random(0, (new Date()).getTime())).substring(0,10)
      @username = Number @username
      @messagesElement = $(".messages")
      @youtubeElement = $(".youtube")
      @roomElement = $(".room")
      @window = $(window)

      @window.on "resize", @resize
      @resize()

      new YoutubeView()

      $("input[name='message']").bind "paste", (e) -> e.preventDefault()

    resize: ->
      height = @window.height() - 60
      @messagesElement.css("max-height", height - 40)
      @youtubeElement.css("max-height", height)
      if $(".message:last").length
        @messagesElement.scrollTop 1337

    setOptions: (options) ->
      room = options.room || @mainRoom
      @model = new Model({room}) unless @model
      #@model.setOptions {room}
      @setBoards(room)

    leaveRoom: () ->
      #@model.leaveRoom($(".room").val())
      @$(".messages").html("")

    sendMessage: (event) ->
      event.preventDefault()
      target = $(event.target)
      input = target.find("input[name='message']")
      message = input.val()
      return unless message

      usernameInput = target.find("input[name='username']")
      @changeUsername usernameInput.val() if usernameInput.val().length

      clearForm = ->
        input.val("")
        input.focus()

      command = message.match(/\/(nick|join|j) ([#-_A-Za-z0-9]+)/i)

      if command
        @commands command
        clearForm()
        return

      clearForm()
      room = @roomElement.val()
      @model.send @username, message, room

    commands: (command) ->
      if command[1] in ["join", "j"]
        Backbone.history.navigate("#" + command[2].replace("#",""))

      else if command[1] is "nick"
        @changeUsername command[2]

      return

    changeUsername: (username) ->
      @username = username.substring(0,25).trim()
      return

    # TODO: make separate view for boards
    setBoards: (room) ->
      @boards = new BoardsCollection() unless @boards

      board = @boards.find (model) ->
        model.get("boardurl") is room

      if board
        $(".room-name").text(board.get("boardname"))
      else
        $(".room-name").text(room)

      @roomElement.val(room)
      rooms = $(".rooms")
      rooms.html("")
      @boards.each (model) ->
        rooms.append('<a href="#' + model.get("boardurl") + '">' + model.get("boardname") + '</a> ')

