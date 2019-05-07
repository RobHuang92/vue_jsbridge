import {
    SET_LOADER,
    SET_PAGETYPE
} from './mutation-types';

export default {
    [SET_LOADER](state, params) {
        state.preloader = params;
    },
    [SET_PAGETYPE](state, params) {
        state.currentPage = params;
    }
}