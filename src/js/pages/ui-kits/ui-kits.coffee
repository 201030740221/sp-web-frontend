###
# UIKits Demo.
###

# Widgets
require './eventView'
require './imgView'

# Modules
require './hoverList'
require './sliderList'

$('#j-checkbox-check-all').checkbox {
    callback: (checked, $el) ->
        console.log checked, $el
}
