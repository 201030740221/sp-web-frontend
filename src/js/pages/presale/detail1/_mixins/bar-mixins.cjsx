moment = require 'moment'

CouponBar = require './coupon-bar'
BookingBar = require './booking'
SmsNotice = require './sms-notice'
GoToSkuDetail = require './go-to-sku-detail'
module.exports =

    renderBar: ->
        node = ''
        store = @state[@storeName]
        server_time = store.server_time
        current = store.current

        if current is null or S('presales-detail').current is null
            return ''
        server_time = store.server_time
        current = store.current
        batches = current.batches
        # hasCurrentBatches = no
        batches.map (item, i) =>
            # 找到当前批次
            if item.id is current.next_valid_batch_id
                # hasCurrentBatches = yes
                # 开售前
                if moment(server_time).isBefore(item.begin_at)
                    console.log '开售前'
                    node =
                        <Toolbar>
                            <div className="presales-bar u-text-center">
                                <Button large bsStyle="black-yellow"><SmsNotice id={current.id} title="预售商品开售提醒" desc="下批销售我们将提前1个小时短信告知您">开售提醒我</SmsNotice></Button>
                            </div>
                        </Toolbar>
                # 开售ing
                else if moment(server_time).isBefore(item.end_at)
                    console.log '开售ing'
                    node =
                        <BookingBar />
                    # 开售ing, 缺货
                    if +current.out_of_stock is -1
                        console.log '开售ing, 缺货'
                        node =
                            <Toolbar>
                                <div className="presales-bar u-text-center">
                                    <Button large bsStyle="black-yellow" disabled>太抢手了  暂时缺货</Button>
                                </div>
                            </Toolbar>
            # 没有当前批次, 应该是最后一个批次和活动结束之间这段时间
            # if not hasCurrentBatches and moment(server_time).isBefore(current.end_at)
            if (not current.next_valid_batch_id > 0) and moment(server_time).isBefore(current.end_at)

                node =
                    <Toolbar>
                        <div className="presales-bar u-text-center">
                            <Button large bsStyle="black-yellow" disabled>太抢手了  暂时缺货</Button>
                        </div>
                    </Toolbar>

        # 预售完毕
        if moment(current.end_at).isBefore(server_time)
            console.log '预售完毕'
            node =
                <GoToSkuDetail />


        # 第一批开售前
        if moment(server_time).isBefore(batches[0].begin_at)
            console.log '第一批开售前'
            node =
                <CouponBar />

        node
