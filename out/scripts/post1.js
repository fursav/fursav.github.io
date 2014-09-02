(function() {
  this.showCs = function() {
    $('code.language-javascript').parent().hide();
    $('code.language-coffeescript').parent().show();
  };

  this.showJs = function() {
    $("code.language-coffeescript").parent().hide();
    $("code.language-javascript").parent().show();
  };

  this.showCs();

}).call(this);
