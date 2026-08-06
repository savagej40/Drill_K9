--========================================================--
-- drill_k9
-- File: client/systems/search.lua
-- Description: K9 search behaviors
-- Version: 1.0.0-alpha.1
--========================================================--

DK9 = DK9 or {}
DK9.Search = {}

local Search = DK9.Search

local SEARCH_DISTANCE = 2.0
local TARGET_MAX_DISTANCE = 8.0
local SEARCH_DURATION = 3500

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

local function getAimedEntity()
    local aiming, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())

    if aiming and entity ~= 0 and DoesEntityExist(entity) then
        return entity
    end

    return 0
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

function Search.Player(targetPed)
    if activeSearch or not dogExists() then
        return false
    end

    if not targetPed or targetPed == 0 or not IsPedAPlayer(targetPed) then
        notify('Aim at a player before selecting Person Search.', 'error')
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

    local inventory = type(result) == 'table' and result.inventory or ''
    local targetName = type(result) == 'table' and result.targetName or 'Player'

    notify(
        ('%s reported:\n%s'):format(targetName, inventory),
        'success'
    )

    DK9.Events.Emit('K9:PLAYER_SEARCH_COMPLETE', result or {})
    DK9.State.Change('FOLLOW')
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
        Search.Player(getAimedEntity())
    end
end)

DK9.Events.On('K9:DISMISSED', function()
    activeSearch = false
end)

RegisterCommand('k9searchplayer', function()
    Search.Player(getAimedEntity())
end, false)
