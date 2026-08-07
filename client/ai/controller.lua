--========================================================--
-- drill_k9
-- File: client/ai/controller.lua
-- Description: Central K9 AI state observer
-- Version: 1.0.0-alpha.1
--========================================================--

DK9 = DK9 or {}
DK9.AI = DK9.AI or {}

local AI = DK9.AI

local UPDATE_RATE = 500
local state = 'IDLE'

------------------------------------------------------------
-- State
------------------------------------------------------------

function AI.SetState(newState)
    if state == newState then
        return false
    end

    state = newState

    if Config.Debug then
        print(('[drill_k9] AI state -> %s'):format(newState))
    end

    DK9.Events.Emit('K9:AI_STATE_CHANGED', {
        current = newState
    })

    return true
end

function AI.GetState()
    return state
end

------------------------------------------------------------
-- Main observer loop
--
-- movement.lua owns movement decisions and tasks.
-- This controller reports the active high-level behavior only.
------------------------------------------------------------

CreateThread(function()
    while true do
        Wait(UPDATE_RATE)

        if not DK9.Engine.IsSpawned() then
            AI.SetState('IDLE')
            goto continue
        end

        local dog = DK9.Engine.GetEntity()

        if dog == 0 or not DoesEntityExist(dog) then
            AI.SetState('IDLE')
            goto continue
        end

        if IsPedDeadOrDying(dog, true) then
            AI.SetState('DEAD')
            goto continue
        end

        if IsPedInAnyVehicle(dog, false) then
            AI.SetState('VEHICLE')
            goto continue
        end

        local movementTask = DK9.Movement
            and DK9.Movement.GetCurrentTask()
            or 'IDLE'

        if movementTask == 'RECALL' then
            AI.SetState('RECALL')

        elseif movementTask == 'FOLLOW' then
            AI.SetState('HEEL')

        elseif movementTask == 'SIT' then
            AI.SetState('SIT')

        elseif movementTask == 'STAY' then
            AI.SetState('STAY')

        elseif movementTask == 'DOWN' then
            AI.SetState('DOWN')

        else
            AI.SetState('IDLE')
        end

        ::continue::
    end
end)

------------------------------------------------------------
-- Cleanup
------------------------------------------------------------

DK9.Events.On('K9:DISMISSED', function()
    AI.SetState('IDLE')
end)
