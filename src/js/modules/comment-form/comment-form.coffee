formTpl = require './comment-form-tpl.hbs'
validate = require 'validate'
uploader = require 'uploader'

require 'modules/plugins/jquery.tag'

getQiniuThumb = (img_url)->
    img_url + '?imageView2/2/w/80/h/80/q/80'

class commentForm
    constructor: (options)->
        @options = $.extend {}, @defaults, @options, options
        #        @trigger = $ @options.trigger
        #        @item = $ @options.itemSelector
        @init()

    defaults:
        trigger: '.j-create'
        itemSelector: '.comment-list__item'

    init: () ->
        _this = @

        $item = $ @options.itemSelector

        $item.on 'click', '.j-create', (e) ->
            $targetItem = $ e.delegateTarget
            return null if $targetItem.data 'formHasRender'
            formHTML = formTpl {}
            $formWrap = $(formHTML).hide()
            $targetItem.append $formWrap
            $formWrap.slideDown()
            $form = $formWrap.find 'form'
            $form.data 'goods_id', $targetItem.data 'goods-id'
            $form.data 'order_no', $targetItem.data 'order-no'
            $form.data 'order_goods_id', $targetItem.data 'order-goods-id'
            _this.initForm $form
            $targetItem.data 'formHasRender', true

    renderAllForm: () ->
        $('.j-create').trigger('click')

    initForm: ($form) ->
        #匿名
        $form.data 'anonymous', 1 # 默认匿名
        $anonymous = $form.find '.j-anonymous'
        $anonymous.checkbox {
            callback: (checked, $el) ->
                if checked
                    $form.data 'anonymous', 1  #匿名评论
                else
                    $form.data 'anonymous', 0 #不匿名
        }

        @handleRate $form
        @handleContent $form
        @getTags $form
        @handleUpload $form
        @formSubmit $form
        @initEvt()

    initEvt: () ->
        #取消
        $cancel = $ '.j-cancel'
        $formWrap = $cancel.closest '.comment-form'
        $cancel.on 'click', (e) =>
            $formWrap.closest @options.itemSelector
            .data 'formHasRender', false
            $formWrap.slideUp () ->
                $formWrap.remove()

        #删除图片
        $imgPreview = $ '.img-preview'
        $imgPreview.on 'click', '._del', (e) ->
            $(@).closest '.img-preview__wrap'
            .remove()

    handleRate: ($form) ->
        $form.data 'rate', 0 # 0: 好评, 1: 中评, 2: 差评; 默认好评
        $radioWrap = $form.find('.form-radios')
        $radioWrap.each ()->
            $radios = $(@).find '.ui-radio'
            $radios.checkbox {
                callback: (checked, $el)->
                    $radios.checkbox 'off', true
                    $el.checkbox 'on', true
                    $form.data 'rate', $el.data 'rate'
            }

    handleContent: ($form) ->
        $text = $form.find '.form-textarea'
        $tip = $form.find '.tip-1 span'
        max = 500;
        messages =
            'content': '请输入内容，至少10个字'

        $form.validate
            messages: messages

        $text.on 'keyup', (e) ->
            text = $text.val()
            len = text.length
            $tip.html max - len

            if len > max
                $text.val text.slice 0, max
                $tip.html 0

    getTags: ($form) ->
        goods_id = $form.data 'goods_id'
        tags = ''
        $tagsField = $form.find('.tags')

        webapi.comment.getTag goods_id: goods_id
        .then (res) ->
            if res and res.code is 0 and res.data.length
                res.data.map (item, index) ->
                    tags += "<span class='tags__item ui-tag' data-tag-id='#{item.id}'>#{item.name}</span>"
                $tagsField.html(tags).closest('.form-item').show()
                $tags = $tagsField.find '.tags__item'
                $tags.tag
                    isMultiple: true
                    dataValue: 'tag-id'
                    onChange: (values)->
                        $form.data 'tag_ids', values

    handleUpload: ($form) ->
        isUploading = false
        picCountMax = 6
        $preview = $form.find '.img-preview'
        $form.find('.upload-picker').uploader
            'useQiniu': true
            'upTokenParams':
                goods_id: $form.data 'goods_id'
                order_no: $form.data 'order_no'
                module: 'comment'
            'accept':
                title: 'Images'
                extensions: 'jpg,jpeg,png'
                mimeTypes: 'image/jpeg,image/png'
            'callbacks':
                'uploadProgress': ->
                    isUploading = true
                'beforeFileQueued': (file) ->
                    imgCount = $preview.children().length
                    if imgCount >= picCountMax
                        SP.notice.error '最多只能上传' + picCountMax + '张图片'
                    return !isUploading && imgCount < picCountMax

                'uploadSuccess': (file, resp) ->
                    url = resp.data.full_path
                    thumb = getQiniuThumb(url)
                    $preview.append $ "<div class='img-preview__wrap u-fl'><img data-id='#{resp.data.id}' data-origin='#{url}' src='#{thumb}'><span class='_del'>X</span></div>"

                'uploadFinished': () ->
                    isUploading = false

    formSubmit: ($form) ->
        _this = @
        $form.on 'submit', (e) ->
            e.preventDefault()
            return null unless $form.valid()

            content = $form.find('.form-textarea').val()
            imagesId = []

            $form.find('.img-preview').find('img').each () ->
                imagesId.push $(@).data 'id'

            postData =
                order_goods_id: $form.data 'order_goods_id'
                content: content
                pic_ids: imagesId
                rate: $form.data 'rate'
                tag_ids: $form.data 'tag_ids'
                is_anonymous: $form.data('anonymous')

            webapi.comment.add postData
            .then (res) ->
                if res and res.code is 0
                    SP.alert '评价成功，审核后在已评价商品列表查看！'
                    $form.closest(_this.options.itemSelector).find('.j-create').off('click').text('已评价待审核')
                    $formWrap = $form.closest('.comment-form').slideUp ()->
                        $formWrap.remove()
                else
                    SP.notice.error res.msg
            .fail () ->
                SP.notice.error res.msg

module.exports = commentForm
