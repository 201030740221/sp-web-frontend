ws = {};
if (typeof console == "undefined") {    this.console = { log: function (msg) {  } };}
WEB_SOCKET_SWF_LOCATION = "swf/WebSocketMain.swf";
WEB_SOCKET_DEBUG = true;
WEB_SOCKET_SUPPRESS_CROSS_DOMAIN_SWF_ERROR = true;

flashSale = {};
flashSale.constants = {
  CODE_FLASHSALE_READY:'101',
  CODE_FLASHSALE_STARTED: '102',
  CODE_FLASHSALE_ENDED: '103',
  CODE_FLASHSALE_FROZEN: '104',
  CODE_FLASHSALE_AVAILABLE: '105',
  CODE_FLASHSALE_RESERVED: '106',
  CODE_FLASHSALE_ALREADY_PARTICIPATED: '107',
  CODE_FLASHSALE_STILL_HAVE_A_CHANCE: '108',

  CODE_FLASHSALE_LOOT_RESERVED: '201',
  CODE_FLASHSALE_LOOT_FAILED: '202',

  CODE_FLASHSALE_ACTION_UNFREEZE: '301'
};
flashSale.constantNames = {
  '101': '准备开始',
  '102': '进行中',
  '103': '已结束',
  '104': '(冻结)已抢完,还有机会',
  '105': '机会来了',
  '106': '已抢到,快付款',
  '107': '已抢过',
  '108': '已抢完,还有机会',
  '201': '抢购操作反馈-成功',
  '202': '抢购操作反馈-失败',
  '301': '特殊操作-解冻'
};

window.onload = function()
{
  ws = new WebSocket("ws://"+document.domain+":3232/");

  ws.onopen = function() {
      ws.send(JSON.stringify({"type":"connect","userKey":"1989","flashSaleId":"123"}));
  }

  ws.onmessage = function(e) {
    console.log(e.data);
    var data = JSON.parse(e.data);
    show_msg(data);
    switch(data['type']){
      case 'broadcast':
        console.log('broadcast');
        break;
      case 'loot':
        console.log('loot');
        break;
      case 'ping':
        ws.send(JSON.stringify({"type":"pong"}));
        break;
    }
  };

  ws.onclose = function() {
    console.log("服务端关闭了连接");
  };

  ws.onerror = function() {
    console.log("出现错误");
  };
}
