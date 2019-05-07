<template>
    <div>
        <h1>我是首页</h1>
        <h2 @click="test">点击试试</h2>
    </div>
</template>

<script>
export default {
    mounted () {
        console.log(this.JsBridge);

        this.JsBridge.registerHandler()
        
    },
    methods: {
        test() {

        }
    }
}
</script>

<style lang="scss" scoped>
    @import '../common/css/mixin.scss';
</style>




