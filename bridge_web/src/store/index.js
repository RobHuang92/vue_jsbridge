import Vue from 'vue';
import Vuex from 'vuex';
import getters from './getters';
import actions from './actions';
import mutations from './mutations';

Vue.use(Vuex)

const state = {
    // 预加载组件，所有的图片都在该对象
    preloader: null,
    // 当前显示页面
    currentPage: 0
}

export default new Vuex.Store({
    state,
    getters,
    actions,
    mutations
})