require 'social-share.js'

$('.weixin-pic').click (e) ->
    $('.wechat-qrcode').show()
    e.stopPropagation()

$(document).click ->
  $('.wechat-qrcode').hide()