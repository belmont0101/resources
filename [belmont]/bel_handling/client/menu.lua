-- Support Qbox export name (GetQBCore); fall back to old qb-core name if needed
local QBCore = nil
if GetResourceState('qbx_core') == 'started' then
    QBCore = (exports['qbx_core'].GetQBCore and exports['qbx_core']:GetQBCore())
        or (exports['qbx_core'].GetCoreObject and exports['qbx_core']:GetCoreObject())
elseif GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Safe helpers
local function Notify(msg, typ, len)
    if QBCore and QBCore.Functions and QBCore.Functions.Notify then
        QBCore.Functions.Notify(msg, typ, len)
    elseif GetResourceState('ox_lib') == 'started' and exports.ox_lib and exports.ox_lib.notify then
        exports.ox_lib:notify({ description = msg, type = (typ == 'error' and 'error' or typ or 'inform'), duration = len })
    else
        print(('[bel_handling] %s: %s'):format(typ or 'info', msg))
    end
end

local function GetPlayerData()
    if QBCore and QBCore.Functions and QBCore.Functions.GetPlayerData then
        return QBCore.Functions.GetPlayerData()
    end
    return {}
end

-- Import functions from main.lua will be done inline since exports need to be called dynamically

-- Function to check if player has permission (local version)
local function HasPermission()
    if not Config.UsePermissions then
        return true
    end
    
    local PlayerData = GetPlayerData()
    if PlayerData and PlayerData.job then
        for _, group in pairs(Config.AdminGroups) do
            if PlayerData.job.name == group then
                return true
            end
        end
    end
    
    return false
end

-- Menu system (using ox_lib if available, otherwise basic commands)
local function OpenHandlingMenu()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
    Notify('You must be in a vehicle to open the handling menu', 'error')
        return
    end
    
    local model = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(model)
    local vehicleClass = GetVehicleClass(vehicle)
    local className = Config.VehicleClasses[vehicleClass] or 'Unknown'
    
    -- Try to use ox_lib menu if available
    if GetResourceState('ox_lib') == 'started' then
        local options = {
            {
                title = 'Vehicle Information',
                description = 'Model: ' .. modelName .. ' | Class: ' .. className,
                icon = 'car'
            },
            {
                title = 'Apply Performance Handling',
                description = 'Apply performance-oriented handling modifications',
                icon = 'gauge-high',
                onSelect = function()
                    ApplyPerformanceHandling(vehicle)
                end
            },
            {
                title = 'Apply Drift Handling',
                description = 'Apply drift-oriented handling modifications',
                icon = 'road',
                onSelect = function()
                    ApplyDriftHandling(vehicle)
                end
            },
            {
                title = 'Apply Realistic Handling',
                description = 'Apply realistic handling modifications',
                icon = 'balance-scale',
                onSelect = function()
                    ApplyRealisticHandling(vehicle)
                end
            },
            {
                title = 'Reset to Default',
                description = 'Reset vehicle handling to original values',
                icon = 'undo',
                onSelect = function()
                    ExecuteCommand(Config.Commands.resethandling.command)
                end
            },
            {
                title = 'Vehicle Stats',
                description = 'View current vehicle handling statistics',
                icon = 'chart-bar',
                onSelect = function()
                    ShowVehicleStats(vehicle)
                end
            }
        }
        
        exports.ox_lib:registerContext({
            id = 'bel_handling_menu',
            title = 'Vehicle Handling Menu',
            options = options
        })
        
        exports.ox_lib:showContext('bel_handling_menu')
    else
        -- Fallback to basic notification system
    Notify('Handling Menu - Available Options:', 'primary', 5000)
    Notify('1. /applyperformance - Performance handling', 'info', 3000)
    Notify('2. /applydrift - Drift handling', 'info', 3000)
    Notify('3. /applyrealistic - Realistic handling', 'info', 3000)
    Notify('4. /' .. Config.Commands.resethandling.command .. ' - Reset handling', 'info', 3000)
    end
end

-- Function to apply performance handling
function ApplyPerformanceHandling(vehicle)
    local performanceHandling = {
        fInitialDriveForce = 1.5,
        fInitialDriveMaxFlatVel = 1.4,
        fBrakeForce = 1.6,
        fTractionCurveMax = 3.0,
        fTractionCurveMin = 2.5,
        fSuspensionForce = 3.0,
        fSuspensionCompDamp = 1.8,
        fSuspensionReboundDamp = 3.2,
        fAntiRollBarForce = 1.2,
        fSteeringLock = 42.0,
        fTractionLossMult = 0.8
    }
    
    exports['bel_handling']:ApplyHandlingToVehicle(vehicle, performanceHandling)
    Notify('Performance handling applied', 'success')
    
    if Config.Debug then
        print('[bel_handling] Applied performance handling preset')
    end
