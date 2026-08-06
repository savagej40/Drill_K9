<template>
  <button
    class="radial-button"
    :class="{ disabled: !command.enabled }"
    :style="buttonPosition"
    :disabled="!command.enabled"
    type="button"
    @click="selectCommand"
  >
    <span class="button-content">
      <component
        :is="icon"
        :size="29"
        :stroke-width="2"
        aria-hidden="true"
      />

      <strong>{{ command.label }}</strong>

      <small>{{ command.subtitle }}</small>
    </span>
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'

import type { K9Command } from '../../stores/k9'
import { Icons } from '../icons'

const props = defineProps<{
  command: K9Command
}>()

const emit = defineEmits<{
  select: [command: string]
}>()

const radius = 205

const icon = computed(() => {
  return Icons[
    props.command.id as keyof typeof Icons
  ] ?? Icons.paw
})

const buttonPosition = computed(() => {
  const radians = props.command.angle * (Math.PI / 180)

  const x = Math.cos(radians) * radius
  const y = Math.sin(radians) * radius

  return {
    left: `${320 + x}px`,
    top: `${320 + y}px`
  }
})

function selectCommand() {
  if (!props.command.enabled) {
    return
  }

  emit('select', props.command.id)
}
</script>

<style scoped>
.radial-button {
  position: absolute;
  width: 118px;
  height: 86px;
  padding: 0;
  transform: translate(-50%, -50%);
  border: 0;
  outline: 0;
  background: transparent;
  color: white;
  cursor: pointer;
  pointer-events: auto;
  text-shadow:
    0 2px 5px rgba(0, 0, 0, 1),
    0 0 12px rgba(0, 0, 0, 0.9);
}

.button-content {
  display: flex;
  width: 100%;
  height: 100%;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 3px;
  transition:
    color 150ms ease,
    transform 150ms ease,
    filter 150ms ease;
}

.radial-button:hover .button-content,
.radial-button:focus-visible .button-content {
  color: #64c5ff;
  transform: scale(1.14);
  filter: drop-shadow(0 0 9px rgba(46, 163, 255, 0.85));
}

.radial-button strong {
  font-size: 14px;
  font-weight: 750;
}

.radial-button small {
  max-width: 115px;
  overflow: hidden;
  color: rgba(255, 255, 255, 0.72);
  font-size: 10px;
  font-weight: 500;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.radial-button.disabled {
  cursor: default;
  opacity: 0.35;
}
</style>