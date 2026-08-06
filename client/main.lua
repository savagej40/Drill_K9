--========================================================--
-- drill_k9
-- File: client/main.lua
-- Description: Client initialization and keybinds
-- Version: 0.3.3
--========================================================--

local menuOpen = false
local clientReady = false

------------------------------------------------------------
-- Menu controls
------------------------------------------------------------

local function setMenuOpen(open)
    if not clientReady then
        return
    end

    if not DK9 or not DK9.Network then
        print('^1[drill_k9] Network module is unavailable.^7')
        return
    end

    menuOpen = open == true

    DK9.Network.ToggleRadial(menuOpen)

    if Config.Debug then
        print(('[drill_k9] Menu %s.'):format(
            menuOpen and 'opened' or 'closed'
        ))
    end
end

local function toggleMenu()
    setMenuOpen(not menuOpen)
end

------------------------------------------------------------
-- Client initialization
------------------------------------------------------------

CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(250)
    end

    Wait(1000)

    if not DK9 or not DK9.Engine then
        print('^1[drill_k9] Engine module failed to load.^7')
        return
    end

    if not DK9.Events then
        print('^1[drill_k9] Events module failed to load.^7')
        return
    end

    if not DK9.Network then
        print('^1[drill_k9] Network module failed to load.^7')
        return
    end

    DK9.Engine.Initialize(PlayerPedId())

    clientReady = true
    menuOpen = false

    DK9.Network.HideRadial()
    DK9.Network.ResetUI()
    DK9.Network.UpdateHUD()

    TriggerServerEvent('drill_k9:server:clientReady')

    local profile = DK9.Engine.GetProfile()

    print((
        '^2[drill_k9] Client initialized. K9 profile: %s (%s).^7'
    ):format(
        profile.Name or 'Rex',
        profile.Breed or 'German Shepherd'
    ))
end)

------------------------------------------------------------
-- Handler ped update
------------------------------------------------------------

CreateThread(function()
    while true do
        if clientReady and DK9 and DK9.Engine then
            DK9.Engine.SetHandler(PlayerPedId())
        end

        Wait(1000)
    end
end)

------------------------------------------------------------
-- F5 key mapping
------------------------------------------------------------

RegisterCommand('+drillk9menu', function()
    toggleMenu()
end, false)

RegisterCommand('-drillk9menu', function()
end, false)

RegisterKeyMapping(
    '+drillk9menu',
    'Open K9 control menu',
    'keyboard',
    Config.Keys.Menu
)

------------------------------------------------------------
-- Server ready
------------------------------------------------------------

RegisterNetEvent('drill_k9:client:serverReady', function(serverVersion)
    if Config.Debug then
        print((
            '^2[drill_k9] Connected to server version %s.^7'
        ):format(tostring(serverVersion)))
    end
end)

------------------------------------------------------------
-- Keep local menu state synchronized
------------------------------------------------------------

AddEventHandler('drill_k9:client:menuClosed', function()
    menuOpen = false
end)

------------------------------------------------------------
-- Resource cleanup
------------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    menuOpen = false
    clientReady = false

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    if DK9 and DK9.Network then
        DK9.Network.ResetUI()
    end

    if DK9 and DK9.Engine then
        DK9.Engine.Cleanup()
    end
end)