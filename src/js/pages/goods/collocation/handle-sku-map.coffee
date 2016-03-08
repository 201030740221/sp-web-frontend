module.exports =
    #获得对象的key
    SKUResult: {},
    currentSku: [],
    getObjKeys: (obj) ->
        if (obj != Object(obj))
            throw new TypeError('Invalid object')
        keys = []
        for key of obj
            if Object::hasOwnProperty.call(obj, key)
                keys[keys.length] = key
        keys

    #把组合的key放入结果集SKUResult
    addToSKUResult: (combArrItem, sku) ->
        key = combArrItem.join(';')
        if @SKUResult[key]
            #SKU信息key属性·
            @SKUResult[key].skuSn = sku['skuSn']
            #SKUResult[key].count += sku.count
            @SKUResult[key].prices.push sku.price
        else
            @SKUResult[key] =
                skuSn: sku['skuSn']
                status: sku["status"]
                #count: sku.count
                prices: [sku.price]
                url: sku['url']
        return
    # 处理后台数据
    transformSkuData: (skuObj)->
        result = {}
        return false if !skuObj
        for sku in skuObj
            attr_item = []
            attributeKeyGroup = sku["attribute_key"].split(",")
            for attributeKeyGroup_item in attributeKeyGroup
                _attr_item = attributeKeyGroup_item.split("-")
                attr_item.push _attr_item[1]
            getKey = ()->
    # console.log(attr_item)
    # attr_item.join(";")
                attr_item.sort (a, b)->
                    return parseInt(a) - parseInt(b)
                return attr_item.join(";")
            result[getKey()] =
                price: sku.price
                skuSn: sku["sku_sn"]
                status: sku["sku_status"]
                goods: sku["goods_id"]
                url: sku['url']
        result
    ###
    # 获得从m中取n的所有组合
    ###
    getFlagArrs: (m, n) ->
        if !n or n < 1
            return []
        resultArrs = []
        flagArr = []
        isEnd = false
        i = 0
        while i < m
            flagArr[i] = if i < n then 1 else 0
            i++
        resultArrs.push flagArr.concat()
        while !isEnd
            leftCnt = 0
            k = 0
            while k < m - 1
                if (flagArr[k] == 1) and (flagArr[k + 1] == 0)
                    j = 0
                    while j < k
                        flagArr[j] = if j < leftCnt then 1 else 0
                        j++
                    flagArr[k] = 0
                    flagArr[k + 1] = 1
                    aTmp = flagArr.concat()
                    resultArrs.push aTmp
                    if (aTmp.slice(-n).join('').indexOf('0') == -1)
                        isEnd = true
                    break
                (flagArr[k] == 1) and leftCnt++
                k++
        resultArrs
    ###
    # 从数组中生成指定长度的组合
    ###
    arrayCombine: (targetArr) ->
        if !targetArr or !targetArr.length
            return []
        len = targetArr.length
        resultArrs = []
        # 所有组合
        n = 1
        while n < len
            flagArrs = @getFlagArrs(len, n)
            while flagArrs.length
                flagArr = flagArrs.shift()
                combArr = []
                i = 0
                while i < len
                    flagArr[i] and combArr.push(targetArr[i])
                    i++
                resultArrs.push combArr
            n++
        resultArrs
    #初始化得到结果集
    initSKU: (data)->
        skuData = @transformSkuData data
        skuKeys = @getObjKeys(skuData)
        i = 0
        while i < skuKeys.length
            skuKey = skuKeys[i]
            #一条SKU信息key
            sku = skuData[skuKey]
            #一条SKU信息value
            skuKeyAttrs = skuKey.split(';')
            #SKU信息key属性值数组
            len = skuKeyAttrs.length
            #对每个SKU信息key属性值进行拆分组合
            combArr = @arrayCombine(skuKeyAttrs)
            j = 0
            while j < combArr.length
                @addToSKUResult combArr[j], sku if sku.status
                j++
            #结果集接放入SKUResult
            @SKUResult[skuKey] =
                #count: sku.count
                skuSn: sku['skuSn']
                prices: [sku.price]
                url: sku['url']
                status: sku['status']
            i++
