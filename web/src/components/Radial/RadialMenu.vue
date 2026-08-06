<template>
  <section class="radial-menu">
    <svg
      class="connector-layer"
      viewBox="0 0 640 640"
      aria-hidden="true"
    >
      <line
        v-for="command in store.commands"
        :key="command.id"
        x1="320"
        y1="320"
        :x2="linePosition(command.angle).x"
        :y2="linePosition(command.angle).y"
      />
    </svg>

    <RadialButton
      v-for="command in store.commands"
      :key="command.id"
      :command="command"
      @select="handleSelection"
    />

    <RadialCenter @select="executeCommand" />
  </section>
</template>

<script setup lang="ts">
import { useK9Store } from '../../stores/k9'
import RadialButton from './RadialButton.vue'
import RadialCenter from './RadialCenter.vue'

const store = useK9Store()
const radius = 205

function linePosition(angle: number) {
  const radians = angle * (Math.PI / 180)

  return {
    x: 320 + Math.cos(radians) * radius,
    y: 320 + Math.sin(radians) * radius
  }
}

function handleSelection(command: string) {
  if (command === 'search') {
    store.setMenu('search')
    return
  }

  if (command === 'vehicle') {
    store.setMenu('vehicle')
    return
  }

  if (command === 'more') {
    store.setMenu('more')
    return
  }

  if (command === 'back') {
    store.backMenu()
    return
  }

  void executeCommand(command)
}

async function executeCommand(command: string) {
  const resourceName =
    typeof GetParentResourceName === 'function'
      ? GetParentResourceName()
      : 'drill_k9'

  try {
    await fetch(`https://${resourceName}/radialCommand`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: JSON.stringify({
        command
      })
    })
  } catch (error) {
    console.error('[drill_k9] Radial callback failed:', error)
  }

  store.hideRadial()
}
</script>

<style scoped>
.radial-menu {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 640px;
  height: 640px;
  transform: translate(-50%, -50%);
  background: transparent !important;
  pointer-events: auto;
  animation: radial-open 180ms ease-out;
}

.connector-layer {
  position: absolute;
  inset: 0;
  width: 640px;
  height: 640px;
  overflow: visible;
  background: transparent !important;
  pointer-events: none;
}

.connector-layer line {
  stroke: rgba(95, 194, 255, 0.46);
  stroke-width: 2;
  stroke-linecap: round;
  stroke-dasharray: 5 8;
  filter: drop-shadow(0 0 5px rgba(46, 163, 255, 0.55));
}

@keyframes radial-open {
  from {
    opacity: 0;
    transform: translate(-50%, -50%) scale(0.88);
  }

  to {
    opacity: 1;
    transform: translate(-50%, -50%) scale(1);
  }
}
</style>