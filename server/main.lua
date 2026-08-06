local RESOURCE_NAME = GetCurrentResourceName()

RegisterNetEvent('drill_k9:server:clientReady', function()
    local sourceId = source
    Utils.Debug('Client ready: %s (%s)', GetPlayerName(sourceId) or 'unknown', sourceId)
    TriggerClientEvent('drill_k9:client:serverReady', sourceId, Config.Version)
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
    Utils.Debug(
        'Player disconnected: %s (%s). Reason: %s',
        GetPlayerName(sourceId) or 'unknown',
        sourceId,
        tostring(reason)
    )
end)