end

-- Function to apply drift handling
function ApplyDriftHandling(vehicle)
    local driftHandling = {
        fInitialDriveForce = 1.2,
        fTractionCurveMax = 1.8,
        fTractionCurveMin = 1.4,
        fTractionCurveLateral = 18.0,
        fTractionLossMult = 1.4,
        fLowSpeedTractionLossMult = 1.2,
        fSuspensionForce = 2.4,
        fSuspensionCompDamp = 1.2,
        fSuspensionReboundDamp = 2.8,
        fAntiRollBarForce = 0.8,
        fSteeringLock = 48.0,
        fBrakeBiasFront = 0.3
    }
    
    exports['bel_handling']:ApplyHandlingToVehicle(vehicle, driftHandling)
    Notify('Drift handling applied', 'success')
    
    if Config.Debug then
        print('[bel_handling] Applied drift handling preset')
    end
end

-- Function to apply realistic handling
function ApplyRealisticHandling(vehicle)
    local realisticHandling = {
        fInitialDriveForce = 0.9,
        fBrakeForce = 1.1,
        fTractionCurveMax = 2.2,
        fTractionCurveMin = 1.8,
        fSuspensionForce = 2.0,
        fSuspensionCompDamp = 1.6,
        fSuspensionReboundDamp = 2.4,
        fAntiRollBarForce = 1.0,
        fSteeringLock = 35.0,
        fTractionLossMult = 1.0,
        fCollisionDamageMult = 1.2,
        fDeformationDamageMult = 1.1
    }
    
    exports['bel_handling']:ApplyHandlingToVehicle(vehicle, realisticHandling)
    Notify('Realistic handling applied', 'success')
    
    if Config.Debug then
        print('[bel_handling] Applied realistic handling preset')
    end
end

-- Function to show vehicle stats
function ShowVehicleStats(vehicle)
    local stats = exports['bel_handling']:GetVehicleHandlingData(vehicle)
    local model = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(model)
    
    local statsText = string.format([[
Vehicle: %s
Mass: %.1f kg
Drive Force: %.2f
Max Speed: %.1f
Brake Force: %.2f
Traction Max: %.2f
Suspension Force: %.2f
Steering Lock: %.1f°
    ]], 
        modelName,
        stats.fMass,
        stats.fInitialDriveForce,
        stats.fInitialDriveMaxFlatVel,
        stats.fBrakeForce,
        stats.fTractionCurveMax,
        stats.fSuspensionForce,
        stats.fSteeringLock
    )
    
    if GetResourceState('ox_lib') == 'started' then
        exports.ox_lib:alertDialog({
            header = 'Vehicle Statistics',
            content = statsText,
            centered = true
        })
    else
        print(statsText)
    Notify('Vehicle stats printed to console (F8)', 'info')
    end
end

-- Register handling menu command
RegisterCommand(Config.Commands.handling.command, function()
    if not HasPermission() then
    Notify('You do not have permission to use this command', 'error')
        return
    end
    
    OpenHandlingMenu()
end, false)

-- Register preset commands
RegisterCommand('applyperformance', function()
    if not HasPermission() then
    Notify('You do not have permission to use this command', 'error')
        return
    end
    
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        ApplyPerformanceHandling(vehicle)
    else
    Notify('You must be in a vehicle', 'error')
    end
end, false)

RegisterCommand('applydrift', function()
    if not HasPermission() then
    Notify('You do not have permission to use this command', 'error')
        return
    end
    
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        ApplyDriftHandling(vehicle)
    else
    Notify('You must be in a vehicle', 'error')
    end
end, false)

RegisterCommand('applyrealistic', function()
    if not HasPermission() then
    Notify('You do not have permission to use this command', 'error')
        return
    end
    
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        ApplyRealisticHandling(vehicle)
    else
    Notify('You must be in a vehicle', 'error')
    end
end, false)

RegisterCommand('vehiclestats', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        ShowVehicleStats(vehicle)
    else
        Notify('You must be in a vehicle', 'error')
    end
end, false)

-- Register command suggestions
TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.handling.command, Config.Commands.handling.description)
TriggerEvent('chat:addSuggestion', '/applyperformance', 'Apply performance handling preset')
TriggerEvent('chat:addSuggestion', '/applydrift', 'Apply drift handling preset')
TriggerEvent('chat:addSuggestion', '/applyrealistic', 'Apply realistic handling preset')
TriggerEvent('chat:addSuggestion', '/vehiclestats', 'Show current vehicle statistics')

-- Event to reload config
RegisterNetEvent('bel_handling:client:reloadConfig', function()
    -- Refresh any cached config data
    if Config.Debug then
        print('[bel_handling] Configuration reloaded')
    end
end)