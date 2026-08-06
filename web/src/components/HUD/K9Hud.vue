<template>
  <Transition name="hud">
    <section
      v-if="store.hudVisible && store.spawned"
      class="k9-hud"
    >
      <header class="hud-header">
        <div>
          <div class="dog-name">{{ store.profile.name }}</div>
          <div class="dog-breed">{{ store.profile.breed }}</div>
        </div>

        <div class="dog-state">
          {{ store.displayState }}
        </div>
      </header>

      <StatBar
        label="Health"
        icon="♥"
        :value="formatStat(store.vitals.health)"
      />

      <StatBar
        label="Armor"
        icon="◆"
        :value="formatStat(store.vitals.armor)"
      />

      <StatBar
        label="Food"
        icon="●"
        :value="formatStat(store.vitals.food)"
      />

      <StatBar
        label="Water"
        icon="◉"
        :value="formatStat(store.vitals.water)"
      />

      <StatBar
        label="Energy"
        icon="ϟ"
        :value="formatStat(store.vitals.energy)"
      />

      <footer class="hud-footer">
        <span>{{ store.gps.distance.toFixed(1) }} ft</span>

        <span
          class="gps-status"
          :class="{ connected: store.gps.connected }"
        >
          {{ store.gps.connected ? 'GPS' : 'OFFLINE' }}
        </span>
      </footer>
    </section>
  </Transition>
</template>

<script setup lang="ts">
import { useK9Store } from '../../stores/k9'
import StatBar from './StatBar.vue'

const store = useK9Store()

function formatStat(value: number): number {
  if (!Number.isFinite(value)) {
    return 0
  }

  return Math.round(Math.min(100, Math.max(0, value)))
}
</script>

<style scoped>
.k9-hud {
  position: absolute;
  right: 24px;
  bottom: 24px;
  width: 280px;
  color: white;
  font-family: Inter, system-ui, sans-serif;
  pointer-events: none;
  text-shadow:
    0 2px 4px rgba(0, 0, 0, 0.95),
    0 0 10px rgba(0, 0, 0, 0.8);
}

.hud-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 14px;
}

.dog-name {
  font-size: 21px;
  font-weight: 750;
}

.dog-breed {
  margin-top: 2px;
  font-size: 12px;
  opacity: 0.75;
}

.dog-state {
  color: #65c5ff;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.1em;
}

.hud-footer {
  display: flex;
  justify-content: space-between;
  margin-top: 13px;
  font-size: 12px;
  font-weight: 650;
}

.gps-status {
  opacity: 0.55;
}

.gps-status.connected {
  color: #43dd80;
  opacity: 1;
}

.hud-enter-active,
.hud-leave-active {
  transition:
    opacity 180ms ease,
    transform 180ms ease;
}

.hud-enter-from,
.hud-leave-to {
  opacity: 0;
  transform: translateY(10px);
}
</style>