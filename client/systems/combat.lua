--========================================================--
-- drill_k9
-- File: client/systems/combat.lua
-- Description: K9 Combat & Apprehension System
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.Combat = {}

local Combat = DK9.Combat

------------------------------------------------------------
-- Internal
------------------------------------------------------------

local currentTarget = nil
local attacking = false

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
-- Clear
------------------------------------------------------------

function Combat.Clear()

    currentTarget = nil
    attacking = false

    if Exists() then
        ClearPedTasks(Dog())
    end

end

------------------------------------------------------------
-- Attack Ped
------------------------------------------------------------

function Combat.Attack(target)

    if not Exists() then
        return false
    end

    if not target or target == 0 then
        return false
    end

    if not DoesEntityExist(target) then
        return false
    end

    currentTarget = target
    attacking = true

    ClearPedTasksImmediately(Dog())

    TaskCombatPed(
        Dog(),
        target,
        0,
        16
    )

    DK9.State.Change("APPREHEND")

    DK9.Events.Emit("K9:ATTACK_START", {
        target = target
    })

    return true

end

------------------------------------------------------------
-- Stop Attack
------------------------------------------------------------

function Combat.Stop()

    if not attacking then
        return
    end

    Combat.Clear()

    DK9.State.Change("FOLLOW")

    DK9.Events.Emit("K9:ATTACK_STOP")

end

------------------------------------------------------------
-- Target Under Crosshair
------------------------------------------------------------

function Combat.GetCrosshairTarget()

    local player = PlayerId()

    local _, entity = GetEntityPlayerIsFreeAimingAt(player)

    if entity ~= 0 then

        if IsEntityAPed(entity) then

            return entity

        end

    end

    return nil

end

------------------------------------------------------------
-- E Key Attack
------------------------------------------------------------

CreateThread(function()

    while true do

        Wait(0)

        if DK9.Engine.IsSpawned() then

            if IsPlayerFreeAiming(PlayerId()) then

                if IsControlJustPressed(0, 38) then -- E

                    local target = Combat.GetCrosshairTarget()

                    if target then

                        Combat.Attack(target)

                    end

                end

            end

        end

    end

end)

------------------------------------------------------------
-- Monitor
------------------------------------------------------------

CreateThread(function()

    while true do

        Wait(500)

        if attacking then

            if not Exists() then

                Combat.Clear()

                goto continue

            end

            if not currentTarget then

                Combat.Stop()

                goto continue

            end

            if not DoesEntityExist(currentTarget) then

                Combat.Stop()

                goto continue

            end

            if IsEntityDead(currentTarget) then

                Combat.Stop()

            end

        end

        ::continue::

    end

end)

------------------------------------------------------------
-- Events
------------------------------------------------------------

DK9.Events.On("K9:COMMAND", function(data)

    if not data then
        return
    end

    if data.command == "apprehend" then

        local target = Combat.GetCrosshairTarget()

        if target then

            Combat.Attack(target)

        else

            DK9.Network.Notify(
                "K9",
                "Aim at a player before issuing Apprehend.",
                "warning"
            )

        end

    elseif data.command == "cancel_attack" then

        Combat.Stop()

    end

end)