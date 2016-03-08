$win = $ window
mixins =
    isTopEdgeOutFromTop: ($el) ->
        st = $win.scrollTop()
        offset = $el.offset()
        top = offset.top

        st - top

    isTopEdgeInFromBottom: ($el) ->
        st = $win.scrollTop()
        offset = $el.offset()
        top = offset.top

        st + $win.height() - top

    isBottomEdgeOutFromTop: ($el) ->
        st = $win.scrollTop()
        offset = $el.offset()
        top = offset.top
        height = $el.height()

        st - top - height

    isBottomEdgeInFromBottom: ($el) ->
        st = $win.scrollTop()
        offset = $el.offset()
        top = offset.top
        height = $el.height()

        st + $win.height() - top - height

module.exports = mixins
