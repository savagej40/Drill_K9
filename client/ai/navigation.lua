--========================================================--
-- drill_k9
-- File: client/ai/navigation.lua
-- Description: Central K9 navigation task layer
-- Version: 1.0.0-alpha.1
--========================================================--

DK9 = DK9 or {}
DK9.Navigation = {}

local Navigation = DK9.Navigation

local mode = 'NONE'
local target = nil

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function getDog()
    if not DK9.Engine then
        return 0
    end

    return DK9.Engine.GetEntity()
end

local function dogExists()
    local dog = getDog()

    return dog ~= 0 and DoesEntityExist(dog)
end

local function entityExists(entity)
    return entity ~= nil
        and entity ~= 0
        and DoesEntityExist(entity)
end

local function preserveTask()
    if not dogExists() then
        return false
    end

    local dog = getDog()

    SetBlockingOfNonTemporaryEvents(dog, true)
    SetPedKeepTask(dog, true)

    return true
end

local function setNavigation(newMode, newTarget)
    mode = newMode
    target = newTarget
end

------------------------------------------------------------
-- Public status
------------------------------------------------------------

function Navigation.GetMode()
    return mode
end

function Navigation.GetTarget()
    return target
end

function Navigation.IsBusy()
    return mode ~= 'NONE'
end

------------------------------------------------------------
-- Stop
------------------------------------------------------------

function Navigation.Stop(clearTasks)
    if dogExists() and clearTasks ~= false then
        local dog = getDog()

        ClearPedTasks(dog)
        ClearPedSecondaryTask(dog)
    end

    setNavigation('NONE', nil)
end

------------------------------------------------------------
-- Follow an entity at an offset
------------------------------------------------------------

function Navigation.FollowEntity(
    entity,
    offsetX,
    offsetY,
    speed,
    stopDistance
)
    if not dogExists() or not entityExists(entity) then
        return false
    end

    offsetX = tonumber(offsetX) or -0.85
    offsetY = tonumber(offsetY) or 0.10
    speed = tonumber(speed) or 3.5
    stopDistance = tonumber(stopDistance) or 1.15

    setNavigation('FOLLOW', entity)

    TaskFollowToOffsetOfEntity(
        getDog(),
        entity,
        offsetX,
        offsetY,
        0.0,
        speed,
        -1,
        stopDistance,
        true
    )

    preserveTask()

    return true
end

------------------------------------------------------------
-- Move toward an entity
------------------------------------------------------------

function Navigation.GoToEntity(
    entity,
    stopDistance,
    speed
)
    if not dogExists() or not entityExists(entity) then
        return false
    end

    stopDistance = tonumber(stopDistance) or 2.0
    speed = tonumber(speed) or 6.0

    setNavigation('ENTITY', entity)

    TaskGoToEntity(
        getDog(),
        entity,
        -1,
        stopDistance,
        speed,
        0.0,
        0
    )

    preserveTask()

    return true
end

------------------------------------------------------------
-- Move directly to coordinates
------------------------------------------------------------

function Navigation.GoToCoords(
    coords,
    speed,
    stoppingRange
)
    if not dogExists() or type(coords) ~= 'vector3' then
        return false
    end

    speed = tonumber(speed) or 4.0
    stoppingRange = tonumber(stoppingRange) or 1.0

    setNavigation('COORDS', coords)

    TaskGoStraightToCoord(
        getDog(),
        coords.x,
        coords.y,
        coords.z,
        speed,
        -1,
        0.0,
        stoppingRange
    )

    preserveTask()

    return true
end

------------------------------------------------------------
-- Move to coordinates using the navmesh
------------------------------------------------------------

function Navigation.GoToCoordsAnyMeans(
    coords,
    speed,
    stoppingRange
)
    if not dogExists() or type(coords) ~= 'vector3' then
        return false
    end

    speed = tonumber(speed) or 4.0
    stoppingRange = tonumber(stoppingRange) or 1.0

    setNavigation('NAVMESH', coords)

    TaskGoToCoordAnyMeans(
        getDog(),
        coords.x,
        coords.y,
        coords.z,
        speed,
        0,
        false,
        786603,
        stoppingRange
    )

    preserveTask()

    return true
end

------------------------------------------------------------
-- Cleanup
------------------------------------------------------------

DK9.Events.On('K9:DISMISSED', function()
    Navigation.Stop(false)
end)

DK9.Events.On('K9:ENTITY_LOST', function()
    Navigation.Stop(false)
end)
