import type { K9Command } from '../stores/k9'

export type MenuName =
  | 'main'
  | 'search'
  | 'vehicle'
  | 'more'

export const Menus: Record<MenuName, K9Command[]> = {
  main: [
    {
      id: 'follow',
      label: 'Follow',
      subtitle: 'Stay close',
      angle: 270,
      enabled: true
    },
    {
      id: 'sit',
      label: 'Sit',
      subtitle: 'Hold position',
      angle: 315,
      enabled: true
    },
    {
      id: 'stay',
      label: 'Stay',
      subtitle: 'Remain here',
      angle: 0,
      enabled: true
    },
    {
      id: 'vehicle',
      label: 'Vehicle',
      subtitle: 'Choose a seat',
      angle: 45,
      enabled: true
    },
    {
      id: 'apprehend',
      label: 'Apprehend',
      subtitle: 'Deploy K9',
      angle: 90,
      enabled: true
    },
    {
      id: 'track',
      label: 'Track',
      subtitle: 'Track target',
      angle: 135,
      enabled: true
    },
    {
      id: 'search',
      label: 'Search',
      subtitle: 'Search options',
      angle: 180,
      enabled: true
    },
    {
      id: 'more',
      label: 'More',
      subtitle: 'Additional commands',
      angle: 225,
      enabled: true
    }
  ],

  search: [
    {
      id: 'search_player',
      label: 'Person',
      subtitle: 'Search aimed person',
      angle: 270,
      enabled: true
    },
    {
      id: 'search_vehicle',
      label: 'Vehicle',
      subtitle: 'Search aimed vehicle',
      angle: 342,
      enabled: true
    },
    {
      id: 'search_area',
      label: 'Area',
      subtitle: 'Search nearby area',
      angle: 54,
      enabled: true
    },
    {
      id: 'back',
      label: 'Back',
      subtitle: 'Main menu',
      angle: 162,
      enabled: true
    }
  ],

  vehicle: [
    {
      id: 'vehicle_driver',
      label: 'Driver',
      subtitle: 'Driver seat',
      angle: 270,
      enabled: true
    },
    {
      id: 'vehicle_passenger',
      label: 'Passenger',
      subtitle: 'Front passenger',
      angle: 330,
      enabled: true
    },
    {
      id: 'vehicle_rear_left',
      label: 'Rear Left',
      subtitle: 'Left rear seat',
      angle: 30,
      enabled: true
    },
    {
      id: 'vehicle_rear_right',
      label: 'Rear Right',
      subtitle: 'Right rear seat',
      angle: 90,
      enabled: true
    },
    {
      id: 'vehicle_exit',
      label: 'Exit',
      subtitle: 'Leave vehicle',
      angle: 150,
      enabled: true
    },
    {
      id: 'back',
      label: 'Back',
      subtitle: 'Main menu',
      angle: 210,
      enabled: true
    }
  ],

  more: [
    {
      id: 'feed',
      label: 'Feed',
      subtitle: 'Give K9 food',
      angle: 270,
      enabled: true
    },
    {
      id: 'water',
      label: 'Water',
      subtitle: 'Give K9 water',
      angle: 330,
      enabled: true
    },
    {
      id: 'heal',
      label: 'Heal',
      subtitle: 'Treat injuries',
      angle: 30,
      enabled: true
    },
    {
      id: 'armor',
      label: 'Armor',
      subtitle: 'Apply ballistic vest',
      angle: 90,
      enabled: true
    },
    {
      id: 'gps_toggle',
      label: 'GPS',
      subtitle: 'Toggle tracker',
      angle: 150,
      enabled: true
    },
    {
      id: 'dismiss',
      label: 'Dismiss',
      subtitle: 'Dismiss K9',
      angle: 210,
      enabled: true
    },
    {
      id: 'back',
      label: 'Back',
      subtitle: 'Main menu',
      angle: 240,
      enabled: true
    }
  ]
}