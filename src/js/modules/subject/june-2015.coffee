# 6月促销活动slid
# activity = require('./tpl-subject')
module.exports = ->
  SP.storage.remove('check_slide')
  # $('.page').append(activity());
  # $('.page').addClass('activity-page')
  # slideToUp = (content) ->
  #   $('.close-advert').hide()
  #   $(".activity-mask").fadeOut();
  #   $('.center-section').slideUp('slow')
  #   $(content).removeClass('on-slide-down')
  #   $('.title-icon').height(60);
  #   SP.storage.set('check_slide',true)

  # slideToDown = (content) ->
  #   $('.title-icon').height(0);
  #   $('.close-advert').show()
  #   $(content).addClass('on-slide-down')
  #   $(".activity-mask").fadeIn()
  #   $('.center-section').slideDown('slow')
  # slideHandle = (content) ->
  #   if($(content).hasClass('on-slide-down'))
  #     slideToUp(content)
  #   else
  #     slideToDown(content)

  # node = $('.slide-up-icon')
  # $('.slide-up-icon').on "click",->
  #   slideHandle($(node))
  # $('.activity-mask').on "click",->
  #   slideHandle($(node))

  # check_slide = SP.storage.get('check_slide')
  # if(!check_slide)
  #   slideToDown($(node))
  #   setTimeout () ->
  #     slideToUp($(node))
  #   ,7000