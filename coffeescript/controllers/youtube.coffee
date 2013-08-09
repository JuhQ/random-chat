googleApiKey = "AIzaSyDftKyCTCHfNw02mbE20RtLP28IX6ME_-g"

module.exports = (id, callback) ->
  googleapis = require('googleapis')
  googleapis.discover("youtube", "v3").execute (err, client) ->
    search = client.youtube.videos.list(part: "snippet", id: id).withApiKey(googleApiKey)
    search.execute (err, response) ->

      data = {}

      data.id = id
      data.title = response.items[0].snippet.title
      data.description = response.items[0].snippet.description.substring(0, 100)

      console.log "description", description
      console.log "title", title
      console.log "id", id

      callback data