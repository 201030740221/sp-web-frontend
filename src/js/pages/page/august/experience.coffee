Activity = require 'modules/activity/activity'

$(document).on 'click', 'a.see-flow', ->
    $this = $(this)
    height = $this.height()
    pos_top = $this.offset().top

    pos_flow = height + pos_top

    $('body, html').animate {
        'scrollTop': pos_flow
    }, 300

date = +new Date("2015-08-13 18:56:30")
start = new Date(date+ 5000)
end = new Date(date+ 40000)
stageStart1 = new Date(date+ 10000)
stageEnd1 = new Date(date+ 20000)
stageStart2 = new Date(date+ 25000)
stageEnd2 = new Date(date+ 35000)


promo = new Activity start, end

promo.ready ()->
    console.log 'promo ready...1', arguments

promo.ready ()->
    console.log 'promo ready...2', arguments

promo.start ()->
    console.log 'promo start...1', start, new Date, arguments

promo.start ()->
    console.log 'promo start...2', arguments

promo.end ()->
    console.log 'promo end...1', end, new Date, arguments

promo.end ()->
    console.log 'promo end...2', end, new Date, arguments


promo.stage stageStart1, stageEnd1, ()->
    console.log 'promo stage...1', stageStart1, stageEnd1, new Date, arguments

promo.stage stageStart2, stageEnd2, ()->
    console.log 'promo stage...2', stageStart2, stageEnd2, new Date, arguments

promo.through ->
    console.log 'promo througe', new Date, arguments

promo.fire('happy')    
