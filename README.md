# 原生APP与web交互


####待增加内容
* mescroll组件的上下刷新。
* 画布的生成通用方法。
* mint-ui的集成。
* axios的统一封装和抽离网络请求层。
* store的modules组件的增加。


#####粗略整理了下原生app和web的交互

web页面用vue的脚手架搭建。

在mian.js里面。将jsbridge绑定到vue的属性上。其他的与普通的vue搭建，结构都一样。

```
// 引用与app交互组件。并挂在vue的属性上
import JsBridge from '@/common/js/JsBridge.js';
Vue.prototype.JsBridge = JsBridge;

```

在home.vue上做了demo的示例。

##vue上的实现方式

### 原生app调用js方法

> 这个方法在mounted需要注册下事件。默认原生app发送给js的方法名为 `sendJsMessage`。该字段写在`JsBridge`的`registerHandler`方法的name字段上。个人建议不要动`sendJsMessage `名字统一规范一个字段。

```
this.JsBridge.registerHandler((params, callback) => {
            console.log(params);
            console.log(`=== ios => js`);
            callback(`js已经接受到ios发送过来的消息`);
        });
```


> `registerHandler`返回参数之一`params`。个人建议：具体要做什么事情，处理什么逻辑，通过`params`来做区分。比如可以返回一个结构。我们通过返回的params下的type去区分具体要做什么业务逻辑。

```

params = {
	'type': 'changeName',
	'data': {
		'name': 'radish',
		'age': 18
	}
}

```

> `registerHandler`返回参数之一`callback`方法。web处理完业务逻辑后，如果有需要通知原生app，告诉其已经完成业务逻辑，可以通过该方法来回调给原生app。


### js调用原生app方法
> 比如网页上点击了某个div，需要开始传递数据给原生app。

```
methods: {
        test() {
            // js 向app调用方法
            const params = {
                fun: 'testName',
                data: {
                    'id': 100,
                    'name': 'radish'
                }
            }
            this.JsBridge.sendNavtive(params, (res) => {
                console.log(res);
            });
        }
    }
    
```

> 传递参数`params`，个人建议由两个结构组成，一个是`fun`，就是js要调用原生app的方法。该fun的value需要在原生app上做实现。
> 传递参数`data`，传递给原生app的数据，可有可无。
> 传递参数`callback`，原生app处理完逻辑后，可以在返回数据通知给前端，已经处理完毕，前端可以接受到一个状态。


##iOS上的实现方式


