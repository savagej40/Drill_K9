--========================================================--
-- drill_k9
-- File: client/systems/movement.lua
-- Description: K9 posture, heel, and recall behavior
-- Version: 1.0.0-alpha.2
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

local HEEL_STOP_DISTANCE = 1.15
local RECALL_START_DISTANCE = 12.0
local RECALL_FINISH_DISTANCE = 5.0

local WALK_SPEED = 2.0
local RUN_SPEED = 3.75
local SPRINT_SPEED = 6.0

local SPEED_REFRESH_DELAY = 1500

------------------------------------------------------------
-- Internal state
------------------------------------------------------------

local currentTask = 'IDLE'
local currentSpeedMode = 'WALK'
local lastHeelRefresh = 0

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

local function clearPostureTasks()
    if not dogExists() then
        return false
    end

    local dog = getDog()

    SetPedKeepTask(dog, false)
    ClearPedTasksImmediately(dog)
    ClearPedSecondaryTask(dog)

    ResetPedMovementClipset(dog, 0.0)
    ResetPedStrafeClipset(dog)
    ResetPedWeaponMovementClipset(dog)

    Wait(50)

    SetBlockingOfNonTemporaryEvents(dog, true)
    SetPedKeepTask(dog, true)

    return true
end

local function setTask(taskName)
    currentTask = taskName
end

------------------------------------------------------------
-- Public status
------------------------------------------------------------

function Movement.GetCurrentTask()
    return currentTask
end

function Movement.GetHeelSide()
    return HEEL_SIDE
end

------------------------------------------------------------
-- Heel
------------------------------------------------------------

function Movement.Heel(forceRefresh)
    if not dogExists() or not Navigation then
        return false
    end

    local now = GetGameTimer()

    if not forceRefresh
        and currentTask == 'FOLLOW'
        and now - lastHeelRefresh < SPEED_REFRESH_DELAY then

        return true
    end

    local offsetX, offsetY = getHeelOffset()
    local speedMode, movementSpeed = getHandlerSpeedMode()

    clearPostureTasks()

    local started = Navigation.FollowEntity(
        getHandler(),
        offsetX,
        offsetY,
        movementSpeed,
        HEEL_STOP_DISTANCE
    )

    if not started then
        return false
    end

    setTask('FOLLOW')
    currentSpeedMode = speedMode
    lastHeelRefresh = now

    return true
end

------------------------------------------------------------
-- Recall
------------------------------------------------------------

function Movement.Recall(forceRefresh)
    if not dogExists() or not Navigation then
        return false
    end

    if not forceRefresh and currentTask == 'RECALL' then
        return true
    end

    clearPostureTasks()

    local started = Navigation.GoToEntity(
        getHandler(),
        RECALL_FINISH_DISTANCE,
        SPRINT_SPEED
    )

    if not started then
        return false
    end

    setTask('RECALL')

    return true
end

------------------------------------------------------------
-- Follow command
------------------------------------------------------------

function Movement.Follow()
    if not dogExists() then
        return false
    end

    if getDistanceToHandler() > RECALL_START_DISTANCE then
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

    Navigation.Stop()
    clearPostureTasks()

    TaskStandStill(getDog(), -1)
    SetPedKeepTask(getDog(), true)

    setTask('STAY')

    return true
end

------------------------------------------------------------
-- Sit
------------------------------------------------------------

function Movement.Sit()
    if not dogExists() then
        return false
    end

    Navigation.Stop()
    clearPostureTasks()

    TaskStartScenarioInPlace(
        getDog(),
        'WORLD_DOG_SITTING_ROTTWEILER',
        0,
        true
    )

    SetPedKeepTask(getDog(), true)

    setTask('SIT')

    return true
end

------------------------------------------------------------
-- Down
------------------------------------------------------------

function Movement.Down()
    if not dogExists() then
        return false
    end

    Navigation.Stop()
    clearPostureTasks()

    TaskStartScenarioInPlace(
        getDog(),
        'WORLD_DOG_BARKING_ROTTWEILER',
        0,
        true
    )

    SetPedKeepTask(getDog(), true)

    setTask('DOWN')

    return true
end

------------------------------------------------------------
-- Return
------------------------------------------------------------

function Movement.Return()
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

------------------------------------------------------------
-- State events
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
-- Radial commands
------------------------------------------------------------

DK9.Events.On('K9:COMMAND', function(data)
    if not data or not data.command then
        return
    end

    local command = data.command

    if command == 'follow' then
        if DK9.State.Is('FOLLOW') then
            Movement.Follow()
        else
            DK9.State.Change('FOLLOW')
        end
    elseif command == 'stay' then
        DK9.State.Change('STAY')
    elseif command == 'sit' then
        DK9.State.Change('SIT')
    elseif command == 'down' then
        DK9.State.Change('DOWN')
    elseif command == 'return' then
        DK9.State.Change('RETURN')
    elseif command == 'heel_left' then
        Movement.SetHeelSide('LEFT')
    elseif command == 'heel_right' then
        Movement.SetHeelSide('RIGHT')
    end
end)

------------------------------------------------------------
-- Lightweight movement monitor
------------------------------------------------------------

CreateThread(function()
    while true do
        Wait(500)

        if DK9.Engine.IsSpawned()
            and dogExists()
            and DK9.State.Is('FOLLOW') then

            local distance = getDistanceToHandler()

            if distance > RECALL_START_DISTANCE then
                if currentTask ~= 'RECALL' then
                    Movement.Recall(true)
                end
            elseif distance <= RECALL_FINISH_DISTANCE then
                if currentTask ~= 'FOLLOW' then
                    Movement.Heel(true)
                else
                    local speedMode = getHandlerSpeedMode()

                    if speedMode ~= currentSpeedMode
                        and GetGameTimer() - lastHeelRefresh
                            >= SPEED_REFRESH_DELAY then

                        Movement.Heel(true)
                    end
                end
            end
        end
    end
end)

------------------------------------------------------------
-- Cleanup
------------------------------------------------------------

DK9.Events.On('K9:DISMISSED', function()
    currentTask = 'IDLE'
    currentSpeedMode = 'WALK'
    lastHeelRefresh = 0
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
