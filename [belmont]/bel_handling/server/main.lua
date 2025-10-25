-- Support Qbox export name (GetQBCore); fall back to old qb-core name if needed
local QBCore = nil
if GetResourceState('qbx_core') == 'started' then
    QBCore = (exports['qbx_core'].GetQBCore and exports['qbx_core']:GetQBCore())
        or (exports['qbx_core'].GetCoreObject and exports['qbx_core']:GetCoreObject())
elseif GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Server-side handling data storage
local handlingData = {}

-- Initialize the resource
if QBCore and QBCore.Functions and QBCore.Functions.CreateCallback then
    QBCore.Functions.CreateCallback('bel_handling:server:hasPermission', function(source, cb, permission)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then
            cb(false)
            return
        end

        if not Config.UsePermissions then
            cb(true)
            return
        end

        -- Check if player has required permission
        for _, group in pairs(Config.AdminGroups) do
            if Player.PlayerData.job.name == group then
                cb(true)
                return
            end
        end

        cb(false)
    end)
else
    -- Fallback: if QBCore is unavailable, treat as no permission system
    Config.UsePermissions = false
end

-- Event to log handling changes
RegisterNetEvent('bel_handling:server:logHandlingChange', function(vehicleModel, handlingType)
    local src = source
    local Player = (QBCore and QBCore.Functions and QBCore.Functions.GetPlayer) and QBCore.Functions.GetPlayer(src) or nil
    
    if Player then
        local logMessage = string.format('[bel_handling] Player %s (%s) modified handling for %s (%s)', 
            Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            Player.PlayerData.citizenid,
            vehicleModel,
            handlingType
        )
        
        print(logMessage)
        
        -- You can add additional logging here (database, webhook, etc.)
    end
end)

-- Command to reload handling configuration
RegisterCommand('reloadhandling', function(source, args, rawCommand)
    local Player = (QBCore and QBCore.Functions and QBCore.Functions.GetPlayer) and QBCore.Functions.GetPlayer(source) or nil
    
    if not Player then return end
    
    -- Check permissions
    local hasPermission = false
    if not Config.UsePermissions then
        hasPermission = true
    else
        for _, group in pairs(Config.AdminGroups) do
            if Player.PlayerData.job.name == group then
                hasPermission = true
                break
            end
        end
    end
    
    if not hasPermission then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to use this command', 'error')
        return
    end
    
    -- Reload the configuration
    TriggerClientEvent('bel_handling:client:reloadConfig', -1)
    TriggerClientEvent('QBCore:Notify', source, 'Handling configuration reloaded for all players', 'success')
    
    print('[bel_handling] Configuration reloaded by ' .. Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.citizenid .. ')')
end, true)

-- Event to sync handling data between players
RegisterNetEvent('bel_handling:server:syncHandling', function(vehicleNetId, handlingData)
    local src = source
    -- Broadcast to all other players
    TriggerClientEvent('bel_handling:client:receiveHandlingSync', -1, vehicleNetId, handlingData, src)
end)

-- Event to get player information for logging
RegisterNetEvent('bel_handling:server:getPlayerInfo', function()
    local src = source
    local Player = (QBCore and QBCore.Functions and QBCore.Functions.GetPlayer) and QBCore.Functions.GetPlayer(src) or nil
    
    if Player then
        local playerInfo = {
            name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            citizenid = Player.PlayerData.citizenid,
            job = Player.PlayerData.job.name,
            grade = Player.PlayerData.job.grade.level
        }
        
        TriggerClientEvent('bel_handling:client:receivePlayerInfo', src, playerInfo)
    end
end)

-- Version check and startup message
CreateThread(function()
    Wait(2000) -- Wait for server to fully load
    
    print('^2[bel_handling]^7 Vehicle Handling System initialized')
    print('^2[bel_handling]^7 Version: 1.0.0 by Belmont0101')
    
    if Config.EnableHandling then
        print('^2[bel_handling]^7 Handling modifications: ^2ENABLED^7')
    else
        print('^2[bel_handling]^7 Handling modifications: ^1DISABLED^7')
    end
    
    if Config.UsePermissions then
        print('^2[bel_handling]^7 Permission system: ^2ENABLED^7')
        print('^2[bel_handling]^7 Admin groups: ^3' .. table.concat(Config.AdminGroups, ', ') .. '^7')
    else
        print('^2[bel_handling]^7 Permission system: ^1DISABLED^7 (All players can use)')
    end
    
    if Config.Debug then
        print('^2[bel_handling]^7 Debug mode: ^3ENABLED^7')
    end
end)

-- Export server functions
exports('GetHandlingData', function()
    return handlingData
end)

exports('SetHandlingData', function(vehicle, data)
    handlingData[vehicle] = data
end)