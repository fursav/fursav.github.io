@showCs = ->
    $('code.language-javascript').parent().hide()
    $('code.language-coffeescript').parent().show()
    return
@showJs = ->
    $("code.language-coffeescript").parent().hide()
    $("code.language-javascript").parent().show()
    return

if $("#cs").attr("checked") then @showCs() else @showJs()

@toggleLang = (e) =>
    target = e.target
    if target.id is "js"
        @showJs()
    else if target.id is "cs"
        @showCs()
    return