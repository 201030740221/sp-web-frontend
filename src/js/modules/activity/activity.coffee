###
    @tofishes
    @description 推广活动，促销活动等封装对象 (Promo)
###
require 'modules/sp/date'
Ontime = require './ontime'
###
Activity 提供生命周期方法及come单独执行方法
###
class Activity
    constructor: (startDate, endDate, now)->
        this.startDate = DATE.parse startDate
        this.endDate = DATE.parse endDate
        this.now = now or new Date

        this.actions = []
        this.checkDelay = this.endDate - this.startDate
        this.state = null

        this.data = {} # 活动期间共享的数据
    # 添加action
    add: (name, action, startDate, endDate)->
        action.startDate = startDate
        action.endDate = endDate
        action.actionName = name

        this.actions.push action
        return this

    # 整个活动都执行的动作    
    through: (action)->
        this.add 'through', action, this.now, +this.now + 100000
    # 活动前执行，活动开始后不再执行
    ready: (action)->
        this.add 'ready', action, this.now, this.startDate
    # 活动开始后执行
    start: (action)->
        this.add 'start', action, this.startDate, this.endDate
    # 活动结束后执行
    end: (action)->
        this.add 'end', action, this.endDate, +this.now + 100000
    # 活动期间执行，指定一段起止时间
    stage: (startDate, endDate, action)->
        this.add 'stage', action, startDate, endDate
            
    # 执行活动, 可传递参数给action
    fire: (args)->
        args = arguments
        now = this.now
        for i, action of this.actions
            ((action, args)->
                Ontime.when action.startDate, action.endDate
                    .now now
                    .run ()->
                        action.apply null, args
            )(action, args)

module.exports = Activity