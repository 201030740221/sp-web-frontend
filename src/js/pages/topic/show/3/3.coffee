###
@date 2016-01-07
@author parker
@modify by Fish 2016-01-11
新品大片 - 模板
###
require 'modules/plugins/jquery.fullscreen'
require 'modules/plugins/jquery.gallery'


$win = $(window)

# all_section = $('.section')
$full = $('.show-main-section')
$(document).ready ->
    $full.fullscreen
        'firstScreenOffset': $full.offset().top
        'item': 'div.section'
        # 'scale': 1580/950

    $('.banner-scroll-btn').click ->
        $full.nextScreen()

    # dg responsive
    $('#dg-container').gallery()
    $dg = $('.dg-wrapper')
    $dgItem = $dg.find('a')
    dgScale = 480/600
    sectionMinHeight = 780
    topGap = 160
    $win.on 'resize.dg', ->
        winHeight = $win.height()
        if winHeight < sectionMinHeight
            height = winHeight - topGap
            width = dgScale * height
            $dg.css('width', width)
        else
            $dg.css('width', '30%')
    .trigger 'resize.dg'
