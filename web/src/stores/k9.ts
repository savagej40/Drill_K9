import { defineStore } from 'pinia'
import { Menus } from '../data/menus'

export type K9Command = {
  id: string
  label: string
  subtitle: string
  angle: number
  enabled: boolean
}

export type K9Profile = {
  name: string
  breed: string
  model: string
  collarId: string
}

export type K9Vitals = {
  health: number
  armor: number
  food: number
  water: number
  energy: number
}

export type K9Gps = {
  enabled: boolean
  connected: boolean
  distance: number
  bearing: number
}

export type K9MenuName = keyof typeof Menus

export type K9UiState = {
  radialVisible: boolean
  hudVisible: boolean
  tabletVisible: boolean
  spawned: boolean
  state: string
  currentMenu: K9MenuName
  profile: K9Profile
  vitals: K9Vitals
  gps: K9Gps
  commands: K9Command[]
}

function clamp(
  value: number,
  minimum = 0,
  maximum = 100
): number {
  return Math.min(maximum, Math.max(minimum, value))
}

export const useK9Store = defineStore('k9', {
  state: (): K9UiState => ({
    radialVisible: false,
    hudVisible: false,
    tabletVisible: false,
    spawned: false,
    state: 'IDLE',
    currentMenu: 'main',

    profile: {
      name: 'Rex',
      breed: 'German Shepherd',
      model: 'a_c_shepherd',
      collarId: ''
    },

    vitals: {
      health: 100,
      armor: 0,
      food: 100,
      water: 100,
      energy: 100
    },

    gps: {
      enabled: true,
      connected: false,
      distance: 0,
      bearing: 0
    },

    commands: Menus.main.map((command) => ({
      ...command
    }))
  }),

  getters: {
    displayState: (state): string => {
      return state.state.replaceAll('_', ' ')
    },

    isAlive: (state): boolean => {
      return state.state !== 'DEAD'
    },

    needsFood: (state): boolean => {
      return state.vitals.food <= 25
    },

    needsWater: (state): boolean => {
      return state.vitals.water <= 25
    },

    isCritical: (state): boolean => {
      return (
        state.vitals.health <= 25 ||
        state.vitals.food <= 10 ||
        state.vitals.water <= 10
      )
    }
  },

  actions: {
    showRadial() {
      this.radialVisible = true
      this.tabletVisible = false
      this.setMenu('main')
    },

    hideRadial() {
      this.radialVisible = false
      this.setMenu('main')
    },

    toggleRadial() {
      this.radialVisible = !this.radialVisible

      if (this.radialVisible) {
        this.tabletVisible = false
        this.setMenu('main')
      } else {
        this.setMenu('main')
      }
    },

    showHud() {
      this.hudVisible = true
    },

    hideHud() {
      this.hudVisible = false
    },

    showTablet() {
      this.tabletVisible = true
      this.radialVisible = false
      this.setMenu('main')
    },

    hideTablet() {
      this.tabletVisible = false
    },

    toggleTablet() {
      this.tabletVisible = !this.tabletVisible

      if (this.tabletVisible) {
        this.radialVisible = false
        this.setMenu('main')
      }
    },

    setMenu(menu: K9MenuName) {
      this.currentMenu = menu

      this.commands = Menus[menu].map((command) => ({
        ...command
      }))
    },

    backMenu() {
      this.setMenu('main')
    },

    setSpawned(spawned: boolean) {
      this.spawned = spawned
      this.hudVisible = spawned

      if (!spawned) {
        this.radialVisible = false
        this.tabletVisible = false
        this.setMenu('main')
      }
    },

    setState(state: string) {
      if (typeof state !== 'string' || state.length === 0) {
        return
      }

      this.state = state
    },

    setProfile(profile: Partial<K9Profile>) {
      this.profile = {
        ...this.profile,
        ...profile
      }
    },

    setVitals(vitals: Partial<K9Vitals>) {
      this.vitals = {
        health: clamp(
          vitals.health ?? this.vitals.health
        ),
        armor: clamp(
          vitals.armor ?? this.vitals.armor
        ),
        food: clamp(
          vitals.food ?? this.vitals.food
        ),
        water: clamp(
          vitals.water ?? this.vitals.water
        ),
        energy: clamp(
          vitals.energy ?? this.vitals.energy
        )
      }
    },

    setGps(gps: Partial<K9Gps>) {
      this.gps = {
        ...this.gps,
        ...gps,
        distance: Math.max(
          0,
          gps.distance ?? this.gps.distance
        ),
        bearing: gps.bearing ?? this.gps.bearing
      }
    },

    setCommands(commands: K9Command[]) {
      if (!Array.isArray(commands)) {
        return
      }

      this.commands = commands.map((command) => ({
        ...command
      }))
    },

    setCommandEnabled(
      commandId: string,
      enabled: boolean
    ) {
      const command = this.commands.find(
        (item) => item.id === commandId
      )

      if (command) {
        command.enabled = enabled
      }
    },

    hydrate(payload: Partial<K9UiState>) {
      if (
        typeof payload.radialVisible === 'boolean'
      ) {
        this.radialVisible = payload.radialVisible
      }

      if (
        typeof payload.hudVisible === 'boolean'
      ) {
        this.hudVisible = payload.hudVisible
      }

      if (
        typeof payload.tabletVisible === 'boolean'
      ) {
        this.tabletVisible = payload.tabletVisible
      }

      if (typeof payload.spawned === 'boolean') {
        this.setSpawned(payload.spawned)
      }

      if (typeof payload.state === 'string') {
        this.setState(payload.state)
      }

      if (payload.currentMenu) {
        this.setMenu(payload.currentMenu)
      }

      if (payload.profile) {
        this.setProfile(payload.profile)
      }

      if (payload.vitals) {
        this.setVitals(payload.vitals)
      }

      if (payload.gps) {
        this.setGps(payload.gps)
      }

      if (payload.commands) {
        this.setCommands(payload.commands)
      }
    },

    reset() {
      this.radialVisible = false
      this.hudVisible = false
      this.tabletVisible = false
      this.spawned = false
      this.state = 'IDLE'
      this.currentMenu = 'main'

      this.profile = {
        name: 'Rex',
        breed: 'German Shepherd',
        model: 'a_c_shepherd',
        collarId: ''
      }

      this.vitals = {
        health: 100,
        armor: 0,
        food: 100,
        water: 100,
        energy: 100
      }

      this.gps = {
        enabled: true,
        connected: false,
        distance: 0,
        bearing: 0
      }

      this.commands = Menus.main.map(
        (command) => ({
          ...command
        })
      )
    }
  }
})