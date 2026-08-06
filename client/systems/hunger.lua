--========================================================--
-- drill_k9
-- File: client/systems/hunger.lua
-- Description: Food, Water & Energy System
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.Hunger = {}

local Hunger = DK9.Hunger

------------------------------------------------------------
-- Configuration
------------------------------------------------------------

local FOOD_DECAY = 0.20
local WATER_DECAY = 0.35
local ENERGY_DECAY = 0.10

local TICK = 60000 -- 1 minute

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function Clamp(value, min, max)

    if value < min then
        return min
    end

    if value > max then
        return max
    end

    return value

end

local function UpdateStats(stats)

    DK9.Engine.SetStats(stats)

    DK9.Network.UpdateHUD()

    DK9.Events.Emit("K9:STATS_UPDATED", stats)

end

------------------------------------------------------------
-- Feed
------------------------------------------------------------

function Hunger.Feed(amount)

    amount = amount or 25

    local stats = DK9.Engine.GetStats()

    stats.Food = Clamp(stats.Food + amount, 0, 100)

    UpdateStats(stats)

    DK9.Network.Notify(
        "K9",
        "Your K9 has been fed.",
        "success"
    )

end

------------------------------------------------------------
-- Water
------------------------------------------------------------

function Hunger.Water(amount)

    amount = amount or 25

    local stats = DK9.Engine.GetStats()

    stats.Water = Clamp(stats.Water + amount, 0, 100)

    UpdateStats(stats)

    DK9.Network.Notify(
        "K9",
        "Your K9 has been given water.",
        "success"
    )

end

------------------------------------------------------------
-- Rest
------------------------------------------------------------

function Hunger.Rest(amount)

    amount = amount or 20

    local stats = DK9.Engine.GetStats()

    stats.Energy = Clamp(stats.Energy + amount, 0, 100)

    UpdateStats(stats)

end

------------------------------------------------------------
-- Decay
------------------------------------------------------------

local function Tick()

    if not DK9.Engine.IsSpawned() then
        return
    end

    local stats = DK9.Engine.GetStats()

    stats.Food = Clamp(stats.Food - FOOD_DECAY, 0, 100)
    stats.Water = Clamp(stats.Water - WATER_DECAY, 0, 100)
    stats.Energy = Clamp(stats.Energy - ENERGY_DECAY, 0, 100)

    --------------------------------------------------------
    -- Starvation
    --------------------------------------------------------

    if stats.Food <= 0 then

        stats.Health = Clamp(stats.Health - 1, 0, 100)

    end

    --------------------------------------------------------
    -- Dehydration
    --------------------------------------------------------

    if stats.Water <= 0 then

        stats.Health = Clamp(stats.Health - 2, 0, 100)

    end

    --------------------------------------------------------
    -- Exhaustion
    --------------------------------------------------------

    if stats.Energy <= 10 then

        DK9.State.Change("RESTING")

    end

    --------------------------------------------------------
    -- Notifications
    --------------------------------------------------------

    if stats.Food == 25 then

        DK9.Network.Notify(
            "K9",
            "Your K9 is getting hungry.",
            "warning"
        )

    end

    if stats.Water == 25 then

        DK9.Network.Notify(
            "K9",
            "Your K9 needs water.",
            "warning"
        )

    end

    if stats.Health == 25 then

        DK9.Network.Notify(
            "K9",
            "Your K9 is critically injured.",
            "error"
        )

    end

    --------------------------------------------------------
    -- Death
    --------------------------------------------------------

    if stats.Health <= 0 then

        stats.Health = 0

        DK9.State.Change("DEAD")

        DK9.Events.Emit("K9:DEAD")

    end

    UpdateStats(stats)

end

------------------------------------------------------------
-- Events
------------------------------------------------------------

DK9.Events.On("K9:COMMAND", function(data)

    if not data then
        return
    end

    if data.command == "feed" then

        Hunger.Feed()

    elseif data.command == "water" then

        Hunger.Water()

    elseif data.command == "rest" then

        Hunger.Rest()

    end

end)

------------------------------------------------------------
-- Thread
------------------------------------------------------------

CreateThread(function()

    while true do

        Wait(TICK)

        Tick()

    end

end)

------------------------------------------------------------
-- Console Commands
------------------------------------------------------------

RegisterCommand("k9feed", function()

    Hunger.Feed()

end)

RegisterCommand("k9water", function()

    Hunger.Water()

end)

RegisterCommand("k9rest", function()

    Hunger.Rest()

end)