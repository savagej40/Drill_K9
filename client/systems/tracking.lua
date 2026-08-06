--========================================================--
-- drill_k9
-- File: client/systems/tracking.lua
-- Description: K9 Scent Tracking System
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.Tracking = {}

local Tracking = DK9.Tracking

------------------------------------------------------------
-- Internal
------------------------------------------------------------

local active = false
local target = nil
local lostScent = false
local lastPosition = nil

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
-- Start Tracking
------------------------------------------------------------

function Tracking.Start(entity)

    if not Exists() then
        return false
    end

    if entity == nil or entity == 0 then
        return false
    end

    if not DoesEntityExist(entity) then
        return false
    end

    target = entity
    active = true
    lostScent = false

    DK9.State.Change("TRACK")

    DK9.Events.Emit("K9:TRACK_STARTED", {
        entity = entity
    })

    DK9.Network.Notify(
        "K9",
        "Tracking started.",
        "success"
    )

    return true

end

------------------------------------------------------------
-- Stop Tracking
------------------------------------------------------------

function Tracking.Stop()

    if not active then
        return
    end

    active = false
    target = nil
    lostScent = false
    lastPosition = nil

    ClearPedTasks(Dog())

    DK9.State.Change("FOLLOW")

    DK9.Events.Emit("K9:TRACK_STOPPED")

end

------------------------------------------------------------
-- Update
------------------------------------------------------------

local function Update()

    if not active then
        return
    end

    if not Exists() then
        Tracking.Stop()
        return
    end

    if not target then
        Tracking.Stop()
        return
    end

    if not DoesEntityExist(target) then

        Tracking.Stop()

        return

    end

    local dogCoords = GetEntityCoords(Dog())
    local targetCoords = GetEntityCoords(target)

    local distance = #(dogCoords - targetCoords)

    lastPosition = targetCoords

    if distance <= 2.0 then

        DK9.Network.Notify(
            "K9",
            "Target located.",
            "success"
        )

        DK9.Events.Emit("K9:TRACK_COMPLETE", {

            target = target

        })

        Tracking.Stop()

        return

    end

    TaskGoToCoordAnyMeans(

        Dog(),

        targetCoords.x,

        targetCoords.y,

        targetCoords.z,

        3.0,

        0,

        false,

        786603,

        0

    )

end

------------------------------------------------------------
-- Lost Scent
------------------------------------------------------------

local function CheckSignal()

    if not active then
        return
    end

    if not target then
        return
    end

    local distance = #(
        GetEntityCoords(PlayerPedId()) -
        GetEntityCoords(target)
    )

    if distance > 250.0 then

        if not lostScent then

            lostScent = true

            DK9.Network.Notify(

                "K9",

                "Scent lost.",

                "warning"

            )

            DK9.Events.Emit("K9:SCENT_LOST")

        end

    else

        if lostScent then

            lostScent = false

            DK9.Network.Notify(

                "K9",

                "Scent reacquired.",

                "success"

            )

            DK9.Events.Emit("K9:SCENT_FOUND")

        end

    end

end

------------------------------------------------------------
-- Threads
------------------------------------------------------------

CreateThread(function()

    while true do

        Wait(500)

        Update()

    end

end)

CreateThread(function()

    while true do

        Wait(1000)

        CheckSignal()

    end

end)

------------------------------------------------------------
-- Crosshair Target
------------------------------------------------------------

function Tracking.GetTarget()

    local _, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())

    if entity ~= 0 then
        return entity
    end

    return nil

end

------------------------------------------------------------
-- Radial Commands
------------------------------------------------------------

DK9.Events.On("K9:COMMAND", function(data)

    if not data then
        return
    end

    if data.command == "track" then

        local entity = Tracking.GetTarget()

        if entity then

            Tracking.Start(entity)

        else

            DK9.Network.Notify(

                "K9",

                "Aim at a player to begin tracking.",

                "warning"

            )

        end

    elseif data.command == "cancel_track" then

        Tracking.Stop()

    end

end)

------------------------------------------------------------
-- Console Commands
------------------------------------------------------------

RegisterCommand("k9track", function()

    local entity = Tracking.GetTarget()

    if entity then

        Tracking.Start(entity)

    end

end)

RegisterCommand("k9stoptrack", function()

    Tracking.Stop()

end)