--========================================================--
-- drill_k9
-- File: client/systems/movement.lua
-- Description: K9 heel, recall, and posture movement
-- Version: 0.4.1
--========================================================--

DK9 = DK9 or {}
DK9.Movement = {}

local Movement = DK9.Movement
local Navigation = DK9.Navigation

------------------------------------------------------------
-- Configuration
------------------------------------------------------------

local HEEL_SIDE = 'LEFT'

local HEEL_LEFT_X = -0.85
local HEEL_RIGHT_X = 0.85
local HEEL_FORWARD_Y = 0.10

local HEEL_DISTANCE = 1.15
local RECALL_START_DISTANCE = 12.0
local RECALL_FINISH_DISTANCE = 5.0

local WALK_SPEED = 2.0
local RUN_SPEED = 3.75
local SPRINT_SPEED = 6.0

local SPEED_UPDATE_COOLDOWN = 1500
local RECALL_REFRESH_INTERVAL = 5000

------------------------------------------------------------
-- Internal state
------------------------------------------------------------

local currentTask = 'IDLE'
local currentSpeedMode = 'WALK'
local lastHeelTaskTime = 0
local lastRecallTaskTime = 0

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function getDog()
    return DK9.Engine.GetEntity()
end

local function getHandler()
    return PlayerPedId()
end

local function dogExists()
    local dog = getDog()

    return dog ~= 0 and DoesEntityExist(dog)
end

local function getDistanceToHandler()
    if not dogExists() then
        return 0.0
    end

    return #(
        GetEntityCoords(getDog()) -
        GetEntityCoords(getHandler())
    )
end

local function getHeelOffset()
    if HEEL_SIDE == 'RIGHT' then
        return HEEL_RIGHT_X, HEEL_FORWARD_Y
    end

    return HEEL_LEFT_X, HEEL_FORWARD_Y
end

local function getHandlerSpeedMode()
    local handler = getHandler()

    if IsPedSprinting(handler) then
        return 'SPRINT', SPRINT_SPEED
    end

    if IsPedRunning(handler) then
        return 'RUN', RUN_SPEED
    end

    return 'WALK', WALK_SPEED
end

local function clearDogTasks()
    if not dogExists() then
        return
    end

    local dog = getDog()

    SetPedKeepTask(dog, false)

    ClearPedTasksImmediately(dog)
    ClearPedSecondaryTask(dog)

    ResetPedMovementClipset(dog, 0.0)
    ResetPedStrafeClipset(dog)
    ResetPedWeaponMovementClipset(dog)

    Wait(75)

    SetBlockingOfNonTemporaryEvents(dog, true)
    SetPedKeepTask(dog, true)
end

------------------------------------------------------------
-- Heel
------------------------------------------------------------

function Movement.Heel(force)

    if not dogExists() then
        return false
    end

    local offsetX, offsetY = getHeelOffset()

    local _, speed = getHandlerSpeedMode()

    clearDogTasks()

    Navigation.FollowEntity(
        getHandler(),
        offsetX,
        offsetY,
        speed,
        FOLLOW_DISTANCE
    )

    currentTask = "FOLLOW"

    currentSpeedMode = getHandlerSpeedMode()

    return true

end

------------------------------------------------------------
-- Recall
------------------------------------------------------------

function Movement.Recall(force)

    if not dogExists() then
        return false
    end

    if not force
        and currentTask == "RECALL" then

        return true

    end

    clearDogTasks()

    Navigation.GoToEntity(
        getHandler(),
        2.0,
        8.0
    )

    currentTask = "RECALL"

    return true

end

------------------------------------------------------------
-- Follow command
------------------------------------------------------------

function Movement.Follow()
    if not dogExists() then
        return false
    end

    local distance = getDistanceToHandler()

    if distance > RECALL_START_DISTANCE then
        return Movement.Recall(true)
    end

    return Movement.Heel(true)
end

------------------------------------------------------------
-- Stay
------------------------------------------------------------

function Movement.Stay()
    if not dogExists() then
        return false
    end

    if Navigation then
        Navigation.Stop()
    end

    clearDogTasks()

    TaskStandStill(getDog(), -1)
    SetPedKeepTask(getDog(), true)

    currentTask = 'STAY'

    return true
