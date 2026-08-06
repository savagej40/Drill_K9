<template>
  <div id="drill-k9-ui">
    <K9Hud />

    <RadialMenu v-if="store.radialVisible" />

    <PersonSearch
      v-if="personSearchVisible"
      @submit="submitPersonSearch"
      @cancel="cancelPersonSearch"
    />
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue'

import { useK9Store } from './stores/k9'
import K9Hud from './components/HUD/K9Hud.vue'
import RadialMenu from './components/Radial/RadialMenu.vue'
import PersonSearch from './components/Search/PersonSearch.vue'
import type { PersonSearchReport } from './components/Search/PersonSearch.vue'

const store = useK9Store()
const personSearchVisible = ref(false)

function resourceName(): string {
  return typeof GetParentResourceName === 'function'
    ? GetParentResourceName()
    : 'drill_k9'
}

async function nuiPost(endpoint: string, payload: Record<string, unknown> = {}) {
  await fetch(`https://${resourceName()}/${endpoint}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: JSON.stringify(payload)
  })
}

async function submitPersonSearch(report: PersonSearchReport) {
  await nuiPost('personSearchSubmit', { report })
  personSearchVisible.value = false
}

async function cancelPersonSearch() {
  await nuiPost('personSearchCancel')
  personSearchVisible.value = false
}

function handleNuiMessage(event: MessageEvent) {
  const message = event.data

  if (!message || typeof message !== 'object') {
    return
  }

  const messageType = message.type ?? message.action

  switch (messageType) {
    case 'show':
    case 'showRadial':
      store.showRadial()
      break

    case 'hide':
    case 'hideRadial':
      store.hideRadial()
      break

    case 'toggle':
    case 'toggleRadial':
      store.toggleRadial()
      break

    case 'showPersonSearch':
      store.hideRadial()
      personSearchVisible.value = true
      break

    case 'hidePersonSearch':
      personSearchVisible.value = false
      break

    case 'hud':
      if (!message.data) {
        return
      }

      store.hydrate({
        spawned: message.data.spawned,
        state: message.data.state,
        profile: message.data.profile,
        vitals: message.data.vitals ?? message.data.stats,
        gps: message.data.gps
      })
      break

    case 'reset':
      personSearchVisible.value = false
      store.reset()
      break
  }
}

onMounted(() => {
  store.reset()
  window.addEventListener('message', handleNuiMessage)
})

onUnmounted(() => {
  window.removeEventListener('message', handleNuiMessage)
})
</script>

<style>
:root,
html,
body,
#app,
#drill-k9-ui {
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
  overflow: hidden;
  background: transparent !important;
}

* {
  box-sizing: border-box;
}

#drill-k9-ui {
  position: fixed;
  inset: 0;
  z-index: 2147483647;
  pointer-events: none;
}
</style>
