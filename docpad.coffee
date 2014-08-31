# DocPad Configuration File
# http://docpad.org/docs/config

# Define the DocPad Configuration
docpadConfig = {
    templateData:
        site:
            title: "Better With Coffee"
        getPreparedTitle: -> if @document.title then "#{@document.title} | #{@site.title}" else @site.title
    collections:
        pages: ->
            @getCollection("html").findAll({isPage:true})
        posts: ->
            @getCollection('documents').findAllLive({relativeOutDirPath:'posts'}).on "add", (model) ->
                model.setMetaDefaults({layout:"post"})
    plugins:
        ghpages:
            deployRemote: 'origin'
            deployBranch: 'master'
}

# Export the DocPad Configuration
module.exports = docpadConfig