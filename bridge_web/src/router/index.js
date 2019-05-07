import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

export default new Router({
    routes: [{
            path: '*',
            component(resolve) {
                require.ensure(['../pages/404.vue'], () => {
                    resolve(require('../pages/404.vue'));
                });
            },
        },
        {
            path: '/home',
            component(resolve) {
                require.ensure(['../pages/home.vue'], () => {
                    resolve(require('../pages/home.vue'));
                });
            },
        }
    ]
})