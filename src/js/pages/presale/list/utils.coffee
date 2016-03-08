###
# utils.
# @author remiel.
###
getProperty = (name)->
    prefixes = ['Webkit', 'Moz', 'O', 'ms', '']
    testStyle = document.createElement('div').style

    for v, i in prefixes
        return v + name if testStyle[v + name] isnt undefined

    # Not Supported
    return undefined

support =
    'touch': 'ontouchend' in document || window.DocumentTouch && document instanceof DocumentTouch
    'transform': !!(getProperty 'Transform')
    'transform3d': !!(window.WebKitCSSMatrix and 'm11' in new WebKitCSSMatrix())

module.exports =
    support: support
    getProperty: getProperty
