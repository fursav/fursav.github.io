(function() {
  this.showCs = function() {
    $('code.language-javascript').parent().hide();
    $('code.language-coffeescript').parent().show();
  };

  this.showJs = function() {
    $("code.language-coffeescript").parent().hide();
    $("code.language-javascript").parent().show();
  };

  if ($("#cs").attr("checked")) {
    this.showCs();
  } else {
    this.showJs();
  }

  this.toggleLang = (function(_this) {
    return function(e) {
      var target;
      target = e.target;
      if (target.id === "js") {
        _this.showJs();
      } else if (target.id === "cs") {
        _this.showCs();
      }
    };
  })(this);

}).call(this);
