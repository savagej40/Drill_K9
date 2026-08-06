--========================================================--
-- drill_k9
-- File: client/systems/gps.lua
-- Description: K9 GPS Tracking System
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.GPS = {}

local GPS = DK9.GPS

------------------------------------------------------------
-- Internal
------------------------------------------------------------

local blip = nil
local signalLost = false

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function Dog()
    return DK9.Engine.GetEntity()
end

local function Exists()

    local entity = Dog()

    return entity ~= 0 and DoesEntityExist(entity)

end

------------------------------------------------------------
-- Create Blip
------------------------------------------------------------

function GPS.CreateBlip()

    if blip then
        return
    end

    if not Exists() then
        return
    end

    blip = AddBlipForEntity(Dog())

    SetBlipSprite(blip, 442)
    SetBlipColour(blip, 3)
    SetBlipScale(blip, 0.75)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("K9")
    EndTextCommandSetBlipName(blip)

    DK9.Engine.SetGPS({
        Enabled = true,
        Connected = true,
        Blip = blip
    })

end

------------------------------------------------------------
-- Remove Blip
------------------------------------------------------------

function GPS.RemoveBlip()

    if blip and DoesBlipExist(blip) then

        RemoveBlip(blip)

    end

    blip = nil

    DK9.Engine.SetGPS({

        Connected = false,
        Blip = nil

    })

end

------------------------------------------------------------
-- Update
------------------------------------------------------------

function GPS.Update()

    if not Exists() then
        return
    end

    local handler = PlayerPedId()

    local distance = #(GetEntityCoords(handler) - GetEntityCoords(Dog()))

    DK9.Engine.SetGPS({

        Distance = distance,

        Connected = true

    })

    DK9.Network.UpdateHUD()

    DK9.Events.Emit("K9:GPS_UPDATED", {

        distance = distance

    })

    if distance > 500.0 then

        if not signalLost then

            signalLost = true

            DK9.Network.Notify(

                "K9 GPS",

                "GPS signal lost.",

                "warning"

            )

        end

    else

        signalLost = false

    end

end

------------------------------------------------------------
-- Toggle
------------------------------------------------------------

function GPS.Toggle()

    if blip then

        GPS.RemoveBlip()

    else

        GPS.CreateBlip()

    end

end

------------------------------------------------------------
-- Threads
------------------------------------------------------------

CreateThread(function()

    while true do

        Wait(1000)

        if DK9.Engine.IsSpawned() then

            if Exists() then

                if not blip then

                    GPS.CreateBlip()

                end

                GPS.Update()

            else

                GPS.RemoveBlip()

            end

        else

            GPS.RemoveBlip()

        end

    end

end)

------------------------------------------------------------
-- Events
------------------------------------------------------------

DK9.Events.On("K9:SPAWNED", function()

    GPS.CreateBlip()

end)

DK9.Events.On("K9:DISMISSED", function()

    GPS.RemoveBlip()

end)

DK9.Events.On("K9:ENTITY_LOST", function()

    GPS.RemoveBlip()

end)

DK9.Events.On("K9:COMMAND", function(data)

    if not data then
        return
    end

    if data.command == "gps_toggle" then

        GPS.Toggle()

    end

end)