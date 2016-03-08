# 全局模块
define ['config', './storage', './math', './member-info'], (config, Store, Math, memberInfo)->


    require './date'
    objectAssign = require 'object-assign'
    thumb = require './thumb'


    SP= {}

    objectAssign SP, thumb

    SP.init = ->

    LightModalBox = require 'LightModalBox'
    ConfirmModalBox = require 'ConfirmModalBox'
    AlertModalBox = require 'AlertModalBox'
    SP.notice = (msg, status)->
        modal = new LightModalBox
            text: msg
            status: status || 'info'
            closedCallback: ()->
                $('#' + modal.id).remove()
                modal = null
        modal.show()
    SP.notice.success = (msg)->
        SP.notice(msg, 'success')
    SP.notice.error = (msg)->
        SP.notice(msg, 'error')

    SP.alert = (msg)->
        AlertModalBox
            content: msg

    SP.confirm = (options)->
        ConfirmModalBox options

    # 服务器
    SP.config = {}
    if window.sipinConfig
        SP.config = sipinConfig

    SP.config.host = config.host

    # 生产环境标志
    SP.isProduction = SP.config.env == 'production'
    SP.isDev = !SP.isProduction


    # 事件中心，待完善
    SP.jq = $({})
    SP.events =
        member_update: 'sp-member-update'
        cart_goods_quantity_update: 'sp-cart-goods-quantity-update'

    SP.on = ->
        SP.jq.on.apply SP.jq, arguments

    SP.off = ->
        SP.jq.off.apply SP.jq, arguments

    SP.trigger = ->
        SP.jq.trigger.apply SP.jq, arguments

    # 调试信息输出
    SP.log = (info)->
        if !window.console then window.console = log: ()->
        if console and console.log
            console.log '%c'+info,'color:#d3af94;'

    # 字符串处理
    SP.trim = (val)->
        val.replace /^\s+|\s+$/gm,''

    # Date对象的一些操作
    SP.date =
        # 获取传入的Date对象的前后的n天m个月的Date对象
        ahead: (date, days, months)->
            return new Date(
                date.getFullYear()
                date.getMonth() + months
                date.getDate() + days
            )
        # 将日期字符串(如:"2015-01-01")转换为Date对象
        parse: (s)->
            if m = s.match /^(\d{4,4})-(\d{2,2})-(\d{2,2})$/
                return new Date m[1], m[2] - 1, m[3]
            else
                return null
        # 将Date对象转换为日期字符串(如:"2015-01-01")
        format: (date)->
            month = (date.getMonth() + 1).toString()
            dom = date.getDate().toString()
            if month.length is 1
                month = '0' + month
            if dom.length is 1
                dom = '0' + dom
            return date.getFullYear() + '-' + month + "-" + dom

    SP.ajaxStatus =
        SUCCESS                 : 0 # 成功
        FAIL                    : 1 # 失败
        ERROR_OPERATION_FAILED  : 10001 # 操作失败
        ERROR_MISSING_PARAM     : 20001 # 缺少参数
        ERROR_INVALID_PARAM     : 20002 # 不合法参数
        ERROR_INVALID_CAPTCHA   : 20003 # 验证码错误
        ERROR_AUTH_FAILED       : 40001 # 未登陆操作
        ERROR_PERMISSION_DENIED : 40003 # 权限错误

    # ajax事件
    SP.postSuccess = (res)->
        if res
            switch res.code
                when SP.ajaxStatus.SUCCESS
                    console.log "success"
                when SP.ajaxStatus.FAIL
                    console.log "fail"
                when SP.ajaxStatus.ERROR_OPERATION_FAILED
                    console.log "操作失败"
                when SP.ajaxStatus.ERROR_MISSING_PARAM
                    console.log "缺少参数"
                when SP.ajaxStatus.ERROR_INVALID_PARAM
                    console.log "不合法参数"
                when SP.ajaxStatus.ERROR_INVALID_CAPTCHA
                    console.log "验证码错误"
                when SP.ajaxStatus.ERROR_AUTH_FAILED
                    console.log "未登录操作"
                when SP.ajaxStatus.ERROR_PERMISSION_DENIED
                    console.log "权限错误"
        else
            console.log "网络问题"



    SP.postError = ()->

    SP.ajax = (type, url, data, success, error)->
        promise = $.ajax
            url: url
            type: type
            dataType: "json"
            data: data
            beforeSend: (xhr)->
                xhr.setRequestHeader("X-CSRF-Token", SP.member.token)
            statusCode:
                500: ()->
                    alert('服务器没有响应，请重试或者联系客服解决!')
                404: ()->
                    SP.log('访问地址不存在，请重试或者联系客服解决!')

        promise.done success || SP.postSuccess
        promise.fail error || SP.postError

        promise;

    SP.post = (url, data, success, error)->
        SP.query "POST", url, data, success, error

    SP.get = (url, data, success, error)->
        SP.query "GET", url , data, success, error

    SP.put = (url, data, success, error)->
        SP.query "PUT", url , data, success, error

    SP.query = (type, url, data, success, error)->
        SP.ajax type, url, data, success, error

    SP.getQuery = ()->
        query = {}

        try
            seg = location.search.replace(/^\?/,'').split('&')
            for item in seg
                if !item
                    continue;
                s = item.split '=';
                query[s[0]] = s[1];
        catch error
            return {}

        return query

    # @tofishes
    # 提供本地存储方法，用以替代cookie存储
    # 减小cookie大小对网站请求速度有很大提升
    # 非必要勿使用cookie存储，而是使用本地存储
    SP.storage = new Store()
    SP.session = new Store('session')

    SP.Math = Math

    SP.classSet = require 'modules/components/utils/class-set'

    memberInfo.call SP

    window.SP = SP

    return  SP
