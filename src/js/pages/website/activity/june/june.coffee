define ['Swipe','Menu', 'Tab'], ( Swipe , Menu, Tab)->
# 轮播图
  $("#j-activity-banner").find(".swipe-item").each ->
    $(".swipe-points").append("<span></span>")

  points = $(".swipe-points").find("span")
  points.eq(0).addClass("_active")
  index_num = 0
  bannerSwipe = new Swipe document.getElementById('j-activity-banner'),
    startSlide: 0
    speed: 400
    disableScroll: false
    stopPropagation: false
    callback: (index, elem) ->
      points.eq(index).addClass("_active").siblings("span").removeClass("_active")
      if(index==0)
          $('.prev-look').addClass('disabled')
      else
          $('.prev-look').removeClass('disabled')
      if(index==4-1)
          $('.next-look').addClass('disabled')
      else
          $('.next-look').removeClass('disabled')
      index_num = index

      return false

  $('.banner-click').on 'click',()->
      $('html,body').animate({scrollTop:$('.gift-section').offset().top-30}, 800)

  #处理过程图
  processHandle = (index_num)->
    for item, index in process
      if index==index_num
        $(process).eq(index).find('.title-icon').addClass('on_title')
        $(process).eq(index).find('.process-icon').addClass('active_icon')
      else
        $(process).eq(index).find('.title-icon').removeClass('on_title')
        $(process).eq(index).find('.process-icon').removeClass('active_icon')

  process = $('.advert-process li')

  $('.prev-look').on 'click',()->
      bannerSwipe.prev()
      processHandle(index_num)

  $('.next-look').on 'click',()->
      bannerSwipe.next()
      processHandle(index_num)

  $processes = $('.process-icon').on 'click',()->
      index_num = $(this).parent().index()
      
      bannerSwipe.slide(index_num)
      processHandle(index_num)
  $('.title-icon').on 'click',()->
      index_num = $(this).parent().index()
      
      bannerSwipe.slide(index_num)
      processHandle(index_num)

  # 根据日期自动适配
  today = new Date()
  date = today.getDate()
  month = today.getMonth() + 1
  index = 0
  if date <= 20
    index = 1
  if date == 21
    index = 2
  if date > 21
    index = 3
  if month > 6
    index = 3

  $processes.eq(index).trigger('click')


  $('.draw-btn').on 'click',() ->
      if(!$('.draw-btn').hasClass('disabled'))
          SP.post SP.config.host + "/api/lottery/join", {}, (res)->
              if(res)
                  if(res.code==0)
                      $('.draw-btn').text('已参与抽奖  等待开奖')
                      $('.draw-btn').addClass('disabled')
                      $('.draw-btn').css("cursor",'default')
                  if(res.code==40001)
                      SP.login()
              else
                return false
      else
          return false

  current_num = 1
  award_list_num = $('.award-list').length
  for item,index in $('.award-list')
      if $(item).hasClass('shown')
         current_num = index
 
  $('.prev-nav').on 'click',()->
      if(!$(this).hasClass('disabled'))
          current_num--
          if(current_num == 0)
              $(this).addClass('disabled')
          $('.award-list').eq(current_num).show().siblings('.award-list').hide()
          $('.next-nav').removeClass('disabled')
      else
          return false
  $('.next-nav').on 'click',()->
      if(!$(this).hasClass('disabled'))
          current_num++
          if(current_num == award_list_num-1)
              $(this).addClass('disabled')
          $('.award-list').eq(current_num).show().siblings('.award-list').hide()
          $('.prev-nav').removeClass('disabled')
      else
          return false
### prev_page = 0
    next_page = 0

   drawNameList = (page)->
     data=
       "page": page
     SP.get SP.config.host + "/api/lottery/winner", data, (res)->
         if(res && res.code==0)
             list = res.data
             next_page = list.next
             prev_page = list.prev
             if(next_page==0)
                 $('.next-nav').css("color",'#D5D5D5')
             else
                 $('.next-nav').css("color",'black')
             if(prev_page==0)
                 $('.prev-nav').css("color",'#D5D5D5')
             else
                 $('.prev-nav').css("color",'black')

             $('.now-date-award').show()
             $('.now-date-award').text(list.name+"期")
             if(list.data.length)
                  $('.next-nav').show()
                  $('.prev-nav').show()
                  html = ''
                  for item, index in list.data
                     dir = 'left'

                     if index % 2
                       dir = 'right'
                     if item.mobile==null || item.mobile==""
                       item.mobile = item.email
                     html+='<div class="'+dir+'-item">'+item.name+'&nbsp;&nbsp;&nbsp;( '+item.mobile+' )</div>'


                  $('.name-section').html(html)
             else
                  $('.now-date-award').hide()
                  $('.next-nav').hide()
                  $('.prev-nav').hide()###

###  page = 1
  drawNameList(page)

  $('.next-nav').on 'click',()->
      if(next_page)
         drawNameList(next_page)
      else
         return false

  $('.prev-nav').on 'click',()->
      if(prev_page)
         drawNameList(prev_page)
      else
        return false###
