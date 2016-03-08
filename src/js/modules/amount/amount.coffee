# 数组选择组件
define ()->
#    sass = require './sass_amount'
    class Amount
        constructor: (@options)->
            that = this
            $target = $(@options.target)
            $target.each (i,item)=>
                up_btn = $(item).find ".amount-box__btns-up"
                down_btn = $(item).find ".amount-box__btns-down"
                input = $(item).find "input"

                up_btn.on "click", item, that.up
                down_btn.on "click", item, that.down
                input.on 'keyup', ->
                    # 校验数据
                    oldNum = input.data 'old-value' || 1
                    newNum = input.val().replace(/[^0-9]/g,'')
                    max = input.data 'max'
                    valid = true

                    input.val(newNum)

                    if (isNaN(newNum))
                        valid = false
                    if newNum > max
                        SP.notice.error "最多只能选择" + max + "件商品"
                        valid = false
                    if newNum < 1
                        SP.notice.error "最少得有一件商品哦"
                        valid = false

                    if valid
                        that.options.callback input.val()
                    else
                        input.val(oldNum)

                .on 'keydown', ->
                    input.data 'old-value', input.val()

        up: (e)=>
            that = this
            item = e.data
            $amountInput = $(item).find ".amount-box__input input"
            maxNum = 1 * $amountInput.data "max"
            oldNum = 1 * $amountInput.val()
            if(oldNum < maxNum)
                newNum = oldNum + 1
                $amountInput.val(newNum)
                if(typeof that.options.callback != "undefined")
                    that.options.callback(newNum)
            else
                SP.notice.error "最多只能选择" + maxNum + "件商品"
            return false
        down: (e)=>
            that = this
            item = e.data
            $amountInput = $(item).find(".amount-box__input input")
            oldNum = 1 * $amountInput.val()
            if(oldNum > 1)
                newNum = oldNum - 1
                $amountInput.val(newNum)
                if(typeof that.options.callback != "undefined")
                    that.options.callback(newNum)
            else
                SP.notice.error "最少得有一件商品哦"
            return false


    return  Amount
