/**
 * JS与native交互桥梁
 *  function 不能用箭头函数
 * */

export default {

    //初始化bridge信息
    init: function(callback) {
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
        setTimeout(function() {
            document.documentElement.removeChild(WVJBIframe)
        }, 0)
    },
    // sendJsMessage 这个字段需要与原生app保持一致
    registerHandler: function(callback, name = 'sendJsMessage') {
        this.init(function(bridge) {
            bridge.registerHandler(name, function(responseData, responseCallback) {
                //如果存在callback函数，则需要返回出去
                if (callback && typeof(callback) == 'function') {
                    try {
                        //判断是否是字符串,需要转为对象
                        if (responseData && typeof(responseData) == "string") {
                            responseData = JSON.parse(responseData);
                        }
                    } catch (error) {
                        console.log(error);
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
                console.log(responseData);

                //如果data存在callback函数，则需要返回出去
                if (callback && typeof(callback) == 'function') {
                    //判断是否是字符串,需要转为对象
                    try {
                        if (responseData && typeof(responseData) == "string") {
                            responseData = JSON.parse(responseData);
                        }
                    } catch (error) {
                        console.log(error);
                    }
                    callback(responseData);
                }
            });
        });
    },
    // 向原生发送消息 
    sendNavtive: function(data, callback) {
        this.callHandler({
            fun: 'sendNavtiveMessage', //这个字段需要与原生保持一致
            data: data
        }, callback);
    }
}