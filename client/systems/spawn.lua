--========================================================--
-- drill_k9
-- File: client/systems/spawn.lua
-- Description: K9 Spawn & Dismiss System
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.Spawn = {}

local Spawn = DK9.Spawn

------------------------------------------------------------
-- Internal
------------------------------------------------------------

local DEFAULT_MODEL = `a_c_shepherd`

------------------------------------------------------------
-- Load Model
------------------------------------------------------------

local function LoadModel(model)

    if type(model) == "string" then
        model = joaat(model)
    end

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(0)
    end

    return model

end

------------------------------------------------------------
-- Delete Existing Entity
------------------------------------------------------------

local function DeleteDog()

    local entity = DK9.Engine.GetEntity()

    if entity ~= 0 and DoesEntityExist(entity) then

        DeleteEntity(entity)

    end

    DK9.Engine.SetEntity(0)
    DK9.Engine.SetSpawned(false)

end

------------------------------------------------------------
-- Spawn
------------------------------------------------------------

function Spawn.Create(model)

    if DK9.Engine.IsSpawned() then
        return false
    end

    local handler = PlayerPedId()

    local coords = GetOffsetFromEntityInWorldCoords(
        handler,
        0.0,
        2.0,
        0.0
    )

    model = LoadModel(model or DEFAULT_MODEL)

    local dog = CreatePed(
        28,
        model,
        coords.x,
        coords.y,
        coords.z,
        GetEntityHeading(handler),
        true,
        false
    )

    SetModelAsNoLongerNeeded(model)

    if dog == 0 then

        print("^1[drill_k9]^7 Failed to create K9.")

        return false

    end

    SetEntityAsMissionEntity(dog, true, true)

    SetPedCanRagdoll(dog, true)
    SetPedFleeAttributes(dog, 0, false)
    SetBlockingOfNonTemporaryEvents(dog, true)

    SetPedRelationshipGroupHash(
        dog,
        GetHashKey("PLAYER")
    )

    SetPedKeepTask(dog, true)

    DK9.Engine.SetEntity(dog)
    DK9.Engine.SetSpawned(true)

    DK9.State.Change("FOLLOW")

    DK9.Events.Emit("K9:SPAWNED", {

        entity = dog

    })

    return true

end

------------------------------------------------------------
-- Dismiss
------------------------------------------------------------

function Spawn.Dismiss()

    if not DK9.Engine.IsSpawned() then
        return
    end

    local entity = DK9.Engine.GetEntity()

    DK9.Events.Emit("K9:DISMISSED", {

        entity = entity

    })

    DeleteDog()

    DK9.State.Reset()

end

------------------------------------------------------------
-- Respawn
------------------------------------------------------------

function Spawn.Respawn(model)

    Spawn.Dismiss()

    Wait(500)

    Spawn.Create(model)

end

------------------------------------------------------------
-- Exists
------------------------------------------------------------

function Spawn.Exists()

    local entity = DK9.Engine.GetEntity()

    return entity ~= 0 and DoesEntityExist(entity)

end

------------------------------------------------------------
-- Monitor
------------------------------------------------------------

CreateThread(function()

    while true do

        Wait(1000)

        if DK9.Engine.IsSpawned() then

            if not Spawn.Exists() then

                DK9.Engine.SetSpawned(false)

                DK9.Engine.SetEntity(0)

                DK9.State.Reset()

                DK9.Events.Emit("K9:ENTITY_LOST")

            end

        end

    end

end)

------------------------------------------------------------
-- Commands
------------------------------------------------------------

RegisterCommand("k9spawn", function()

    Spawn.Create()

end)

RegisterCommand("k9dismiss", function()

    Spawn.Dismiss()

end)

------------------------------------------------------------
-- Event Hooks
------------------------------------------------------------

DK9.Events.On("K9:COMMAND", function(data)

    if not data then
        return
    end

    if data.command == "spawn" then

        Spawn.Create()

    elseif data.command == "dismiss" then

        Spawn.Dismiss()

    end

end)