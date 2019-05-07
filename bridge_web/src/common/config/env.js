/**
 * 配置编译环境和线上环境之间的切换
 * 
 * baseUrl: 域名地址
 * routerMode: 路由模式
 * imgBaseUrl: 图片所在域名地址
 * 
 */


// 接口基础请求地址
var baseUrl = '';

/** 
 * hash模式url地址后面会带有 /#/
 * history可以去除 # 不过需要后端的配合
 * 有预加载的，没办法使用路由。只能用页面的显示隐藏来做
 * 
 */
// var routerMode = 'hash';

// 预留图片拼接地址
var imgBaseUrl = '';


if (process.env.NODE_ENV == 'development') {
    // 测试环境做跨域配置
    baseUrl = '/api'
} else if (process.env.NODE_ENV == 'production') {
    baseUrl = 'https://api.weibo.com/2';
}

export {
    baseUrl,
    // routerMode,
    imgBaseUrl,
}