###
   @description 在指定时间段内执行任务
###
getSecs = (ms)->
    Math.floor ms / 1000

class Ontime
    constructor: (start, end, delay)->
        this.start = +DATE.parse start
        this.end = +DATE.parse end
        this.time = this.record = +new Date

        this.timeid = null
        this.delay = delay or 10 * 60 * 1000
    now: (time)->
        this.time = +DATE.parse time
        return this
    run: (func)->
        _this = this
        
        record_diff = +new Date - this.record
        time = this.time + record_diff

        start = this.start
        end = this.end

        delay_half = this.delay / 2

        if getSecs(time) < getSecs(start)
            _delay = this.delay
            diff = start - time
            diff_half = diff / 2

            # 延迟时间
            if diff < this.delay + delay_half
                _delay = Math.min diff, delay_half
            if diff_half > this.delay
                _delay = diff_half

            this.timeid = setTimeout ()->
                _this.run func
            ,   _delay

            return false
        
        if getSecs(time) <= getSecs(end + 1000)
            func(time)
            clearTimeout this.timeid

            return true

        return false

Ontime.when = (start, end, delay)->
    new Ontime start, end, delay

module.exports = Ontime