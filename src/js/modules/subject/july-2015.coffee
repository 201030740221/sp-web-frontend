#7月活动顶部条
activity = require('./july-2015-tpl.hbs')
module.exports = ->
    $ 'body > .page'
    .prepend activity()
