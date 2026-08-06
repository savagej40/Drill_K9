local RESOURCE_NAME = GetCurrentResourceName()

local activePersonSearches = {}
local nextSearchId = 1
local SEARCH_TIMEOUT = 60000
local MAX_SEARCH_DISTANCE = 12.0

local function playerExists(sourceId)
    return sourceId
        and sourceId > 0
        and GetPlayerName(sourceId) ~= nil
end

local function playersNear(sourceA, sourceB)
    local pedA = GetPlayerPed(sourceA)
    local pedB = GetPlayerPed(sourceB)

    if pedA == 0 or pedB == 0 then
        return false
    end

    local coordsA = GetEntityCoords(pedA)
    local coordsB = GetEntityCoords(pedB)

    return #(coordsA - coordsB) <= MAX_SEARCH_DISTANCE
end

local function closeSearch(searchId, reason)
    local search = activePersonSearches[searchId]

    if not search then
        return
    end

    activePersonSearches[searchId] = nil

    if playerExists(search.target) then
        TriggerClientEvent('drill_k9:client:closePersonSearch', search.target)
    end

    if reason and playerExists(search.handler) then
        TriggerClientEvent(
            'drill_k9:client:personSearchCancelled',
            search.handler,
            reason
        )
    end
end

RegisterNetEvent('drill_k9:server:clientReady', function()
    local sourceId = source
    Utils.Debug('Client ready: %s (%s)', GetPlayerName(sourceId) or 'unknown', sourceId)
    TriggerClientEvent('drill_k9:client:serverReady', sourceId, Config.Version)
end)

RegisterNetEvent('drill_k9:server:startPersonSearch', function(targetSource)
    local handlerSource = source
    targetSource = tonumber(targetSource)

    if not playerExists(handlerSource)
        or not playerExists(targetSource)
        or handlerSource == targetSource then

        TriggerClientEvent(
            'drill_k9:client:personSearchCancelled',
            handlerSource,
            'Unable to start the person search.'
        )
        return
    end

    if not playersNear(handlerSource, targetSource) then
        TriggerClientEvent(
            'drill_k9:client:personSearchCancelled',
            handlerSource,
            'The player moved too far away.'
        )
        return
    end

    for searchId, search in pairs(activePersonSearches) do
        if search.handler == handlerSource or search.target == targetSource then
            closeSearch(searchId, 'A person search is already active.')
        end
    end

    local searchId = nextSearchId
    nextSearchId = nextSearchId + 1

    activePersonSearches[searchId] = {
        handler = handlerSource,
        target = targetSource,
        createdAt = os.time()
    }

    TriggerClientEvent(
        'drill_k9:client:openPersonSearch',
        targetSource,
        searchId
    )

    CreateThread(function()
        Wait(SEARCH_TIMEOUT)

        if activePersonSearches[searchId] then
            closeSearch(searchId, 'The person search timed out.')
        end
    end)
end)

RegisterNetEvent('drill_k9:server:submitPersonSearch', function(searchId, inventory)
    local targetSource = source
    searchId = tonumber(searchId)
    inventory = tostring(inventory or ''):sub(1, 1000)

    local search = activePersonSearches[searchId]

    if not search or search.target ~= targetSource then
        return
    end

    if inventory:match('^%s*$') then
        return
    end

    activePersonSearches[searchId] = nil

    TriggerClientEvent('drill_k9:client:closePersonSearch', targetSource)

    if playerExists(search.handler) then
        TriggerClientEvent(
            'drill_k9:client:personSearchResult',
            search.handler,
            {
                inventory = inventory,
                targetName = GetPlayerName(targetSource) or 'Player',
                targetSource = targetSource
            }
        )
    end
end)

RegisterNetEvent('drill_k9:server:cancelPersonSearch', function(searchId)
    local targetSource = source
    searchId = tonumber(searchId)

    local search = activePersonSearches[searchId]

    if not search or search.target ~= targetSource then
        return
    end

    closeSearch(searchId, 'The player cancelled the person search.')
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= RESOURCE_NAME then return end
    print('^2====================================================^7')
    print(('^2 drill_k9 v%s started successfully.^7'):format(Config.Version))
    print('^2 Standalone K9 resource loaded.^7')
    print('^2====================================================^7')
end)

AddEventHandler('playerDropped', function(reason)
    local sourceId = source

    for searchId, search in pairs(activePersonSearches) do
        if search.handler == sourceId or search.target == sourceId then
            closeSearch(searchId, 'The person search ended because a player disconnected.')
        end
    end

    Utils.Debug(
        'Player disconnected: %s (%s). Reason: %s',
        GetPlayerName(sourceId) or 'unknown',
        sourceId,
        tostring(reason)
    )
end)
