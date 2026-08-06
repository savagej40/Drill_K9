--========================================================--
-- drill_k9
-- File: client/systems/search.lua
-- Description: K9 Search System
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.Search = {}

local Search = DK9.Search

------------------------------------------------------------
-- Configuration
------------------------------------------------------------

local SEARCH_TIME = 5000

local PlayerContraband = {
    "Illegal Narcotics",
    "Handgun",
    "Large Amount of Cash",
    "Stolen Property",
    "Lock Picks",
    "Fake Identification",
    "Brass Knuckles",
    "Explosives",
    "Nothing"
}

local VehicleContraband = {
    "Illegal Narcotics",
    "Assault Rifle",
    "Explosives",
    "Body Armor",
    "Cash",
    "Stolen Firearm",
    "Nothing"
}

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

local function RandomItem(tbl)

    return tbl[math.random(#tbl)]

end

------------------------------------------------------------
-- Search Player
------------------------------------------------------------

function Search.Player(target)

    if not Exists() then
        return
    end

    if not target or target == 0 then
        return
    end

    DK9.State.Change("SEARCH_PLAYER")

    TaskGoToEntity(
        Dog(),
        target,
        -1,
        1.5,
        2.0,
        0,
        0
    )

    Wait(SEARCH_TIME)

    local item = RandomItem(PlayerContraband)

    DK9.Network.Notify(
        "K9 Search",
        ("Player Search Complete\nResult: %s"):format(item),
        item == "Nothing" and "info" or "success"
    )

    DK9.Events.Emit("K9:PLAYER_SEARCH_COMPLETE", {
        target = target,
        result = item
    })

    DK9.State.Change("FOLLOW")

end

------------------------------------------------------------
-- Search Vehicle
------------------------------------------------------------

function Search.Vehicle(vehicle)

    if not Exists() then
        return
    end

    if not vehicle or vehicle == 0 then
        return
    end

    local coords = GetEntityCoords(vehicle)

    DK9.State.Change("SEARCH_VEHICLE")

    TaskGoStraightToCoord(
        Dog(),
        coords.x,
        coords.y,
        coords.z,
        2.0,
        -1,
        0.0,
        0.0
    )

    Wait(SEARCH_TIME)

    local item = RandomItem(VehicleContraband)

    DK9.Network.Notify(
        "K9 Search",
        ("Vehicle Search Complete\nResult: %s"):format(item),
        item == "Nothing" and "info" or "success"
    )

    DK9.Events.Emit("K9:VEHICLE_SEARCH_COMPLETE", {
        vehicle = vehicle,
        result = item
    })

    DK9.State.Change("FOLLOW")

end

------------------------------------------------------------
-- Area Search
------------------------------------------------------------

function Search.Area(coords)

    if not Exists() then
        return
    end

    DK9.State.Change("SEARCH_AREA")

    TaskGoStraightToCoord(
        Dog(),
        coords.x,
        coords.y,
        coords.z,
        2.0,
        -1,
        0.0,
        0.0
    )

    Wait(SEARCH_TIME)

    local found = math.random(1,100) <= 35

    if found then

        DK9.Network.Notify(
            "K9 Search",
            "Evidence located.",
            "success"
        )

    else

        DK9.Network.Notify(
            "K9 Search",
            "Nothing located.",
            "info"
        )

    end

    DK9.Events.Emit("K9:AREA_SEARCH_COMPLETE", {
        found = found,
        coords = coords
    })

    DK9.State.Change("FOLLOW")

end

------------------------------------------------------------
-- Crosshair Detection
------------------------------------------------------------

function Search.GetTarget()

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

    if data.command == "search_player" then

        local target = Search.GetTarget()

        if target and IsEntityAPed(target) then

            Search.Player(target)

        else

            DK9.Network.Notify(
                "K9",
                "Aim at a player.",
                "warning"
            )

        end

    elseif data.command == "search_vehicle" then

        local target = Search.GetTarget()

        if target and IsEntityAVehicle(target) then

            Search.Vehicle(target)

        else

            DK9.Network.Notify(
                "K9",
                "Aim at a vehicle.",
                "warning"
            )

        end

    elseif data.command == "search_area" then

        Search.Area(GetEntityCoords(PlayerPedId()))

    end

end)

------------------------------------------------------------
-- Console Commands
------------------------------------------------------------

RegisterCommand("k9searchplayer", function()

    local target = Search.GetTarget()

    if target then
        Search.Player(target)
    end

end)

RegisterCommand("k9searchvehicle", function()

    local target = Search.GetTarget()

    if target then
        Search.Vehicle(target)
    end

end)

RegisterCommand("k9searcharea", function()

    Search.Area(GetEntityCoords(PlayerPedId()))

end)