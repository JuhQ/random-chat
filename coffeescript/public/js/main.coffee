requirejs.config
  baseUrl: "/js"
  enforceDefine: true
  urlArgs: "bust=" + (new Date()).getTime()
  paths:
    jquery: "http://ajax.googleapis.com/ajax/libs/jquery/2.0.3/jquery"
    backbone: "libs/backbone"
    underscore: "libs/underscore"
    text: "libs/text"
    moment: "libs/moment"
    socketio: "../../socket.io/socket.io.js"
    #sockjs: "http://cdn.sockjs.org/sockjs-0.3.min"
    sockjs: "http://cdn.sockjs.org/sockjs-0.3"

define [
  "jquery"
  "underscore"
  "backbone"
  "router/router"
  "libs/fastclick"
  ], (
  $
  _
  Backbone
    Router
    Fastclick
  ) ->
  router = new Router()
  Backbone.history.start
    replace: true

  new FastClick(document.body)
