@showCs = ->
    $('code.language-javascript').parent().hide()
    $('code.language-coffeescript').parent().show()
    return
@showJs = ->
    $("code.language-coffeescript").parent().hide()
    $("code.language-javascript").parent().show()
    return
    
@showCs()