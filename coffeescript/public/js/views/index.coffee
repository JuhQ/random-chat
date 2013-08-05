define [
  "jquery"
  "underscore"
  "backbone"
  "models/chat"
  "collections/boards"
  ], (
  $
  _
  Backbone
  Model
  BoardsCollection
  ) ->
  Backbone.View.extend
    el: "body"
    events:
      "submit form": "sendMessage"

    mainRoom: "random"

    random: (min, max) ->
      return min + Math.round(Math.random() * (max-min))

    initialize: ->
      @username = String(@random(0, (new Date()).getTime())).substring(0,10)
      @username = Number @username

      $("input[name='message']").bind "paste", (e) ->
        e.preventDefault()
      return

    setOptions: (options) ->
      room = options.room || @mainRoom
      @model = new Model() unless @model
      @model.setOptions {room}
      @setBoards(room)

    leaveRoom: () ->
      @model.leaveRoom($(".room").val())
      @$(".messages").html("")

    sendMessage: (event) ->
      event.preventDefault()
      input = $(event.target).find("input[name='message']")
      message = input.val()
      return unless message

      clearForm = ->
        input.val("")
        input.focus()

      command = message.match(/\/(nick|join|j) ([#-_A-Za-z0-9]+)/i)

      if command
        @commands command
        clearForm()
        return

      clearForm()
      room = $(".room").val()
      @model.send @username, message, room

    commands: (command) ->
      if command[1] in ["join", "j"]
        Backbone.history.navigate("#" + command[2].replace("#",""))

      else if command[1] is "nick"
        @username = command[2]

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


      rooms = $(".rooms")
      rooms.html("")
      @boards.each (model) ->
        rooms.append('<a href="#' + model.get("boardurl") + '">' + model.get("boardname") + '</a> ')

