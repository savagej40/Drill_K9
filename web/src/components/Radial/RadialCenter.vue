<template>
  <button
    class="radial-center"
    type="button"
    @click="selectCenter"
  >
    <span class="pulse" />

    <span class="center-icon">
      <component
        :is="Icons.dog"
        :size="44"
        :stroke-width="2"
      />
    </span>

    <strong class="dog-name">
      {{ store.spawned ? store.profile.name : 'Spawn K9' }}
    </strong>

    <small class="dog-state">
      {{ store.spawned ? store.displayState : store.profile.breed }}
    </small>
  </button>
</template>

<script setup lang="ts">
import { useK9Store } from '../../stores/k9'
import { Icons } from '../icons'

const store = useK9Store()

const emit = defineEmits<{
  select: [command: string]
}>()

function selectCenter() {
  emit('select', store.spawned ? 'dismiss' : 'spawn')
}
</script>

<style scoped>
.radial-center {
  position: absolute;
  top: 50%;
  left: 50%;
  display: flex;
  width: 138px;
  height: 138px;
  padding: 0;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  transform: translate(-50%, -50%);
  border: 0;
  outline: 0;
  background: transparent !important;
  color: #ffffff;
  cursor: pointer;
  pointer-events: auto;
  text-shadow:
    0 2px 5px rgba(0, 0, 0, 1),
    0 0 12px rgba(0, 0, 0, 0.9);
}

.center-icon {
  display: grid;
  width: 76px;
  height: 76px;
  place-items: center;
  border: 2px solid rgba(100, 197, 255, 0.72);
  border-radius: 50%;
  background: transparent !important;
  color: #ffffff;
  box-shadow:
    0 0 18px rgba(46, 163, 255, 0.4),
    inset 0 0 16px rgba(46, 163, 255, 0.12);
  transition:
    transform 150ms ease,
    color 150ms ease,
    border-color 150ms ease,
    box-shadow 150ms ease;
}

.radial-center:hover .center-icon,
.radial-center:focus-visible .center-icon {
  transform: scale(1.1);
  border-color: #64c5ff;
  color: #64c5ff;
  box-shadow:
    0 0 28px rgba(46, 163, 255, 0.75),
    inset 0 0 18px rgba(46, 163, 255, 0.2);
}

.dog-name {
  margin-top: 8px;
  font-size: 16px;
  font-weight: 750;
}

.dog-state {
  margin-top: 2px;
  color: rgba(255, 255, 255, 0.75);
  font-size: 10px;
  font-weight: 650;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.pulse {
  position: absolute;
  top: 10px;
  left: 50%;
  width: 84px;
  height: 84px;
  transform: translateX(-50%);
  border: 1px solid rgba(100, 197, 255, 0.48);
  border-radius: 50%;
  pointer-events: none;
  animation: center-pulse 2s ease-out infinite;
}

@keyframes center-pulse {
  0% {
    opacity: 0.8;
    transform: translateX(-50%) scale(0.88);
  }

  75%,
  100% {
    opacity: 0;
    transform: translateX(-50%) scale(1.35);
  }
}
</style>