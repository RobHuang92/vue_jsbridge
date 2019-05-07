/**
 * JS与native交互桥梁
 * */

export default {

    //初始化bridge信息
    init: (callback) => {
        if (window.WebViewJavascriptBridge) {
            return callback(WebViewJavascriptBridge);
        } else {
            document.addEventListener(
                'WebViewJavascriptBridgeReady',
                function() {
                    callback(WebViewJavascriptBridge)
                },
                false
            );
        }
        if (window.WVJBCallbacks) {
            return window.WVJBCallbacks.push(callback);
        }
        window.WVJBCallbacks = [callback];
        var WVJBIframe = document.createElement('iframe');
        WVJBIframe.style.display = 'none';
        WVJBIframe.src = 'https://__bridge_loaded__';
        document.documentElement.appendChild(WVJBIframe);
        setTimeout(() => {
            document.documentElement.removeChild(WVJBIframe)
        }, 0)
    },
    registerHandler: (name, callback) => {
        this.init((bridge) => {
            bridge.registerHandler(name, (responseData, responseCallback) => {
                //如果存在callback函数，则需要返回出去
                if (callback && typeof(callback) == 'function') {
                    //判断是否是字符串,需要转为对象
                    if (responseData && typeof(responseData) == "string") {
                        responseData = JSON.parse(responseData);
                    }
                    callback(responseData, responseCallback);
                }
            });
        })
    },
    callHandler: function(data, callback) {
        console.log("callHandler/" + data.fun + "/" + JSON.stringify(data.data))
        this.init(function(bridge) {
            //校验传入data.data 是对象还是字符串
            if (data.data && typeof(data.data) == 'object') {
                data.data = JSON.stringify(data.data);
            }
            bridge.callHandler(data.fun, data.data, function(responseData) {
                //如果data存在callback函数，则需要返回出去
                if (callback && typeof(callback) == 'function') {
                    //判断是否是字符串,需要转为对象
                    if (responseData && typeof(responseData) == "string") {
                        responseData = JSON.parse(responseData);
                    }
                    callback(responseData);
                }
            });
        });
    },
    // 向原生发送消息 
    sendNavtive: function(obj, callback) {
        this.callHandler({
            fun: obj.fun,
            data: obj.data
        }.callback);
    }
}