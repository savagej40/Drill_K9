--========================================================--
-- drill_k9
-- File: fxmanifest.lua
-- Description: Standalone Advanced K9 System
--========================================================--

fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Drill Development'
description 'Advanced Standalone K9 System'
version '0.2.0'

---------------------------------------------------------
-- UI
---------------------------------------------------------

ui_page 'ui/index.html'

files {
    'ui/**'
}

---------------------------------------------------------
-- Shared
---------------------------------------------------------

shared_scripts {
    'shared/config.lua',
    'shared/states.lua',
    'shared/utils.lua'
}

---------------------------------------------------------
-- Client
---------------------------------------------------------

client_scripts {

    -- Core
    'client/core/engine.lua',
    'client/core/events.lua',
    'client/core/state.lua',
    'client/core/network.lua',

    -- AI
    'client/ai/navigation.lua',
    'client/ai/controller.lua',

    -- Systems
    'client/systems/spawn.lua',
    'client/systems/movement.lua',
    'client/systems/vehicle.lua',
    'client/systems/combat.lua',
    'client/systems/gps.lua',
    'client/systems/hunger.lua',
    'client/systems/search.lua',
    'client/systems/tracking.lua',
    'client/systems/animations.lua',
    'client/systems/ai.lua',
    'client/systems/health.lua',
    'client/systems/items.lua',
    'client/systems/kennel.lua',

    -- Bootstrap
    'client/main.lua'
}

---------------------------------------------------------
-- Server
---------------------------------------------------------

server_scripts {
    'server/main.lua'
}

dependency '/onesync'