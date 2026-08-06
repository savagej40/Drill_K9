<template>
  <div class="search-backdrop">
    <form class="search-panel" @submit.prevent="submit">
      <header>
        <p class="eyebrow">DRILL K9</p>
        <h1>Person Search</h1>
        <p>Report everything currently on your person.</p>
      </header>

      <section class="category-list">
        <label v-for="category in categories" :key="category.key" class="category-row">
          <span>{{ category.label }}</span>
          <button
            type="button"
            class="toggle"
            :class="{ active: form[category.key] }"
            @click="form[category.key] = !form[category.key]"
          >
            {{ form[category.key] ? 'YES' : 'NO' }}
          </button>
        </label>
      </section>

      <label class="other-label" for="other-property">Other Property</label>
      <textarea
        id="other-property"
        v-model="form.other"
        maxlength="1000"
        placeholder="Wallet&#10;Cell phone&#10;Keys&#10;Other items..."
      />

      <div class="counter">{{ form.other.length }}/1000</div>

      <div class="actions">
        <button type="button" class="secondary" @click="cancel">
          Cancel
        </button>
        <button type="submit">Submit</button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue'

export type PersonSearchReport = {
  weapons: boolean
  drugs: boolean
  explosives: boolean
  largeCash: boolean
  evidence: boolean
  other: string
}

type BooleanReportKey = Exclude<keyof PersonSearchReport, 'other'>

const emit = defineEmits<{
  submit: [report: PersonSearchReport]
  cancel: []
}>()

const categories: Array<{ key: BooleanReportKey; label: string }> = [
  { key: 'weapons', label: 'Weapons' },
  { key: 'drugs', label: 'Drugs' },
  { key: 'explosives', label: 'Explosives' },
  { key: 'largeCash', label: 'Large Amount of Cash' },
  { key: 'evidence', label: 'Evidence' }
]

const form = reactive<PersonSearchReport>({
  weapons: false,
  drugs: false,
  explosives: false,
  largeCash: false,
  evidence: false,
  other: ''
})

function submit() {
  emit('submit', {
    weapons: form.weapons,
    drugs: form.drugs,
    explosives: form.explosives,
    largeCash: form.largeCash,
    evidence: form.evidence,
    other: form.other.trim()
  })
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
  width: min(560px, 100%);
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

.category-list {
  display: grid;
  gap: 9px;
  margin-bottom: 18px;
}

.category-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 48px;
  padding: 9px 12px 9px 15px;
  border: 1px solid rgba(255,255,255,.1);
  border-radius: 11px;
  background: rgba(255,255,255,.035);
  font-weight: 650;
}

.toggle {
  min-width: 66px;
  padding: 8px 12px;
  background: rgba(255,255,255,.09);
  color: rgba(255,255,255,.72);
}

.toggle.active {
  background: #e25050;
  color: white;
}

.other-label {
  display: block;
  margin: 0 0 8px;
  color: rgba(255,255,255,.82);
  font-weight: 700;
}

textarea {
  width: 100%;
  min-height: 140px;
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
</style>
