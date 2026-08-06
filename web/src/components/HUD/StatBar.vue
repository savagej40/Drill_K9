<template>
    <div class="stat">

        <div class="stat-header">

            <span class="label">

                {{ icon }} {{ label }}

            </span>

            <span class="value">

                {{ value }}%

            </span>

        </div>

        <div class="bar">

            <div
                class="fill"
                :class="colorClass"
                :style="{
                    width: value + '%'
                }"
            />

        </div>

    </div>
</template>

<script setup lang="ts">

import { computed } from 'vue'

const props = defineProps({

    label: {

        type: String,

        required: true

    },

    icon: {

        type: String,

        required: true

    },

    value: {

        type: Number,

        required: true

    }

})

const colorClass = computed(() => {

    if (props.value >= 70)
        return 'good'

    if (props.value >= 35)
        return 'warning'

    return 'danger'

})

</script>

<style scoped>

.stat{

    margin-top:12px;

}

.stat-header{

    display:flex;

    justify-content:space-between;

    align-items:center;

    margin-bottom:6px;

    font-size:13px;

}

.label{

    opacity:.9;

}

.value{

    font-weight:700;

}

.bar{

    width:100%;

    height:8px;

    overflow:hidden;

    border-radius:100px;

    background:rgba(255,255,255,.08);

}

.fill{

    height:100%;

    border-radius:100px;

    transition:

        width .35s ease,

        background-color .35s ease;

}

.good{

    background:#37d67a;

}

.warning{

    background:#f6b93b;

}

.danger{

    background:#ff5b5b;

}

</style>