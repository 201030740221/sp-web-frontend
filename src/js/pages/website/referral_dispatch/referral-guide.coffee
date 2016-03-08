$referral = $ '#goto-referral'
$referral.on 'click', (e)->
    e.preventDefault()
    
    if !SP.isLogined()
        url = $referral.attr 'href'
        SP.login ->
            location.href = url
    else
        location.href = url
    