--========================================================--
-- drill_k9
-- File: client/systems/items.lua
-- Description: K9 Equipment & Item System
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.Items = {}

local Items = DK9.Items

------------------------------------------------------------
-- Registered Items
------------------------------------------------------------

local RegisteredItems = {

    ["k9_food"] = {
        label = "K9 Food",
        action = "feed"
    },

    ["k9_water"] = {
        label = "Water",
        action = "water"
    },

    ["k9_treat"] = {
        label = "Treat",
        action = "energy"
    },

    ["k9_medkit"] = {
        label = "Trauma Kit",
        action = "heal"
    },

    ["k9_vest"] = {
        label = "Ballistic Vest",
        action = "armor"
    },

    ["k9_gps"] = {
        label = "GPS Collar",
        action = "gps"
    }

}

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function Exists()

    local entity = DK9.Engine.GetEntity()

    return entity ~= 0 and DoesEntityExist(entity)

end

------------------------------------------------------------
-- Use Item
------------------------------------------------------------

function Items.Use(itemName)

    if not Exists() then
        return false
    end

    local item = RegisteredItems[itemName]

    if not item then
        return false
    end

    if item.action == "feed" then

        DK9.Hunger.Feed(30)

    elseif item.action == "water" then

        DK9.Hunger.Water(30)

    elseif item.action == "energy" then

        DK9.Hunger.Rest(15)

    elseif item.action == "heal" then

        DK9.Health.Heal(35)

    elseif item.action == "armor" then

        DK9.Health.AddArmor(100)

    elseif item.action == "gps" then

        DK9.GPS.Toggle()

    end

    DK9.Events.Emit("K9:ITEM_USED", {

        item = itemName

    })

    DK9.Network.Notify(

        "K9",

        ("%s used."):format(item.label),

        "success"

    )

    return true

end

------------------------------------------------------------
-- Register Custom Item
------------------------------------------------------------

function Items.Register(name, data)

    RegisteredItems[name] = data

end

------------------------------------------------------------
-- Get Registered Items
------------------------------------------------------------

function Items.Get()

    return RegisteredItems

end

------------------------------------------------------------
-- Radial Commands
------------------------------------------------------------

DK9.Events.On("K9:COMMAND", function(data)

    if not data then
        return
    end

    if data.command == "feed" then

        Items.Use("k9_food")

    elseif data.command == "water" then

        Items.Use("k9_water")

    elseif data.command == "heal" then

        Items.Use("k9_medkit")

    elseif data.command == "armor" then

        Items.Use("k9_vest")

    elseif data.command == "gps" then

        Items.Use("k9_gps")

    end

end)

------------------------------------------------------------
-- Console Commands
------------------------------------------------------------

RegisterCommand("k9feed", function()

    Items.Use("k9_food")

end)

RegisterCommand("k9water", function()

    Items.Use("k9_water")

end)

RegisterCommand("k9heal", function()

    Items.Use("k9_medkit")

end)

RegisterCommand("k9armor", function()

    Items.Use("k9_vest")

end)

RegisterCommand("k9gps", function()

    Items.Use("k9_gps")

end)