(function() {
  define(["jquery", "underscore", "backbone", "text!templates/youtube-player.html", "text!templates/youtube-playlist.html"], function($, _, Backbone, PlayerTemplate, PlaylistTemplate) {
    return Backbone.View.extend({
      el: ".youtube",
      events: {
        "click .show": "show",
        "submit form": "submit"
      },
      submit: function(event) {
        return event.preventDefault();
      },
      show: function(event) {
        event.preventDefault();
        $(".show").remove();
        $(".youtube-container").show();
        this.loadYoutubeApi();
        this.video();
        return this.playlist();
      },
      playVideo: function() {
        return new YT.Player("player", {
          videoId: "TfE0sq7_rrI",
          events: {
            onReady: this.onPlayerReady,
            onStateChange: this.onPlayerStateChange
          }
        });
      },
      onPlayerReady: function(event) {
        return event.target.playVideo();
      },
      onPlayerStateChange: function(event) {
        if (event.data === 0) {
          return that.nextVideo();
        }
      },
      video: function() {
        return this.$(".player").html(_.template(PlayerTemplate, {
          video: "TfE0sq7_rrI"
        }));
      },
      playlist: function() {
        var collection;
        collection = new Backbone.Collection([
          {
            video: "TfE0sq7_rrI",
            name: "Driving in russia",
            description: "Spurdo sparde michael jackson russia"
          }, {
            video: "TfE0sq7_rrI",
            name: "Driving in russia",
            description: "Spurdo sparde michael jackson russia"
          }, {
            video: "TfE0sq7_rrI",
            name: "Driving in russia",
            description: "Spurdo sparde michael jackson russia"
          }, {
            video: "TfE0sq7_rrI",
            name: "Driving in russia",
            description: "Spurdo sparde michael jackson russia"
          }
        ]);
        return this.$(".playlist").html(_.template(PlaylistTemplate, {
          collection: collection
        }));
      },
      loadYoutubeApi: function() {
        var firstScriptTag, tag, that;
        that = this;
        tag = document.createElement("script");
        tag.src = "https://www.youtube.com/iframe_api";
        firstScriptTag = document.getElementsByTagName("script")[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
        window.onYouTubeIframeAPIReady = function() {
          return that.playVideo();
        };
      }
    });
  });

}).call(this);
