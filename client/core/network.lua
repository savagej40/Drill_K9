--========================================================--
-- drill_k9
-- File: client/core/network.lua
-- Description: NUI and server communication
-- Version: 0.3.2
--========================================================--

DK9 = DK9 or {}
DK9.Network = {}

local Network = DK9.Network

------------------------------------------------------------
-- Send message to Vue
------------------------------------------------------------

function Network.SendUI(messageType, data)
    SendNUIMessage({
        type = messageType,
        action = messageType,
        data = data or {}
    })
end

------------------------------------------------------------
-- Radial visibility
------------------------------------------------------------

function Network.ShowRadial()
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    Network.SendUI('showRadial')
end

function Network.HideRadial()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    Network.SendUI('hideRadial')
end

function Network.ToggleRadial(open)
    if open == true then
        Network.ShowRadial()
    else
        Network.HideRadial()
    end
end

------------------------------------------------------------
-- HUD update
------------------------------------------------------------

function Network.UpdateHUD()
    if not DK9.Engine or not DK9.Engine.IsReady() then
        return
    end

    local profile = DK9.Engine.GetProfile()
    local stats = DK9.Engine.GetStats()
    local gps = DK9.Engine.GetGPS()

    Network.SendUI('hud', {
        spawned = DK9.Engine.IsSpawned(),
        state = DK9.Engine.GetState(),

        profile = {
            name = profile.Name or 'Rex',
            breed = profile.Breed or 'German Shepherd',
            model = profile.Model or 'a_c_shepherd',
            collarId = profile.CollarId or ''
        },

        vitals = {
            health = stats.Health or 100,
            armor = stats.Armor or 0,
            food = stats.Food or 100,
            water = stats.Water or 100,
            energy = stats.Energy or 100
        },

        gps = {
            enabled = gps.Enabled == true,
            connected = gps.Connected == true,
            distance = gps.Distance or 0.0,
            bearing = gps.Bearing or 0.0
        }
    })
end

function Network.ResetUI()
    Network.SendUI('reset')
end

------------------------------------------------------------
-- Notifications
------------------------------------------------------------

function Network.Notify(title, message, notificationType)
    Network.SendUI('notification', {
        title = title or 'K9',
        message = message or '',
        notificationType = notificationType or 'info'
    })
end

------------------------------------------------------------
-- NUI callbacks
------------------------------------------------------------

RegisterNUICallback('closeMenu', function(_, callback)
    Network.HideRadial()

    TriggerEvent('drill_k9:client:menuClosed')

    callback({
        success = true
    })
end)

RegisterNUICallback('radialCommand', function(data, callback)
    local command = type(data) == 'table' and data.command or nil

    if type(command) ~= 'string' or command == '' then
        callback({
            success = false,
            error = 'Invalid command.'
        })

        return
    end

    DK9.Events.Emit('K9:COMMAND', {
        command = command
    })

    Network.HideRadial()

    TriggerEvent('drill_k9:client:menuClosed')

    callback({
        success = true
    })
end)

------------------------------------------------------------
-- Event listeners
------------------------------------------------------------

DK9.Events.On('K9:STATE_CHANGED', Network.UpdateHUD)
DK9.Events.On('K9:SPAWNED', Network.UpdateHUD)
DK9.Events.On('K9:DISMISSED', Network.UpdateHUD)
DK9.Events.On('K9:STATS_UPDATED', Network.UpdateHUD)
DK9.Events.On('K9:GPS_UPDATED', Network.UpdateHUD)