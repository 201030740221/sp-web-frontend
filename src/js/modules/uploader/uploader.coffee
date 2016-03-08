# 参数说明 http:#fex.baidu.com/webuploader/doc/index.html#WebUploader_File

# dnd {Selector} [可选] [默认值：undefined] 指定Drag And Drop拖拽的容器，如果不指定，则不启动。
# paste {Selector} [可选] [默认值：undefined] 指定监听paste事件的容器，如果不指定，不启用此功能。此功能为通过粘贴来添加截屏的图片。建议设置为document.body.
# pick {Selector, Object} [可选] [默认值：undefined] 指定选择文件的按钮容器，不指定则不创建按钮。
# id {Seletor} 指定选择文件的按钮容器，不指定则不创建按钮。
# label {String} 请采用 innerHTML 代替
# innerHTML {String} 指定按钮文字。不指定时优先从指定的容器中看是否自带文字。
# multiple {Boolean} 是否开起同时选择多个文件能力。
# accept {Arroy} [可选] [默认值：null] 指定接受哪些类型的文件。 由于目前还有ext转mimeType表，所以这里需要分开指定。
# title {String} 文字描述
# extensions {String} 允许的文件后缀，不带点，多个用逗号分割。
# mimeTypes {String} 多个用逗号分割。
# 如：

# {
#     title: 'Images',
#     extensions: 'gif,jpg,jpeg,bmp,png',
#     mimeTypes: 'image/*'
# }
# thumb {Object} [可选] 配置生成缩略图的选项。
# 默认为：

# {
#     width: 110,
#     height: 110,

#     # 图片质量，只有type为`image/jpeg`的时候才有效。
#     quality: 70,

#     # 是否允许放大，如果想要生成小图的时候不失真，此选项应该设置为false.
#     allowMagnify: true,

#     # 是否允许裁剪。
#     crop: true,

#     # 是否保留头部meta信息。
#     preserveHeaders: false,

#     # 为空的话则保留原有图片格式。
#     # 否则强制转换成指定的类型。
#     type: 'image/jpeg'
# }
# compress {Object} [可选] 配置压缩的图片的选项。如果此选项为false, 则图片在上传前不进行压缩。
# 默认为：

# {
#     width: 1600,
#     height: 1600,

#     # 图片质量，只有type为`image/jpeg`的时候才有效。
#     quality: 90,

#     # 是否允许放大，如果想要生成小图的时候不失真，此选项应该设置为false.
#     allowMagnify: false,

#     # 是否允许裁剪。
#     crop: false,

#     # 是否保留头部meta信息。
#     preserveHeaders: true
# }
# prepareNextFile {Boolean} [可选] [默认值：false] 是否允许在文件传输时提前把下一个文件准备好。 对于一个文件的准备工作比较耗时，比如图片压缩，md5序列化。 如果能提前在当前文件传输期处理，可以节省总体耗时。
# chunked {Boolean} [可选] [默认值：false] 是否要分片处理大文件上传。
# chunkSize {Boolean} [可选] [默认值：5242880] 如果要分片，分多大一片？ 默认大小为5M.
# chunkRetry {Boolean} [可选] [默认值：2] 如果某个分片由于网络问题出错，允许自动重传多少次？
# threads {Boolean} [可选] [默认值：3] 上传并发数。允许同时最大上传进程数。
# formData {Object} [可选] 文件上传请求的参数表，每次发送都会发送此对象中的参数。
# fileVal {Object} [可选] [默认值：'file'] 设置文件上传域的name。
# method {Object} [可选] [默认值：'POST'] 文件上传方式，POST或者GET。
# sendAsBinary {Object} [可选] [默认值：false] 是否已二进制的流的方式发送文件，这样整个上传内容php:#input都为文件内容， 其他参数在$_GET数组中。
# fileNumLimit {int} [可选] [默认值：undefined] 验证文件总数量, 超出则不允许加入队列。
# fileSizeLimit {int} [可选] [默认值：undefined] 验证文件总大小是否超出限制, 超出则不允许加入队列。
# fileSingleSizeLimit {int} [可选] [默认值：undefined] 验证单个文件大小是否超出限制, 超出则不允许加入队列。
# duplicate {int} [可选] [默认值：undefined] 去重， 根据文件名字、文件大小和最后修改时间来生成hash Key.

S4 = ()->
    return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
# Generate a pseudo-GUID by concatenating random hexadecimal.
guid = ()->
    return S4()+S4()+S4()+S4()

generalFileName = (fileName)->
    now = new Date()
    year = now.getFullYear()
    month = now.getMonth() + 1
    day = now.getDate()
    uid = guid()
    name =  "#{year}/#{month}/#{day}/#{uid}_#{fileName}"

define ['WebUploader', './webuploader.css'], (WebUploader) ->
    $.fn.uploader = (options)->
        options = $.extend(true, {
            # 自动上传。
            auto: true,
            fileVal: 'file', # 文件域的参数名
            useQiniu: false, # 是否使用七牛直接上传
            upTokenParams: {},
            # swf文件路径
            swf: 'web-frontend-static/src/js/widgets/uploader/uploader.swf',
            # 文件接收服务端。
            server: '/attachment/upload',
            pick: {
                multiple: false
            },
            # 选择文件的按钮。可选。
            # 内部根据当前运行是创建，可能是input元素，也可能是flash.
            # pick: '#filePicker',
            # 只允许选择文件，可选。
            accept: {
                title: 'Images',
                extensions: 'gif,jpg,jpeg,bmp,png',
                mimeTypes: 'image/*'
            },
            formData: { # 其他需要传的参数
                # 'officialId': (window.weixinHelper && weixinHelper.activeOfficialId) || 0,
                # 'msgType': 'image'
            },

            callbacks: {
                'uploadStart': (file)->,
                'uploadSuccess': (file, response)->,
                'uploadError': (file)->,
                'uploadComplete': (file)->, # 完成上传，不管成功或失败都会调用
                'uploadProgress': (file, percentage)-> # 上传进度
            }
        }, options);

        if options.useQiniu
            domain = 'http://7sbwdf.com2.z0.glb.qiniucdn.com/'
            options.server = 'http://upload.qiniu.com/'
            # 获取token及所在七牛的cdn域名
            webapi.tools.getQiniuToken(options.upTokenParams).then (res)->
                token = res.data.uptoken
                domain = 'http://' + res.data.domain + '/'
                options.formData.token = token

            _uploadStart = options.callbacks.uploadStart
            options.callbacks.uploadStart = (file)->
                key = generalFileName file.name
                options.formData.key = key
                uploader = this
                uploader.option('formData', options.formData)

                _uploadStart.call this, file

            _uploadSuccess = options.callbacks.uploadSuccess
            options.callbacks.uploadSuccess = (file, resp)->
                resp.url = domain + resp.key
                _uploadSuccess.call this, file, resp

        return this.each ()->
            $this = $(this)
            callbacks = options.callbacks
            name
            uploader;

            options.pick = $this[0]#'#' + id;
            uploader = WebUploader.create(options);

            uploader.on 'uploadStart', ->
                 options.formData._token = window.csrf_token
                 this.option 'formData', options.formData

            for name, callback of callbacks
                ( (_name, callback)->
                    uploader.on  _name, ()->
                        return callback.apply(uploader, arguments);
                ) name, callback;
