class VerticalSlider
    constructor: (selector) ->
        @$selector = $ selector
        @$trigger = @$selector.find '.trigger'
        @$row = @$selector.find '.slider-row'
        @initStatus()
        @bindEvt()

    initStatus: ->
        target = @$trigger.find('.active').data 'target'
        $target = @$row.filter ->
            $(@).data('index') is target
        $target.show()
        @current = @$row.index $target

    bindEvt: ->
        _this = @
        @$trigger.on 'click', 'a', (e) ->
            e.preventDefault()
            if $(@).hasClass 'up'
                _this.slide null, 'up'
            else if $(@).hasClass 'down'
                _this.slide null, 'down'
            else
                target = $(@).data 'target'
                $target = _this.$row.filter ->
                    $(@).data('index') is target
                return null if $target.length is 0
                index = _this.$row.index $target
                _this.slide index, null

    slide: (index, dir) ->
        if index isnt null
            @current = index
        else if dir is 'up' and @current > 0
            @current  = @current - 1
        else if dir is 'down' and @current < @$row.length - 1
            @current = @current + 1
        else
            return null

        @$row.slideUp()
        @$row.eq(@current).slideDown()

        target = @$row.eq(@current).data 'index'
        @$trigger.find('a').removeClass 'active'
        .filter ->
            return $(@).data('target') is target
        .addClass 'active'

module.exports = VerticalSlider
