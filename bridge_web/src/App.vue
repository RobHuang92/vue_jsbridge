<template>
    <div id="app">
        <router-view/>
    </div>
</template>

<script>
export default {
    name: 'App'
}
</script>

<style lang="scss">
    @import './common/css/common.scss';
    @import './common/css/mixin.scss';
    @import './common/css/mint.scss';
    #app{
        width: 100%;
        height: 100%;
    }
    body, html{
        background: $bg_c;
        color: $font_c;
    }
    .animated{
        animation-duration: 0.5s;
    }
</style>

