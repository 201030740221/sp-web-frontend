# 下拉选择框 SelectBox
define ['./tpl-address-list.hbs','NewAddress'], (addressListTpl, NewAddress)->
    name = 'addressList'

    hasEditing = false

    #API
    host = SP.config.host
    #host = 'http://admin.sipin.benny:8000'

    Api =
        getAddressList: 'member/address'
        deleteAddress: 'member/address/delete'
        setDefaultAddress: 'member/address/default'

    Action =
        baseUrl: host + '/api/'
        path: Api
        fn: (res)->
            #console.log res

        getAddressList: ()->
            param = ''
            SP.get @baseUrl + @path.getAddressList + param, {}, @fn, @fn

        deleteAddress: (data)->
            SP.post @baseUrl + @path.deleteAddress, data, @fn, @fn

        setDefaultAddress: (data)->
            SP.post @baseUrl + @path.setDefaultAddress, data, @fn, @fn

    class AddressList
        constructor: (options)->
            if !options.el
                #console.log 'el is null'
                return false
            @options = $.extend {}, @defaults, @options, options
            @_init() if !@_addressList


        defaults:
            el: null
            name: name
            checkboxClick: true, #
            callback: (address_id, region_id)->
                #console.log 'defaults.callback ' + 'address_id: ' + address_id +' region_id: ' + region_id,


        _init: ()->
            @$container = $ @options.el
            @_getAddressList()
            .done (res)=>
                if res.code is 0 then @_renderAddressList res.data
            @_addressList = @
            @

        #获取列表
        _getAddressList: ()->
            Action.getAddressList()
        _renderAddressList: (data)->
            _this = @
            @data = data
            console.log data
            tpl = addressListTpl data
            @$container.append tpl
            @_initElements()
            @_bindEvt()
            $.each data, (i, item)->
                if item.is_default == 1
                    region_id = if item.district_id then item.district_id else item.city_id
                    _this._onCallback item.id, region_id
            if data.length == 0
                @_onCreateAddress true


        _initElements: ()->
            @$el = @$container.find '.order-info-address__box'
            @$items = @$el.find '.order-info-address__item'
            @$checkboxs = @$items.find '.order-info-address__checkbox'
            @$delBtn = @$items.find '.j-address-del'
            @$updateBtn = @$items.find '.j-address-update'
            @$defaultBtn = @$items.find '.j-address-set-default'


            @createAddressBtn = @$el.find '.j-address-create'
            @createAddressBtnBox = @createAddressBtn.parent()
            @

        _bindEvt: ()->
            _this = @
            @$checkboxs.on 'click', (e)->
                if _this.options.checkboxClick
                    _this._onSetActive @
                    ###$el = $ @
                    $parent = $el.closest '.order-info-address__item'
                    _this.$checkboxs.removeClass '_active'

                    $el.addClass '_active'
                    _this._onCallback $parent.data 'id'###

            #del
            @$delBtn.on 'click', (e)->
                $el = $ @
                $parent = $el.closest '.order-info-address__item'
                id = $parent.data 'id'
                is_default = $parent.data 'is-default'
                if is_default
                    SP.notice.error '不能删除默认地址'
                    return

                SP.confirm
                    content: '确认要删除该地址吗？'
                    confirm: ->
                        Action.deleteAddress id: id
                        .done (res)->
                            $parent.remove()


            #update
            @$updateBtn.on 'click', (e)->
                # 之前的地址编辑完全没有考虑多个地址同时编辑的情况，
                # 导致数据之间是互相共用
                # 目前先锁定只能每次编辑一个
                # 等后期重构
                if hasEditing
                    SP.notice.error '您还有地址未保存'
                    return

                hasEditing = true

                $el = $ @
                $parent = $el.closest '.order-info-address__item'
                $origin = $parent.children().hide()
                id = $parent.data 'id'
                $.each _this.data, (i,item)->
                    if item.id is id
                        console.log item
                        $parent.newAddress
                            type: 'update'
                            data: item
                            callback: (data)->
                                SP.notice.success '地址保存成功'
                                _this.$items.remove()
                                _this.$el.remove()
                                _this._renderAddressList data
                                hasEditing = false
                            cancelCallback: ()=>
                                $origin.show()
                                hasEditing = false

            #set default
            @$defaultBtn.on 'click', (e)->
                $el = $ @
                $parent = $el.closest '.order-info-address__item'
                id = $parent.data 'id'
                postData =
                    id: id
                Action.setDefaultAddress postData
                .done (res)->
                    #_this._onSetActive $el
                    if res.code == 0
                        _this.$el.remove()
                        _this._renderAddressList res.data


            #增加新地址btn
            @createAddressBtn.on 'click', (e)=>
                if hasEditing
                    SP.notice.error '您还有地址未保存'
                    return
                hasEditing = true
                @_onCreateAddress()

            @

        _onCreateAddress: (first)->
            _this = @
            @createAddressBtnBox.hide()
            @$container.newAddress
                callback: (data)->
                    SP.notice.success '新地址保存成功'
                    _this.$items.remove()
                    _this._renderAddressList data
                    hasEditing = false
                cancelCallback: ()=>
                    @createAddressBtnBox.show()
                    hasEditing = false
            if first
                @$container.find '.user-info__hd'
                .hide()
                @$container.find '.j-address-cancel'
                .hide()


        _onSetActive: (el)->
            _this = @
            $el = $ el
            $parent = $el.closest '.order-info-address__item'
            _this.$checkboxs.removeClass '_active'

            $el.addClass '_active'
            _this._onCallback $parent.data('id'),$parent.data('region-id')

        _offEvt: ()->

            @

        _onCallback: (address_id, region_id)->
            @options.callback.call(@$container, address_id, region_id) if typeof @options.callback is 'function'

        _destroy: ()->
            @$el.empty().remove()
            if @options.el._addressList
                delete @options.el._addressList


    #export to JQ
    $.fn.addressList = (options, options2)->
        ret = @
        @each ()->
            if typeof options is 'string' && @_addressList
                switch options
                    when 'off' then @_addressList._offEvt()
            else
                opts = $.extend {},options,{el: @}
                addressList = @_addressList
                if !addressList
                    addressList = new AddressList(opts)
                else
                    #@_addressList.reset(opts)
                @_addressList = addressList
        return ret



    Fn = (options)->
        if options.el
            $el = $ options.el
            return $el.each ()->
                opts = $.extend {},options,{el: @}
                addressList = @_addressList
                if !addressList
                    addressList = new AddressList(opts)
#                else
#                    @_addressList.reset(opts)
                @_addressList = addressList
        else
            SP.log 'el is null'
            return false

    Fn
