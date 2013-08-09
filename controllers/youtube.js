(function() {
  var googleApiKey;

  googleApiKey = "AIzaSyDftKyCTCHfNw02mbE20RtLP28IX6ME_-g";

  module.exports = function(id, callback) {
    var googleapis;
    googleapis = require('googleapis');
    return googleapis.discover("youtube", "v3").execute(function(err, client) {
      var search;
      search = client.youtube.videos.list({
        part: "snippet",
        id: id
      }).withApiKey(googleApiKey);
      return search.execute(function(err, response) {
        var data;
        data = {};
        data.id = id;
        data.title = response.items[0].snippet.title;
        data.description = response.items[0].snippet.description.substring(0, 100);
        console.log("description", description);
        console.log("title", title);
        console.log("id", id);
        return callback(data);
      });
    });
  };

}).call(this);
