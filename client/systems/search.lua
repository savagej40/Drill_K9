--========================================================--
-- drill_k9
-- File: client/systems/search.lua
-- Description: K9 search behaviors
-- Version: 1.0.0-alpha.3
--========================================================--

DK9 = DK9 or {}
DK9.Search = {}

local Search = DK9.Search

local SEARCH_DISTANCE = 2.0
local TARGET_MAX_DISTANCE = 8.0
local SEARCH_DURATION = 3500
local ALERT_DURATION = 2500

local activeSearch = false

local function getDog()
    return DK9.Engine.GetEntity()
end

local function dogExists()
    local dog = getDog()
    return dog ~= 0 and DoesEntityExist(dog)
end

local function notify(message, notificationType)
    if DK9.Network and DK9.Network.Notify then
        DK9.Network.Notify('K9 Search', message, notificationType or 'info')
    end
end

local function yesNo(value)
    return value == true and 'YES' or 'NO'
end

local function getAimedEntity()
    local aiming, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())

    if aiming and entity ~= 0 and DoesEntityExist(entity) then
        return entity
    end

    return 0
end

local function getClosestPlayerPed(maxDistance)
    local handler = PlayerPedId()
    local handlerCoords = GetEntityCoords(handler)
    local closestPed = 0
    local closestDistance = maxDistance or TARGET_MAX_DISTANCE

    for _, player in ipairs(GetActivePlayers()) do
        if player ~= PlayerId() then
            local ped = GetPlayerPed(player)

            if ped ~= 0 and DoesEntityExist(ped) then
                local distance = #(handlerCoords - GetEntityCoords(ped))

                if distance <= closestDistance then
                    closestPed = ped
                    closestDistance = distance
                end
            end
        end
    end

    return closestPed
end

local function getSearchTarget()
    local aimed = getAimedEntity()

    if aimed ~= 0 and IsPedAPlayer(aimed) then
        return aimed
    end

    return getClosestPlayerPed(TARGET_MAX_DISTANCE)
end

local function getPlayerServerIdFromPed(ped)
    if not IsPedAPlayer(ped) then
        return nil
    end

    local playerIndex = NetworkGetPlayerIndexFromPed(ped)

    if playerIndex == -1 then
        return nil
    end

    return GetPlayerServerId(playerIndex)
end

local function waitUntilNear(entity, timeout)
    local startedAt = GetGameTimer()

    while dogExists() and DoesEntityExist(entity) do
        local distance = #(
            GetEntityCoords(getDog()) -
            GetEntityCoords(entity)
        )

        if distance <= SEARCH_DISTANCE then
            return true
        end

        if GetGameTimer() - startedAt >= timeout then
            return false
        end

        Wait(100)
    end

    return false
end

local function formatSearchResult(result)
    local report = type(result.report) == 'table' and result.report or {}
    local targetName = result.targetName or 'Player'
    local other = tostring(report.other or '')

    if other:match('^%s*$') then
        other = 'None reported'
    end

    return table.concat({
        ('Player: %s'):format(targetName),
        ('Weapons: %s'):format(yesNo(report.weapons)),
        ('Drugs: %s'):format(yesNo(report.drugs)),
        ('Explosives: %s'):format(yesNo(report.explosives)),
        ('Large Cash: %s'):format(yesNo(report.largeCash)),
        ('Evidence: %s'):format(yesNo(report.evidence)),
        ('Other Property: %s'):format(other)
    }, '\n')
end

local function performAlert()
    if not dogExists() then
        DK9.State.Change('FOLLOW')
        return
    end

    ClearPedTasksImmediately(getDog())

    TaskStartScenarioInPlace(
        getDog(),
        'WORLD_DOG_BARKING_ROTTWEILER',
        0,
        true
    )

    SetPedKeepTask(getDog(), true)
    notify('K9 ALERT\nThe K9 alerted on the subject.', 'error')

    CreateThread(function()
        Wait(ALERT_DURATION)

        if dogExists() then
            ClearPedTasks(getDog())
        end

        DK9.State.Change('FOLLOW')
    end)
end

function Search.Player(targetPed)
    if activeSearch or not dogExists() then
        return false
    end

    if not targetPed or targetPed == 0 or not IsPedAPlayer(targetPed) then
        notify('No player is close enough to search.', 'error')
        return false
    end

    local handlerDistance = #(
        GetEntityCoords(PlayerPedId()) -
        GetEntityCoords(targetPed)
    )

    if handlerDistance > TARGET_MAX_DISTANCE then
        notify('That player is too far away.', 'error')
        return false
    end

    local targetServerId = getPlayerServerIdFromPed(targetPed)

    if not targetServerId then
        notify('Unable to identify that player.', 'error')
        return false
    end

    activeSearch = true
    DK9.State.Change('SEARCH_PLAYER')

    if DK9.Navigation then
        DK9.Navigation.GoToEntity(targetPed, SEARCH_DISTANCE, 3.0)
    else
        TaskGoToEntity(
            getDog(),
            targetPed,
            -1,
            SEARCH_DISTANCE,
            3.0,
            0.0,
            0
        )
    end

    CreateThread(function()
        local reached = waitUntilNear(targetPed, 10000)

        if not reached then
            activeSearch = false
            DK9.State.Change('FOLLOW')
            notify('The K9 could not reach the player.', 'error')
            return
        end

        TaskTurnPedToFaceEntity(getDog(), targetPed, 750)
        Wait(750)
        TaskStandStill(getDog(), SEARCH_DURATION)

        notify('K9 is searching the player...', 'info')
        Wait(SEARCH_DURATION)

        TriggerServerEvent(
            'drill_k9:server:startPersonSearch',
            targetServerId
        )
    end)

    return true
end

RegisterNetEvent('drill_k9:client:personSearchResult', function(result)
    activeSearch = false
    result = type(result) == 'table' and result or {}

    notify(formatSearchResult(result), result.alert and 'error' or 'success')

    DK9.Events.Emit('K9:PLAYER_SEARCH_COMPLETE', result)

    if result.alert == true then
        performAlert()
    else
        DK9.State.Change('FOLLOW')
    end
end)

RegisterNetEvent('drill_k9:client:personSearchCancelled', function(message)
    activeSearch = false
    notify(message or 'The person search was cancelled.', 'error')
    DK9.State.Change('FOLLOW')
end)

DK9.Events.On('K9:COMMAND', function(data)
    if not data or not data.command then
        return
    end

    if data.command == 'search_player' then
        Search.Player(getSearchTarget())
    end
end)

DK9.Events.On('K9:DISMISSED', function()
    activeSearch = false
end)

RegisterCommand('k9searchplayer', function()
    Search.Player(getSearchTarget())
end, false)
