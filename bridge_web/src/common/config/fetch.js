import { baseUrl } from './env';
import axios from 'axios';
import { Indicator } from 'mint-ui';

/*** 
 * 接口请求
 * 
 * @param url：请求的相对url地址 /test/test
 * @param method: 请求方法默认GET请求
 * @param params: 传递参数
 * */


// 显示和关闭请求过程中的菊花
function ShowIndicator() {
    CloseIndicator();
    Indicator.open({ text: '加载中...', spinnerType: 'fading-circle' });
}

function CloseIndicator() {
    Indicator.close();
}


export default function(url, method = 'GET', params = null) {
    ShowIndicator();
    // 拼接请求地址
    const urlPath = baseUrl + url;
    // 请求参数
    const item = params ? params : '';
    if (method === 'POST') {
        return axios.post(urlPath, item).then(() => { CloseIndicator(); });
    } else if (method === 'GET') {
        return axios.get(urlPath, item).then(() => { CloseIndicator(); });
    }
}