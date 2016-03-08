var ORIGIN_EVENTS = 'open message close error'
,   websocket_state = {
    'CONNECTING':  0,   // 连接还没开启。
    'OPEN':    1,   // 连接已开启并准备好进行通信。
    'CLOSING': 2,   // 连接正在关闭的过程中。
    'CLOSED':  3   // 连接已经关闭，或者连接无法建立。
};

var reconnect_max = 15 // 最大重连次数
,   reconnect_time = 0 // 重试次数
,   delay = 3000 // 重连延迟基数，最后重连时间 = delay * multiple * reconnect_time
,   multiple = 2 // 每次重连延迟时间递增倍数
,   reconnect_id
,   isReconnecting = false;

function isOriginEvent(eventName) {
    return ORIGIN_EVENTS.indexOf(eventName) != -1;
}
function executeAction(ws, action, e) {
    var data = e.data;
    try {
        data = JSON.parse(e.data)
    } catch (e) {}

    if (action) {
        action.call(ws, data, e);
        return true;
    }

    return false;
}
/**
 * websocket封装
 * @param  {[type]} options 
 * options.swf 和调用页面同域名的flash文件地址 用于不支持websocket的浏览器使用flash模拟
 * options.debug 是否开启debug
 * options.crossdomain 是否开启跨域
 * options.url 连接的地址
 *
 * @method scoket.on(eventName, function(){})
 * @method socket.connect(function_hasConnected)
 * @method socket.send({}) 发送数据
 * @method socket.close(code, reason) 关闭连接
 * 
 * @return {[type]}         [description]
 * @example
 *   var channel = new socket({ url: 'ws://socket.sipin.com/' })
 *   channel.on('event_type', funciton(data, e){console.log(data)})
 *   // 所有的send操作需在连接后执行
 *   channel.connect(function(ws) {
 *       channel.send({...})
 *   })
 */
function socket(options) {
    // window.WEB_SOCKET_SWF_LOCATION = options.swf; // 需要放在页面顶部
    window.WEB_SOCKET_DEBUG = options.debug || true;
    window.WEB_SOCKET_SUPPRESS_CROSS_DOMAIN_SWF_ERROR = options.crossdomain || true;

    this.url = options.url;
    this.events = {}
}

socket.prototype.connect = function (connected) {
    var _this = this
    ,   events = this.events;

    if (isReconnecting) {
        return;
    }

    this.connected = connected || function(){};

    var ws = new WebSocket(_this.url);
    this.ws = ws;
    
    ws.onopen = function (e) {

        executeAction(ws, events['open'], e);
        executeAction(ws, connected, e);

        clearTimeout(reconnect_id);
        // reconnect_time = 0; // 重连成功，重置重连次数
    };

    ws.onmessage = function (e) {
        var hasType = false;

        // 有指定类型的消息监听
        if (e.data) {
            var data = JSON.parse(e.data)
            ,   eventName = data['type']
            ,   action = events[eventName];

            hasType = executeAction(ws, action, e);
        }

        // 没有监听的类型，则执行默认消息监听
        if (hasType === false) {
            executeAction(ws, events['message'], e);
        }
            
    };

    ws.onclose = function (e) {
        console.log(e, 'socket close....')
        executeAction(ws, events['close'], e);
    };

    ws.onerror = function (e) {
        var action = events['error'];
        executeAction(ws, action, e);
    };
}

// 重连方法，
// 在on('close')回调中调用此方法，并需要根据实际业务需求判断是否需要重连
socket.prototype.reconnect = function () {
    var _this = this;

    if (!this.isClosed()) {
        this.close()
    }

    if (reconnect_time > reconnect_max) {
        clearTimeout(reconnect_id);
        alert('网络连接失败，请刷新重试');
        return;
    }

    // 关闭后立即重连，并次数+1
    reconnect_time++;
    _this.connect(_this.connected);

    isReconnecting = true;

    // 如果未连接成功，这里延迟继续执行
    // 如果连接成功，在open事件中，取消这次延迟重连
    reconnect_id = setTimeout(function () {
        isReconnecting = false;
        _this.reconnect();
    }, delay * multiple * reconnect_time)

}

socket.prototype.on = function (eventName, action) {
    this.events[eventName] = action;
};

socket.prototype.send = function (data) {
    if (this.ws)
        this.ws.send(JSON.stringify(data))
    else 
        window.console && console.log('send fail, no websocket, please use send() in connected callback')
}
// https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent#Status_codes
socket.prototype.close = function (code, reason) {
    code = code || 1000;
    reason = reason || 'closed normal';
    if (this.ws)
        this.ws.close(code, reason)
    else 
        window.console && console.log('close socket fail')
}
socket.prototype.getState = function () {
    return this.ws.readyState;
}
socket.prototype.isClosed = function () {
    return this.getState() === websocket_state.CLOSED;
}


module.exports = socket;