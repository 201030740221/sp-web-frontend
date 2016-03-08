liteFlux = require 'lite-flux'
store = liteFlux.store "presales-home",
    data:
        list: null
        current: null
        tab: 0
        block1ImgInit: no

    actions:
        reset: () ->
            list: null
            current: null
            tab: 0
            block1ImgInit: no
            batches: null
            current_detail: null
            skuPicker: null


        resetDetail: () ->
            @setStore
                batches: null
                current_detail: null
                skuPicker: null


        setBlock1ImgInitStatus: (status) ->
            @setStore
                block1ImgInit: status || no

        setCurrent: (item) ->
            @setStore
                current: item

        tab: (i) ->
            store = @getStore()
            list = store.list
            current = list[i]

            @getAction().resetDetail()
            @setStore
                tab: i
                current: current
            @getAction().getPresales current.id
        getList: () ->
            webapi.presales.presales().then (res) =>
                if res.code is 0
                    current = null
                    if res.data and res.data.presales and res.data.presales.length
                        current = res.data.presales[0]
                        @getAction().resetDetail()
                        @getAction().getPresales current.id
                    @setStore
                        list: res.data.presales
                        current: current
                        server_time: res.data.server_time

        onSetStore: (data) ->
            @setStore data

        skuOptional: (goods_sku) ->
            optional = []
            optional = goods_sku.map (sku, j) =>
                attribute_key: sku.attribute_key
                attribute_name: sku.attribute_name
                goods_id: sku.goods.id
                id: sku.id
                price: sku.price
                sku_sn: sku.sku_sn
            optional
        setSelectedSku: (sku) ->
            store = @getStore()
            skuPicker = store.skuPicker
            goods_sku = skuPicker.goods_sku
            if sku
                goods_sku.map (item, i) =>
                    if +item.sku_sn is +sku.skuSn
                        skuPicker.selected_sku = item
                        skuPicker.selected =
                            attribute_key: item.attribute_key
                            attribute_name: item.attribute_name
                            goods_id: item.goods.id
                            id: item.id
                            price: item.price
                            sku_sn: item.sku_sn
                        @setStore
                            skuPicker: skuPicker
        initPresales: (presale, server_time) ->

            presale = presale # res.data.presale
            goods_sku = presale.goods.goods_sku
            optional = @getAction().skuOptional goods_sku
            selected = null
            skuData = presale.goods.skuData
            skuData.map (item, i) =>
                item.value.map (val, j) =>
                    skuData[i].value[j].check = 0

            # 保存当前 SKU 属性
            attribute_state = {}
            if optional and optional.length
                selected = optional[0]
                attribute_key = selected.attribute_key
                attribute = attribute_key.split(',')
                attribute.map (item, i) =>
                    attr = item.split('-')
                    attribute_state[attr[0]] = parseInt(attr[1])

                    skuData.map (item1, j) =>
                        if +item1.id is +attr[0]
                            item1.value.map (val, k) =>
                                if +val.id is +attr[1]
                                    skuData[j].value[k].check = 1
            skuPicker =
                skuData: skuData
                optional: optional
                selected: selected
                attribute_key: attribute_state
                selected_sku: goods_sku[0]
                goods_sku: goods_sku

            batches = null
            presale.batches.map (item, i) =>
                if item.id is presale.next_valid_batch_id
                    batches = item
            @setStore
                current_detail: presale
                batches: batches
                skuPicker: skuPicker
                server_time: server_time # res.data.server_time

        getPresales: (id) ->
            store = @getStore()
            id = id || store.id
            webapi.presales.presales(id).then (res) =>
                if res.code is 0
                    @getAction().initPresales res.data.presale, res.data.server_time

        getDelivery: () ->
            store = @getStore()
            region = S('region')
            skuPicker = store.skuPicker
            if not skuPicker
                return ''

            data =
                goods_sku_id: skuPicker.selected_sku.id
                region_id: region.district

            webapi.goods.getDelivery(data).then (res) =>
                if res.code is 0
                    skuPicker['delivery'] = res.data.toFixed 2
                    @setStore
                        skuPicker: skuPicker

        checkout: () ->
            store = @getStore()
            data =
                presale_batch_id: store.batches.id
                sku_sn: store.skuPicker.selected_sku.sku_sn
            console.log 'checkout TODO'
            # A('checkout').checkoutPresales data


module.exports = store
