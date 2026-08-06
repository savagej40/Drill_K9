--========================================================--
-- drill_k9
-- File: client/systems/animations.lua
-- Description: K9 Animation System
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.Animation = {}

local Animation = DK9.Animation

------------------------------------------------------------
-- Internal
------------------------------------------------------------

local currentAnimation = nil

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

local function Clear()

    if Exists() then
        ClearPedTasks(Dog())
    end

    currentAnimation = nil

end

------------------------------------------------------------
-- Idle
------------------------------------------------------------

function Animation.Idle()

    if not Exists() then
        return
    end

    Clear()

    TaskStandStill(Dog(), -1)

    currentAnimation = "IDLE"

end

------------------------------------------------------------
-- Sit
------------------------------------------------------------

function Animation.Sit()

    if not Exists() then
        return
    end

    Clear()

    TaskStartScenarioInPlace(
        Dog(),
        "WORLD_DOG_SITTING_ROTTWEILER",
        0,
        true
    )

    currentAnimation = "SIT"

end

------------------------------------------------------------
-- Down
------------------------------------------------------------

function Animation.Down()

    if not Exists() then
        return
    end

    Clear()

    TaskStartScenarioInPlace(
        Dog(),
        "WORLD_DOG_BARKING_ROTTWEILER",
        0,
        true
    )

    currentAnimation = "DOWN"

end

------------------------------------------------------------
-- Bark
------------------------------------------------------------

function Animation.Bark()

    if not Exists() then
        return
    end

    Clear()

    TaskStartScenarioInPlace(
        Dog(),
        "WORLD_DOG_BARKING_ROTTWEILER",
        0,
        true
    )

    currentAnimation = "BARK"

end

------------------------------------------------------------
-- Follow
------------------------------------------------------------

function Animation.Follow()

    currentAnimation = "FOLLOW"

end

------------------------------------------------------------
-- Search
------------------------------------------------------------

function Animation.Search()

    currentAnimation = "SEARCH"

end

------------------------------------------------------------
-- Attack
------------------------------------------------------------

function Animation.Attack()

    currentAnimation = "ATTACK"

end

------------------------------------------------------------
-- Vehicle
------------------------------------------------------------

function Animation.Vehicle()

    currentAnimation = "VEHICLE"

end

------------------------------------------------------------
-- Rest
------------------------------------------------------------

function Animation.Rest()

    if not Exists() then
        return
    end

    Clear()

    TaskStartScenarioInPlace(
        Dog(),
        "WORLD_DOG_SITTING_ROTTWEILER",
        0,
        true
    )

    currentAnimation = "REST"

end

------------------------------------------------------------
-- Injured
------------------------------------------------------------

function Animation.Injured()

    if not Exists() then
        return
    end

    Clear()

    SetPedToRagdoll(
        Dog(),
        3000,
        3000,
        0,
        false,
        false,
        false
    )

    currentAnimation = "INJURED"

end

------------------------------------------------------------
-- Death
------------------------------------------------------------

function Animation.Death()

    if not Exists() then
        return
    end

    SetEntityHealth(Dog(), 0)

    currentAnimation = "DEAD"

end

------------------------------------------------------------
-- State Listener
------------------------------------------------------------

DK9.Events.On("K9:STATE_CHANGED", function(data)

    if not data then
        return
    end

    local state = data.current

    if state == "IDLE" then

        Animation.Idle()

    elseif state == "FOLLOW" then

        Animation.Follow()

    elseif state == "SIT" then

        Animation.Sit()

    elseif state == "DOWN" then

        Animation.Down()

    elseif state == "SEARCH_PLAYER"
        or state == "SEARCH_VEHICLE"
        or state == "SEARCH_AREA" then

        Animation.Search()

    elseif state == "APPREHEND" then

        Animation.Attack()

    elseif state == "ENTER_VEHICLE"
        or state == "IN_VEHICLE" then

        Animation.Vehicle()

    elseif state == "RESTING" then

        Animation.Rest()

    elseif state == "INJURED" then

        Animation.Injured()

    elseif state == "DEAD" then

        Animation.Death()

    end

end)

------------------------------------------------------------
-- Event Listeners
------------------------------------------------------------

DK9.Events.On("K9:ATTACK_START", function()

    Animation.Attack()

end)

DK9.Events.On("K9:TRACK_STARTED", function()

    Animation.Search()

end)

DK9.Events.On("K9:SPAWNED", function()

    Animation.Idle()

end)

DK9.Events.On("K9:DISMISSED", function()

    Clear()

end)