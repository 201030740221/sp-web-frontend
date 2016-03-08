commentForm = require 'modules/comment-form/comment-form'

page = ->

page.init = ->
    comment = new commentForm()
    comment.renderAllForm()


page.init()