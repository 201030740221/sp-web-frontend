# 暂时用轮询处理支付状态响应
wait_time = 8 * 1000
wait_time_end = 2 * 60 * 1000 # 2分钟等待
polling_time = 2 * 1000
polling_time_id = null

order_no = $('#weixin-pay-content').data 'order-no'

url_detail = '/payment?order_no=' + order_no

polling = ->
    webapi.checkout.getOrderStatus {order_no: order_no}
    .then (res)->
        if res.code == 0 and res.data.status_id is 2
            location.href = url_detail
            clearTimeout(polling_time_id)

# 延迟执行轮询
setTimeout ->
    polling_time_id = setInterval ->
        polling()
    , polling_time
, wait_time

# 2分钟后终止页面
setTimeout ->
    clearTimeout polling_time_id
    location.href = url_detail
, wait_time_end

