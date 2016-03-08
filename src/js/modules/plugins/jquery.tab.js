/**
 * 简单选项卡切换
 * @param  {[type]} options [description]
 * @return {[type]}         [description]
 */
$.fn.tab = function (options) {
    options = $.extend({
        'title': '.tab-title', // 标题
        'content': '.tab-content', // 标题对应的内容
        'active': 'active', // 当前标题高亮class
        'onswitch': function(){}
    }, options);

    return this.each(function () {
        var $tab = $(this);
        $tab.on('click', options.title, function() {
            var $title = $(this);

            if ($title.hasClass(options.active)) return;

            var $titles = $tab.find(options.title)
            ,   $contents = $tab.find(options.content)
            ,   index = $titles.index($title);

            $titles.removeClass(options.active);
            $title.addClass(options.active);
            $contents.hide().eq(index).show();

            options.onswitch($tab, $contents, index)
        });
    });
};