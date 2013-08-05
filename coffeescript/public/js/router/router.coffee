define [
  "views/index"
  ], (
  Index
  ) ->
  Backbone.Router.extend
    routes:
      "": "room"
      ":room": "room"

    view: null
    room: (room) ->
      if @view
        @view.leaveRoom()

      @view = new Index() unless @view
      @view.setOptions {room}

