loginEmpty = require './tpl-cart-empty.hbs'
unLoginEmpty = require './tpl-cart-empty-unlogin.hbs'

getCartEmpty = ->
    return if SP.isLogined() then loginEmpty() else unLoginEmpty

module.exports = getCartEmpty
