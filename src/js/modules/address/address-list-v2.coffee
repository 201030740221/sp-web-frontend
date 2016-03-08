# 下拉选择框 SelectBox
define ['./tpl-address-list-v2.hbs', 'NewAddress', 'ModalBox'], (addressListTpl, NewAddress, ModalBox)->
    name = 'addressList'

    hasEditing = false

    class AddressList
        constructor: (options)->
            if !options.el
                return false
            @options = $.extend {}, @defaults, @options, options
            @_init() if !@_addressList


        defaults:
            el: null
            member_id: null
            name: name
            checkboxClick: true,
            callback: (address_id, region_id)->

        _init: ()->
            @$container = $ @options.el
            @_getAddressList @options.member_id
            .then (res)=>
                if res.code is 0
                    @_renderAddressList res.data
            @_addressList = @
            @isAllShowing = false
            @

        #获取列表
        _getAddressList: (member_id)->
            webapi.address.get member_id

        _renderAddressList: (data, type=null)->
            _this = @
            @data = data
            tpl = addressListTpl data
            @$container.empty().append tpl
            @_initElements()
            @_bindEvt()
            $.each data, (i, item)->
                if item.is_default == 1
                    region_id = if item.district_id then item.district_id else item.city_id
                    _this._onCallback item.id, region_id, type

            @_handleAddressList()
            if data.length == 0
                @_onCreateAddress true


        _handleAddressList: ()->
            if @isAllShowing
                @$items.show()
                @$allAddress.text '显示更少地址'
            else if @$items.length > 3
                @$el.find '.address-list__item:lt(3)'
                .show()
                @$allAddress.show()
            else
                @$items.show()
                @$allAddress.hide()

        _initElements: ()->
            @$el = @$container.find '.address-list'
            @$items = @$el.find '.address-list__item'
            @$checkboxs = @$items.find '.address-list__checkbox'
            @$delBtn = @$items.find '.j-address-del'
            @$updateBtn = @$items.find '.j-address-update'
            @$defaultBtn = @$items.find '.j-address-set-default'
            @createAddressBtn = @$el.find '.j-address-create'
            @createAddressBtnBox = @createAddressBtn.parent()
            @$allAddress = $ '.j-all-address'

            @$items.each (index)->
                if $(@).data('is-default') is 1
                    $el = $ @
                    $el.prependTo $el.closest('.address-list')
            @

        _bindEvt: ()->
            _this = @
            @$checkboxs.on 'click', (e)->
                if _this.options.checkboxClick
                    _this._onSetActive @

            @$el.on 'click', '.j-all-address', (e)->
                if _this.isAllShowing
                    _this.$el.find '.address-list__item:gt(2)'
                    .slideUp()
                    $(e.target).text('查看所有地址')
                    _this.isAllShowing = false
                else
                    _this.$items.slideDown()
                    _this.isAllShowing = true
                    $(e.target).text('显示更少地址')

            #del
            @$delBtn.on 'click', (e)->
                e.stopPropagation()
                $el = $ @
                $parent = $el.closest '.address-list__item'
                $checkbox = $el.closest '.address-list__checkbox'
                id = $parent.data 'id'
                is_default = $parent.data 'is-default'

                if is_default
                    SP.notice.error '不能删除默认地址'
                    return
                if $checkbox.hasClass '_active'
                    SP.notice.error('你已经选择该地址！');
                    return

                SP.confirm
                    title: '删除收货地址'
                    content: '是否确定要删除该收货地址，删除后将不再显示',
                    confirm: ()->
                        webapi.address.remove id: id
                        .then (res)->
                            $parent.remove()
                            _this._handleAddressList()
                    cancel: ()->




            #update
            @$updateBtn.on 'click', (e)->
                e.stopPropagation()
                # 之前的地址编辑完全没有考虑多个地址同时编辑的情况，
                # 导致数据之间是互相共用
                # 目前先锁定只能每次编辑一个
                # 等后期重构
                if hasEditing
                    SP.notice.error '您还有地址未保存'
                    return

                hasEditing = true

                $el = $ @
                $parent = $el.closest '.address-list__item'
                $origin = $parent.children().hide()
                id = $parent.data 'id'
                $.each _this.data, (i, item)->
                    if item.id is id
                        modalBox = new ModalBox
                            template: '<div class="address-update-box"></div>',
                            width: 650,
                            top: 60,
                            mask: true,
                            maskClose: true,
                            # closeBtn: true,
                            closedCallback: ->
                                # modalBox.destroy()
                        modalBox.show()

                        $('.address-update-box').newAddress
                            type: 'update'
                            data: item
                            callback: (data)->
                                SP.notice.success '地址保存成功'
                                _this._renderAddressList data, _this._changeType.UPDATE
                                modalBox.destroy()
                                hasEditing = false

                            cancelCallback: ()=>
                                $origin.show()
                                modalBox.destroy()
                                hasEditing = false

            #set default
            @$defaultBtn.on 'click', (e)->
                $el = $ @
                $parent = $el.closest '.address-list__item'
                id = $parent.data 'id'
                webapi.address.setDefault id
                .then (res)->
                    #_this._onSetActive $el
                    if res.code == 0
                        _this._renderAddressList res.data, _this._changeType.SET_DEFAULT


            #增加新地址btn
            @createAddressBtn.on 'click', (e)=>
                if hasEditing
                    SP.notice.error '您还有地址未保存'
                    return
                hasEditing = true
                if not @isAllShowing
                    @$allAddress.trigger 'click'
                @_onCreateAddress()

            @

        _onCreateAddress: (first)->
            _this = @
            @createAddressBtnBox.hide()
            @$container.newAddress
                first: first
                callback: (data)->
                    SP.notice.success '新地址保存成功'
                    _this._renderAddressList data, _this._changeType.ADD
                    if first
                        _this.$items.show()
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
            $parent = $el.closest '.address-list__item'
            _this.$checkboxs.removeClass '_active'

            $el.addClass '_active'
            _this._onCallback $parent.data('id'), $parent.data('region-id'), _this._changeType.ON_SET

        _offEvt: ()->
            @

        _changeType: {
            'DELETE': 0
            'UPDATE': 1
            'ADD': 2
            'SET_DEFAULT': 3
            'ON_SET': 4
        }

        _onCallback: (address_id, region_id, type=null)->
            @options.callback.call(@$container, address_id, region_id, type) if typeof @options.callback is 'function'

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
                opts = $.extend {}, options, {el: @}
                addressList = @_addressList
                if !addressList
                    addressList = new AddressList(opts)
                else
                @_addressList = addressList
        return ret


    Fn = (options)->
        if options.el
            $el = $ options.el
            return $el.each ()->
                opts = $.extend {}, options, {el: @}
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
