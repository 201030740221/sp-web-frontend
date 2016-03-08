class Navigator
    constructor: (options) ->
        @trigger = options.trigger or ''
        @speed = options.speed or 100
        @gap = options.gap or 10
        @scrollEffect = true
        @scrollEffect = options.scrollEffect if options.scrollEffect isnt undefined
        @$item = $(@trigger).filter ->
            target = $(@).data 'target'
            return not (target is 'cs' or target is 'top')
        @initEvt()

    getOffsetMap: ->
        map = top: 0
        @$item.each ->
            target = $(@).data 'target'
            map[target] = $(target).offset().top
        map

    go: (offsetTop)->
        $htmlBody = $ 'html, body'
        $htmlBody.animate
            'scrollTop': offsetTop
            , @speed

    getContact: ->
        if typeof mechatClick != 'undefined'
            mechatClick()
            return

    initEvt: ->
        _this = @
        $win = $ window
        $doc = $ document
        $htmlBody = $ 'html, body'
        $gotop = $ '.goto-top'
        gotopTimeId = null

        $win.load ->
            $doc.on 'click', _this.trigger, (e) ->
                e.preventDefault()
                offsetMap = _this.getOffsetMap()
                target = $(@).data 'target'
                offsetTop = 0

                if target is 'cs'
                    _this.getContact()
                else
                    _this.go offsetMap[target]

        $win.on 'scroll', ->
            clearTimeout(gotopTimeId)
            scrollTop = $win.scrollTop()
            winHeight = $win.height()
            offsetMap = _this.getOffsetMap()
            offsetMapR = {}
            offsetArray = []

            delete offsetMap.top

            gotopTimeId = setTimeout ->
                if scrollTop > winHeight
                    $gotop.fadeIn(_this.speed)
                else
                    $gotop.fadeOut(_this.speed)
            , 50

            return null unless _this.scrollEffect

            for key, value of offsetMap
                offsetMapR[value] = key
                offsetArray.push value

            offsetArray.sort (a, b) -> b - a

            _this.$item.removeClass 'active'

            offsetArray.every (item) ->
                if scrollTop > item - _this.gap
                    target = offsetMapR[item]
                    _this.$item.filter ->
                        $target = $ @
                        $target.addClass 'active' if $target.data('target') is target
                    return false
                else
                    return true

        $win.trigger 'scroll'

module.exports = Navigator
