<template>
    <div>
        <h1>我是首页</h1>
        <h2 @click="test">点击试试</h2>
    </div>
</template>

<script>
export default {
    mounted () {
        this.JsBridge.registerHandler((params, callback) => {
            console.log(params);
            
            console.log(`=== ios => js`);

            callback(`js已经接受到ios发送过来的消息`);
        });
    },
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
}
</script>

<style lang="scss" scoped>
    @import '../common/css/mixin.scss';
</style>




