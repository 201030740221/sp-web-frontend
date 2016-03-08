/**
 * @tofishes
 * 获取七牛缩略图地址
 * http://developer.qiniu.com/docs/v6/api/reference/fop/image/imageview2.html
 */
var getThumb = function (img_url, width, height, quality) {
    quality = quality || 80;

    if (!width && !height) {
        return img_url;
    }

    var query = '?imageView2/2';

    if (width) {
        query += '/w/'+ width;
    }

    if (height) {
        query += '/h/'+ height;
    }

    query += '/q/' + quality;

    return img_url + query;
};
var getSmallThumb = function (img_url) {
    return getThumb(img_url, 80, 80);
}
module.exports = {
    getThumb: getThumb,
    // 获取约定的小缩略图
    getSmallThumb: getSmallThumb
};
