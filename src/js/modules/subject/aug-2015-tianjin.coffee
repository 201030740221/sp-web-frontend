#7月活动顶部条
activity = require('./aug-2015-tianjin-tpl.hbs')
module.exports = ->
    $ 'body > .page'
    .prepend activity()