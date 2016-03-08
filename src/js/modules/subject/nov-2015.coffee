# 11月活动顶部条
activity = require('./nov-2015-tpl.hbs')
module.exports = ->
    $ 'body > .page'
    .prepend activity()
