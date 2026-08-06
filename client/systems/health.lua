--========================================================--
-- drill_k9
-- File: client/systems/health.lua
-- Description: K9 Health System
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.Health = {}

local Health = DK9.Health

------------------------------------------------------------
-- Configuration
------------------------------------------------------------

local DAMAGE_INTERVAL = 250

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

local function Clamp(value)

    if value < 0 then
        return 0
    end

    if value > 100 then
        return 100
    end

    return value

end

------------------------------------------------------------
-- Sync
------------------------------------------------------------

local function Sync()

    DK9.Network.UpdateHUD()

    DK9.Events.Emit("K9:HEALTH_UPDATED", DK9.Engine.GetStats())

end

------------------------------------------------------------
-- Damage
------------------------------------------------------------

function Health.Damage(amount)

    if not Exists() then
        return
    end

    amount = math.abs(amount)

    local stats = DK9.Engine.GetStats()

    --------------------------------------------------------
    -- Armor
    --------------------------------------------------------

    if stats.Armor > 0 then

        local absorbed = math.min(stats.Armor, amount)

        stats.Armor = stats.Armor - absorbed

        amount = amount - absorbed

    end

    --------------------------------------------------------
    -- Health
    --------------------------------------------------------

    if amount > 0 then

        stats.Health = Clamp(stats.Health - amount)

    end

    DK9.Engine.SetStats(stats)

    if stats.Health <= 25 then

        DK9.State.Change("INJURED")

    end

    if stats.Health <= 0 then

        stats.Health = 0

        DK9.Engine.SetStats(stats)

        DK9.State.Change("DEAD")

        DK9.Events.Emit("K9:DEAD")

    end

    Sync()

end

------------------------------------------------------------
-- Heal
------------------------------------------------------------

function Health.Heal(amount)

    local stats = DK9.Engine.GetStats()

    stats.Health = Clamp(stats.Health + math.abs(amount))

    DK9.Engine.SetStats(stats)

    if stats.Health > 25 then

        DK9.State.Change("FOLLOW")

    end

    Sync()

end

------------------------------------------------------------
-- Armor
------------------------------------------------------------

function Health.AddArmor(amount)

    local stats = DK9.Engine.GetStats()

    stats.Armor = Clamp(stats.Armor + amount)

    DK9.Engine.SetStats(stats)

    Sync()

end

------------------------------------------------------------
-- Full Restore
------------------------------------------------------------

function Health.Restore()

    local stats = DK9.Engine.GetStats()

    stats.Health = 100
    stats.Armor = 100
    stats.Food = 100
    stats.Water = 100
    stats.Energy = 100

    DK9.Engine.SetStats(stats)

    DK9.State.Change("FOLLOW")

    Sync()

end

------------------------------------------------------------
-- Revive
------------------------------------------------------------

function Health.Revive()

    if not Exists() then
        return
    end

    local stats = DK9.Engine.GetStats()

    stats.Health = 50

    DK9.Engine.SetStats(stats)

    ResurrectPed(Dog())

    ClearPedTasksImmediately(Dog())

    DK9.State.Change("FOLLOW")

    DK9.Events.Emit("K9:REVIVED")

    Sync()

end

------------------------------------------------------------
-- Monitor
------------------------------------------------------------

CreateThread(function()

    local previousHealth = 100

    while true do

        Wait(DAMAGE_INTERVAL)

        if DK9.Engine.IsSpawned() and Exists() then

            local current = GetEntityHealth(Dog())

            if previousHealth == 100 then
                previousHealth = current
            end

            if current < previousHealth then

                local damage = previousHealth - current

                Health.Damage(damage)

            end

            previousHealth = GetEntityHealth(Dog())

        else

            previousHealth = 100

        end

    end

end)

------------------------------------------------------------
-- Events
------------------------------------------------------------

DK9.Events.On("K9:COMMAND", function(data)

    if not data then
        return
    end

    if data.command == "heal" then

        Health.Heal(25)

    elseif data.command == "armor" then

        Health.AddArmor(25)

    elseif data.command == "revive" then

        Health.Revive()

    end

end)

------------------------------------------------------------
-- Console Commands
------------------------------------------------------------

RegisterCommand("k9heal", function()

    Health.Heal(25)

end)

RegisterCommand("k9armor", function()

    Health.AddArmor(25)

end)

RegisterCommand("k9revive", function()

    Health.Revive()

end)

RegisterCommand("k9restore", function()

    Health.Restore()

end)