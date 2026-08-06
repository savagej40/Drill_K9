<template>
  <div class="search-backdrop">
    <form class="search-panel" @submit.prevent="submit">
      <header>
        <p class="eyebrow">DRILL K9</p>
        <h1>Person Search</h1>
        <p>List everything currently on your person.</p>
      </header>

      <textarea
        v-model="inventory"
        maxlength="1000"
        placeholder="Wallet&#10;Cell phone&#10;Cash&#10;Keys..."
        autofocus
      />

      <div class="counter">{{ inventory.length }}/1000</div>

      <div class="actions">
        <button type="button" class="secondary" @click="cancel">
          Cancel
        </button>
        <button type="submit" :disabled="inventory.trim().length === 0">
          Submit
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const emit = defineEmits<{
  submit: [inventory: string]
  cancel: []
}>()

const inventory = ref('')

function submit() {
  const value = inventory.value.trim()
  if (!value) return
  emit('submit', value)
}

function cancel() {
  emit('cancel')
}
</script>

<style scoped>
.search-backdrop {
  position: fixed;
  inset: 0;
  display: grid;
  place-items: center;
  padding: 24px;
  background: rgba(4, 8, 14, 0.72);
  pointer-events: auto;
}

.search-panel {
  width: min(520px, 100%);
  padding: 28px;
  border: 1px solid rgba(108, 196, 255, 0.32);
  border-radius: 18px;
  background: linear-gradient(145deg, rgba(14, 24, 38, 0.98), rgba(7, 13, 22, 0.98));
  box-shadow: 0 24px 80px rgba(0, 0, 0, 0.55);
  color: white;
  font-family: Inter, system-ui, sans-serif;
}

header { margin-bottom: 18px; }
.eyebrow { margin: 0 0 5px; color: #64c7ff; font-size: 12px; font-weight: 800; letter-spacing: 0.18em; }
h1 { margin: 0; font-size: 28px; }
header p:last-child { margin: 8px 0 0; color: rgba(255,255,255,.68); }

textarea {
  width: 100%;
  min-height: 220px;
  resize: none;
  padding: 16px;
  border: 1px solid rgba(255,255,255,.14);
  border-radius: 12px;
  outline: none;
  background: rgba(0,0,0,.28);
  color: white;
  font: inherit;
  line-height: 1.5;
}
textarea:focus { border-color: rgba(100,199,255,.75); }
.counter { margin-top: 7px; text-align: right; color: rgba(255,255,255,.45); font-size: 12px; }
.actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 18px; }
button { padding: 11px 18px; border: 0; border-radius: 10px; background: #38aeea; color: #05111a; font-weight: 800; cursor: pointer; }
button.secondary { background: rgba(255,255,255,.09); color: white; }
button:disabled { opacity: .4; cursor: not-allowed; }
</style>
