--========================================================--
-- drill_k9
-- File: client/ai/controller.lua
-- Description: Central K9 AI Controller
--========================================================--

DK9 = DK9 or {}
DK9.AI = DK9.AI or {}

local AI = DK9.AI

------------------------------------------------------------
-- AI States
------------------------------------------------------------

AI.State = "IDLE"

AI.LastUpdate = 0

AI.UpdateRate = 250

------------------------------------------------------------
-- Change AI State
------------------------------------------------------------

function AI.SetState(state)

    if AI.State == state then
        return
    end

    AI.State = state

    if Config.Debug then
        print(("[AI] State -> %s"):format(state))
    end

end

------------------------------------------------------------
-- Get AI State
------------------------------------------------------------

function AI.GetState()

    return AI.State

end

------------------------------------------------------------
-- Main Think Loop
------------------------------------------------------------

CreateThread(function()

    while true do

        Wait(AI.UpdateRate)

        if not DK9.Engine.IsSpawned() then

            AI.SetState("IDLE")

            goto continue

        end

        local dog = DK9.Engine.GetEntity()

        if dog == 0 then
            goto continue
        end

        local handler = PlayerPedId()

        local dogCoords = GetEntityCoords(dog)

        local handlerCoords = GetEntityCoords(handler)

        local distance = #(dogCoords-handlerCoords)

        ----------------------------------------------------
        -- Vehicle
        ----------------------------------------------------

        if IsPedInAnyVehicle(dog,false) then

            AI.SetState("VEHICLE")

            goto continue

        end

        ----------------------------------------------------
        -- Follow AI
        ----------------------------------------------------

        if DK9.State.Is("FOLLOW") then

            if distance > 12.0 then

                AI.SetState("RECALL")

                if DK9.Movement.GetCurrentTask() ~= "RECALL" then
                     DK9.Movement.Recall(true)
                end

            elseif distance <= 5.0 then

                AI.SetState("HEEL")

                if DK9.Movement.GetCurrentTask() ~= "FOLLOW" then
                    DK9.Movement.Heel(true)
                end

            end

            goto continue

        end
        ----------------------------------------------------
        -- Idle
        ----------------------------------------------------

        AI.SetState("IDLE")

        ::continue::

    end

end)