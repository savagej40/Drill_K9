--========================================================--
-- drill_k9
-- File: client/ai/navigation.lua
-- Description: Central K9 navigation system
-- Version: 0.4.1
--========================================================--

DK9 = DK9 or {}
DK9.Navigation = {}

local Navigation = DK9.Navigation

Navigation.Target = nil
Navigation.Mode = 'NONE'

local function getDog()
    return DK9.Engine.GetEntity()
end

local function dogExists()
    local dog = getDog()
    return dog ~= 0 and DoesEntityExist(dog)
end

local function validEntity(entity)
    return entity ~= nil and entity ~= 0 and DoesEntityExist(entity)
end

local function prepareDog()
    if not dogExists() then
        return false
    end

    local dog = getDog()
    SetBlockingOfNonTemporaryEvents(dog, true)
    SetPedKeepTask(dog, true)
    return true
end

function Navigation.Stop(clearTasks)
    if dogExists() and clearTasks ~= false then
        ClearPedTasks(getDog())
        ClearPedSecondaryTask(getDog())
    end

    Navigation.Target = nil
    Navigation.Mode = 'NONE'
end

function Navigation.FollowEntity(entity, offsetX, offsetY, speed, stopDistance)
    if not dogExists() or not validEntity(entity) then
        return false
    end

    Navigation.Stop(false)

    offsetX = tonumber(offsetX) or -0.85
    offsetY = tonumber(offsetY) or 0.10
    speed = tonumber(speed) or 3.5
    stopDistance = tonumber(stopDistance) or 1.0

    Navigation.Mode = 'FOLLOW'
    Navigation.Target = entity

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

    prepareDog()
    return true
end

function Navigation.GoToEntity(entity, stopDistance, speed)
    if not dogExists() or not validEntity(entity) then
        return false
    end

    Navigation.Stop(false)

    stopDistance = tonumber(stopDistance) or 2.0
    speed = tonumber(speed) or 6.0

    Navigation.Mode = 'RECALL'
    Navigation.Target = entity

    TaskGoToEntity(
        getDog(),
        entity,
        -1,
        stopDistance,
        speed,
        0.0,
        0
    )

    prepareDog()
    return true
end

function Navigation.GoToCoords(coords, speed, stoppingRange)
    if not dogExists() or type(coords) ~= 'vector3' then
        return false
    end

    Navigation.Stop(false)

    speed = tonumber(speed) or 4.0
    stoppingRange = tonumber(stoppingRange) or 1.0

    Navigation.Mode = 'COORDS'
    Navigation.Target = coords

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

    prepareDog()
    return true
end

function Navigation.GoToCoordsAnyMeans(coords, speed, stoppingRange)
    if not dogExists() or type(coords) ~= 'vector3' then
        return false
    end

    Navigation.Stop(false)

    speed = tonumber(speed) or 4.0
    stoppingRange = tonumber(stoppingRange) or 1.0

    Navigation.Mode = 'COORDS'
    Navigation.Target = coords

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

    prepareDog()
    return true
end

function Navigation.GetMode()
    return Navigation.Mode
end

function Navigation.GetTarget()
    return Navigation.Target
end

function Navigation.IsBusy()
    return Navigation.Mode ~= 'NONE'
end