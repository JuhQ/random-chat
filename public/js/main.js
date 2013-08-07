(function() {
  requirejs.config({
    baseUrl: "/js",
    enforceDefine: true,
    urlArgs: "bust=" + (new Date()).getTime(),
    paths: {
      jquery: "http://ajax.googleapis.com/ajax/libs/jquery/2.0.3/jquery",
      backbone: "libs/backbone",
      underscore: "libs/underscore",
      text: "libs/text",
      moment: "libs/moment",
      socketio: "../../socket.io/socket.io.js"
    }
  });

  define(["jquery", "underscore", "backbone", "router/router", "libs/fastclick"], function($, _, Backbone, Router, Fastclick) {
    var router;
    router = new Router();
    Backbone.history.start({
      replace: true
    });
    return new FastClick(document.body);
  });

}).call(this);
