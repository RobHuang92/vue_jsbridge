import Vue from 'vue';
import App from './App';

// 路由
import router from '@/router'

// 全局初始化
import mixin from '@/common/js/mixin';

// 导入rem布局
import '@/common/config/rem';

// vuex组件
import store from '@/store';

// 导入mint-ui组件
import Mint from 'mint-ui';
import 'mint-ui/lib/style.css';
Vue.use(Mint);

// 导入动画库
import animated from 'animate.css';
Vue.use(animated);

// 图片懒加载
import VueLazyLoad from 'vue-lazyload'
Vue.use(VueLazyLoad, {
    preLoad: 1.3,
    error: require('@/assets/placeholder_error.png'),
    loading: require('@/assets/placeholder_loading.gif'),
});


// 引用fastclick
import FastClick from 'fastclick';
FastClick.attach(document.body);

// 引用与app交互组件。并挂在vue的属性上
import JsBridge from '@/common/js/JsBridge.js';
Vue.prototype.JsBridge = JsBridge;



Vue.config.productionTip = false;

new Vue({
    el: '#app',
    router,
    store,
    components: { App },
    mixins: [mixin],
    template: '<App/>'
})