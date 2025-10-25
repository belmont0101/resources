-- Test commands for the handling system
-- These commands are for testing purposes only

if Config.Debug then
    -- Support Qbox export name (GetQBCore); fall back to old qb-core name if needed
    local QBCore = nil
    if GetResourceState('qbx_core') == 'started' then
        QBCore = (exports['qbx_core'].GetQBCore and exports['qbx_core']:GetQBCore())
            or (exports['qbx_core'].GetCoreObject and exports['qbx_core']:GetCoreObject())
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    end

    local function Notify(msg, typ, len)
        if QBCore and QBCore.Functions and QBCore.Functions.Notify then
            QBCore.Functions.Notify(msg, typ, len)
        elseif GetResourceState('ox_lib') == 'started' and exports.ox_lib and exports.ox_lib.notify then
            exports.ox_lib:notify({ description = msg, type = (typ == 'error' and 'error' or typ or 'inform'), duration = len })
        else
            print(('[bel_handling] %s: %s'):format(typ or 'info', msg))
        end
    end
    -- Test command to spawn a vehicle with handling
    RegisterCommand('testhandling', function(source, args, rawCommand)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        
        local vehicleModel = args[1] or 'adder'
        local modelHash = GetHashKey(vehicleModel)
        
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(100)
        end
        
        local vehicle = CreateVehicle(modelHash, coords.x + 2, coords.y, coords.z, heading, true, false)
        SetPedIntoVehicle(ped, vehicle, -1)
        
        -- Apply handling after a short delay
        SetTimeout(1000, function()
            exports['bel_handling']:ApplyHandling(vehicle)
        end)
        
    Notify('Test vehicle spawned: ' .. vehicleModel, 'success')
    end, false)
    
    -- Test command to print current vehicle handling
    RegisterCommand('printhandling', function()
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        if vehicle ~= 0 then
            local handling = exports['bel_handling']:GetVehicleHandlingData(vehicle)
            local model = GetEntityModel(vehicle)
            local modelName = GetDisplayNameFromVehicleModel(model)
            
            print('=== HANDLING DATA FOR ' .. modelName .. ' ===')
            for key, value in pairs(handling) do
                if type(value) == 'vector3' then
                    print(key .. ': x=' .. value.x .. ', y=' .. value.y .. ', z=' .. value.z)
                else
                    print(key .. ': ' .. tostring(value))
                end
            end
            print('=== END HANDLING DATA ===')
            
            Notify('Handling data printed to console (F8)', 'info')
        else
            Notify('You must be in a vehicle', 'error')
        end
    end, false)
    
    -- Register command suggestions for testing
    TriggerEvent('chat:addSuggestion', '/testhandling', 'Spawn a test vehicle with handling [vehicle_name]')
    TriggerEvent('chat:addSuggestion', '/printhandling', 'Print current vehicle handling to console')
    
    print('[bel_handling] Debug commands loaded: /testhandling, /printhandling')
end