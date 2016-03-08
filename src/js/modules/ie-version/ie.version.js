(function (window) {
    window.ie = {};
    ie.is = function(ver){
        var b = document.createElement('b')
        b.innerHTML = '<!--[if IE ' + ver + ']><i></i><![endif]-->'
        return b.getElementsByTagName('i').length === 1
    };

    var list = [6, 7, 8, 9]
    var v, l = list.length;

    for (v = 0; v < l; v++) {
        if (ie.is(list[v])) {
            ie.version = list[v]
        }
    }

    ie.version = ie.version || 10;

    if (ie.version < 8) {
        
    }
})(window);

