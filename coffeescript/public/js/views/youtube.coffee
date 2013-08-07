define [
  "jquery"
  "underscore"
  "backbone"
  "text!templates/youtube-player.html"
  "text!templates/youtube-playlist.html"
  ], (
  $
  _
  Backbone
  PlayerTemplate
  PlaylistTemplate
  ) ->
  Backbone.View.extend
    el: ".youtube"
    events:
      "click .show": "show"
      "submit form": "submit"

    submit: (event) ->
      event.preventDefault()

    show: (event) ->
      event.preventDefault()
      $(".show").remove()
      $(".youtube-container").show()

      @loadYoutubeApi()
      @video()
      @playlist()


    playVideo: ->
      new YT.Player("player",
        videoId: "TfE0sq7_rrI"
        events:
          onReady: @onPlayerReady
          onStateChange: @onPlayerStateChange
      )

    onPlayerReady: (event) ->
      event.target.playVideo()

    onPlayerStateChange: (event) ->
      that.nextVideo() if event.data is 0

    video: ->
      @$(".player").html _.template PlayerTemplate, video: "TfE0sq7_rrI"

    playlist: ->
      collection = new Backbone.Collection([
        {video: "TfE0sq7_rrI", name: "Driving in russia", description: "Spurdo sparde michael jackson russia"}
        {video: "TfE0sq7_rrI", name: "Driving in russia", description: "Spurdo sparde michael jackson russia"}
        {video: "TfE0sq7_rrI", name: "Driving in russia", description: "Spurdo sparde michael jackson russia"}
        {video: "TfE0sq7_rrI", name: "Driving in russia", description: "Spurdo sparde michael jackson russia"}
      ])

      @$(".playlist").html _.template PlaylistTemplate, {collection}

    loadYoutubeApi: ->
      that = @
      
      tag = document.createElement("script")
      tag.src = "https://www.youtube.com/iframe_api"
      firstScriptTag = document.getElementsByTagName("script")[0]
      firstScriptTag.parentNode.insertBefore tag, firstScriptTag


      window.onYouTubeIframeAPIReady = ->
        that.playVideo()




      return