end

------------------------------------------------------------
-- Sit
------------------------------------------------------------

function Movement.Sit()
    if not dogExists() then
        return false
    end

    if Navigation then
        Navigation.Stop()
    end

    clearDogTasks()

    TaskStartScenarioInPlace(
        getDog(),
        'WORLD_DOG_SITTING_ROTTWEILER',
        0,
        true
    )

    SetPedKeepTask(getDog(), true)

    currentTask = 'SIT'

    return true
end

------------------------------------------------------------
-- Down
------------------------------------------------------------

function Movement.Down()
    if not dogExists() then
        return false
    end

    if Navigation then
        Navigation.Stop()
    end

    clearDogTasks()

    TaskStartScenarioInPlace(
        getDog(),
        'WORLD_DOG_BARKING_ROTTWEILER',
        0,
        true
    )

    SetPedKeepTask(getDog(), true)

    currentTask = 'DOWN'

    return true
end

------------------------------------------------------------
-- Return
------------------------------------------------------------

function Movement.Return()
    if not dogExists() then
        return false
    end

    return Movement.Recall(true)
end

------------------------------------------------------------
-- Heel side
------------------------------------------------------------

function Movement.SetHeelSide(side)
    side = string.upper(tostring(side or 'LEFT'))

    if side ~= 'LEFT' and side ~= 'RIGHT' then
        return false
    end

    HEEL_SIDE = side

    if DK9.State.Is('FOLLOW') then
        Movement.Follow()
    end

    return true
end

function Movement.GetHeelSide()
    return HEEL_SIDE
end

function Movement.GetCurrentTask()
    return currentTask
end

------------------------------------------------------------
-- State listener
------------------------------------------------------------

DK9.Events.On('K9:STATE_CHANGED', function(data)
    if not data or not data.current then
        return
    end

    if data.current == 'FOLLOW' then
        Movement.Follow()

    elseif data.current == 'STAY' then
        Movement.Stay()

    elseif data.current == 'SIT' then
        Movement.Sit()

    elseif data.current == 'DOWN' then
        Movement.Down()

    elseif data.current == 'RETURN' then
        Movement.Return()
    end
end)

------------------------------------------------------------
-- Command listener
------------------------------------------------------------

DK9.Events.On('K9:COMMAND', function(data)
    if not data or not data.command then
        return
    end

    if data.command == 'follow' then
        if DK9.State.Is('FOLLOW') then
            Movement.Follow()
        else
            DK9.State.Change('FOLLOW')
        end

    elseif data.command == 'stay' then
        DK9.State.Change('STAY')

    elseif data.command == 'sit' then
        DK9.State.Change('SIT')

    elseif data.command == 'down' then
        DK9.State.Change('DOWN')

    elseif data.command == 'return' then
        DK9.State.Change('RETURN')

    elseif data.command == 'heel_left' then
        Movement.SetHeelSide('LEFT')

    elseif data.command == 'heel_right' then
        Movement.SetHeelSide('RIGHT')
    end
end)

------------------------------------------------------------
-- Movement Monitor
------------------------------------------------------------

CreateThread(function()

    while true do

        Wait(500)

        if not DK9.Engine.IsSpawned() then
            goto continue
        end

        if not dogExists() then
            goto continue
        end

        if not DK9.State.Is("FOLLOW") then
            goto continue
        end

        local distance = getDistanceToHandler()

        if currentTask == "RECALL" then

            if distance <= RECALL_FINISH_DISTANCE then

                Movement.Heel(true)

            end

        elseif currentTask == "FOLLOW" then

            local speedMode = getHandlerSpeedMode()

            if speedMode ~= currentSpeedMode then

                Movement.Heel(true)

            end

        end

        ::continue::

    end

end)
------------------------------------------------------------
-- Console testing
------------------------------------------------------------

RegisterCommand('k9heelleft', function()
    Movement.SetHeelSide('LEFT')
end, false)

RegisterCommand('k9heelright', function()
    Movement.SetHeelSide('RIGHT')
end, false)