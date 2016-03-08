# 配送地
define ['DropDown', './tpl-layout.hbs',
        './tpl-item.hbs','./place-selector'], (DropDown, placeSelector_tpl, placeSelector_item)->

    # 设置用户位置cookie
    setPlaceIdStore = (provinceId,cityId,districtId)->
        SP.storage.set('region_province_id', provinceId || -1 );
        SP.storage.set('region_city_id', cityId || -1 );
        SP.storage.set('region_district_id', districtId || -1 );

    setPlaceNameStore = (provinceName,cityName,districtName)->
        SP.storage.set('region_province_name', provinceName || -1 );
        SP.storage.set('region_city_name', cityName || -1 );
        SP.storage.set('region_district_name', districtName || -1 );

    class PlaceSelector extends DropDown
        constructor: (@options)->
            self  = this
            this.target = $(@options.target)
            this.mode = @options.mode || 1
            this.callback = @options.callback || ->
            this.onchange = @options.onchange || ->
            this.initCookie = @options.initCookie || ->
            this.clickEl = this.target.find("._place_click")
            this.data = null
            this.level = 0
            # 返回数据结构
            this.result = {
                province:{
                    id: -1,
                    name:"请选择"
                },
                city:{
                    id: -1,
                    name:"请选择"
                },
                district:{
                    id: -1,
                    name:"请选择"
                }
            }

            ###SP.member.region = {
                province_id: -1,
                province_name: "省份",
                city_id:-1,
                city_name: "市",
                district_id: -1,
                district_name: "区"
            }###

            # 处理cookie
            region_cookie = {}
            if SP.member.region and SP.member.region.province_id != -1
                region_cookie = SP.member.region
            else
                region_cookie.province_id =  SP.storage.get('region_province_id');
                region_cookie.city_id = SP.storage.get('region_city_id');
                region_cookie.district_id = SP.storage.get('region_district_id' );
                region_cookie.province_name = SP.storage.get('region_province_name' );
                region_cookie.city_name = SP.storage.get('region_city_name');
                region_cookie.district_name = SP.storage.get('region_district_name' );

            if parseInt(region_cookie.province_id) !=-1
                this.initCookie region_cookie
            else
                this.initCookie false

            super
            $(@options.target).each ->
                $(this).off "click"


            @options.render = ()=>


            #初始化数据
            _initData = ->
                self.target.find("i").each ->
                    $this = $(this)
                    id = $(this).data("id")

                    if id > 0
                        $(this).closest("._place_box").show()

                    ['province', 'city', 'district'].forEach (division)->
                        if $this.hasClass "_place_#{division}"
                            if id >0
                                self.result[division].id = id
                                self.result[division].name = $this.text()
                            else
                                self.result[division].id = -1
                                self.result[division].name = "请选择"
                                $this.text "请选择"

                            return false

            _writeHtml = ->
                ['province', 'city', 'district'].forEach (division)->
                    $division = self.target.find("._place_#{division}")

                    $division.data "id", self.result[division].id
                    .text self.result[division].name

                    self.target.find("input.#{division}-value").val self.result[division].id

                if self.result.city.id == -1
                    self.target.find("._place_box").eq(2).hide()
                else
                    self.target.find("._place_box").eq(2).show()

            _findData = (id,data,res)=>
                data = data || self.data

                for item in data
                    if parseInt(id) == parseInt(item.id)
                        res["name"] = item.name
                        res["id"] = item.id
                        return res

                    if item.children.length
                        _findData(id,item.children,res)


            _hignLight = (type)=>
                res = self.result[type]
                $(".select-stock-place__bd li a").each ->
                    data = $(this).data()

                    if data.id == res.id
                        $(this).closest("li").addClass "_active"
                    else
                        $(this).closest("li").removeClass "_active"

            _showFrame = (that,callback)->
                self._getData self.level, (res)->
                    if res.length
                        self.options.$target = $("._place_box").eq(self.level).find("._place_click")
                        if !self.dropDownBox
                            self.render_layout()
                        self._render res
                        type = $(that).find("i").data("type")
                        _hignLight(type)
                        self.show()
                        self.dropDownBox.show()
                    else
                        $(that).closest("._place_box").hide()
                        self._competeSelect();
                        self.hide()

            _bindEvent = ->
                # 弹出
                self.clickEl.on "click",->
                    that = this
                    if self.level ==$(this).closest("._place_box").index() and  self.dropDownBox and  !self.dropDownBox.is(":hidden")
                        self.hide()
                    else
                        self.level = $(this).closest("._place_box").index()
                        #id = $(that).find("i").data("id")
                        _showFrame(that)

                #关闭
                $(document).on "click",".close",->
                    self.hide()

                # 选中
                $(document).on "click", ".select-stock-place__bd li a", ->
                    if $(this).hasClass "disabled"
                        return false;
                    data = $(this).data()

                    if self.level ==0
                        _findData data.id, self.data, self.result.province
                        self.result.city.id = -1
                        self.result.city.name = "请选择"
                        self.result.district.id = -1
                        self.result.district.name = "请选择"
                    else if self.level ==1
                        _findData data.id, self.data, self.result.city
                        self.result.district.id = -1
                        self.result.district.name = "请选择"
                    else
                        _findData data.id, self.data, self.result.district
                    _writeHtml()
                    # 位置
                    self.onchange(self.result)
                    if self.level<2
                        self.level++
                        # 是否有下一级
                        $("._place_box").eq(self.level).show()
                        _showFrame $("._place_box").eq(self.level).find("._place_click")[0]
                    else
                        self.hide()
                        self._competeSelect();

            _init = ->
                _initData()
                _bindEvent()

            _init()



        # 获取数据
        _getData: (level,callback)->
            self = this

            _get = (level)->
                if level ==0
                    return self.data
                if level ==1
                    for item in self.data
                        if item.id == parseInt(self.result.province.id)
                            return item.children
                if level ==2
                    for item in self.data
                        if item.id == parseInt(self.result.province.id)
                            for child in item.children
                                if child.id == parseInt(self.result.city.id)
                                    return child.children

            if(!self.data)
                SP.get SP.config.host + "/api/region/region",{

                },(res)->
                    if res && res.code ==0
                        self.data  = res.data.region
                        callback _get level
            else
                callback _get level


        # 渲染弹框
        _render: (data)->
            self = this
            self.render_layout()
            items = placeSelector_item(data)
            layout = placeSelector_tpl()
            layout = $(layout).find(".select-stock-place__bd").html(items).closest(".select-stock-place")
            layout.find(".select-stock-place__hd").hide()
            self.dropDownBox.find(".ui-drop-down-box__inner").html(layout)

        # 完成选择
        _competeSelect: ()->
            if @options.callback?
                @options.callback(this.result)
            setPlaceIdStore this.result.province.id, this.result.city.id, this.result.district.id
            setPlaceNameStore this.result.province.name, this.result.city.name, this.result.district.name
            SP.log "place select success!"


    return  PlaceSelector
