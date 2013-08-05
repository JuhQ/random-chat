(function() {
  exports.index = function(req, res) {
    return res.render("index");
  };

  exports.test = function(req, res) {
    return res.render("iframe");
  };

}).call(this);
