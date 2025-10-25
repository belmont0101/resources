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

-- Local variables
local currentVehicle = nil
local defaultHandling = {}
local originalHandling = {}

-- Initialize the resource
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if Config.Debug then
        print('[bel_handling] Player loaded, initializing handling system...')
    end
end)

-- Function to get vehicle handling data
local function GetVehicleHandlingData(vehicle)
    local handling = {}
    
    -- Get all handling fields
    handling.fMass = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fMass')
    handling.fInitialDragCoeff = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDragCoeff')
    handling.fPercentSubmerged = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPercentSubmerged')
    handling.fSubmergedRatio = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSubmergedRatio')
    handling.vecCentreOfMassOffset = GetVehicleHandlingVector(vehicle, 'CHandlingData', 'vecCentreOfMassOffset')
    handling.vecInertiaMultiplier = GetVehicleHandlingVector(vehicle, 'CHandlingData', 'vecInertiaMultiplier')
    handling.fDriveBiasFront = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fDriveBiasFront')
    handling.nInitialDriveGears = GetVehicleHandlingInt(vehicle, 'CHandlingData', 'nInitialDriveGears')
    handling.fInitialDriveForce = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveForce')
    handling.fDriveInertia = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fDriveInertia')
    handling.fClutchChangeRateScaleUpShift = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fClutchChangeRateScaleUpShift')
    handling.fClutchChangeRateScaleDownShift = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fClutchChangeRateScaleDownShift')
    handling.fInitialDriveMaxFlatVel = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel')
    handling.fBrakeForce = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce')
    handling.fBrakeBiasFront = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeBiasFront')
    handling.fHandBrakeForce = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fHandBrakeForce')
    handling.fSteeringLock = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSteeringLock')
    handling.fTractionCurveMax = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax')
    handling.fTractionCurveMin = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin')
    handling.fTractionCurveLateral = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveLateral')
    handling.fTractionSpringDeltaMax = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionSpringDeltaMax')
    handling.fLowSpeedTractionLossMult = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult')
    handling.fCamberStiffnesss = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fCamberStiffnesss')
    handling.fTractionBiasFront = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionBiasFront')
    handling.fTractionLossMult = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionLossMult')
    handling.fSuspensionForce = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSuspensionForce')
    handling.fSuspensionCompDamp = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSuspensionCompDamp')
    handling.fSuspensionReboundDamp = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSuspensionReboundDamp')
    handling.fSuspensionUpperLimit = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSuspensionUpperLimit')
    handling.fSuspensionLowerLimit = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSuspensionLowerLimit')
    handling.fSuspensionRaise = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSuspensionRaise')
    handling.fSuspensionBiasFront = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSuspensionBiasFront')
    handling.fAntiRollBarForce = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fAntiRollBarForce')
    handling.fAntiRollBarBiasFront = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fAntiRollBarBiasFront')
    handling.fRollCentreHeightFront = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fRollCentreHeightFront')
    handling.fRollCentreHeightRear = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fRollCentreHeightRear')
    handling.fCollisionDamageMult = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fCollisionDamageMult')
    handling.fWeaponDamageMult = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fWeaponDamageMult')
    handling.fDeformationDamageMult = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fDeformationDamageMult')
    handling.fEngineDamageMult = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fEngineDamageMult')
    handling.fPetrolTankVolume = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume')
    handling.fOilVolume = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fOilVolume')
    handling.fSeatOffsetDistX = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSeatOffsetDistX')
    handling.fSeatOffsetDistY = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSeatOffsetDistY')
    handling.fSeatOffsetDistZ = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSeatOffsetDistZ')
    handling.nMonetaryValue = GetVehicleHandlingInt(vehicle, 'CHandlingData', 'nMonetaryValue')
    
    return handling
end

-- Function to apply handling to vehicle
local function ApplyHandlingToVehicle(vehicle, handlingData)
    for key, value in pairs(handlingData) do
        if type(value) == "number" then
            if string.find(key, "nInitialDriveGears") or string.find(key, "nMonetaryValue") then
                SetVehicleHandlingInt(vehicle, 'CHandlingData', key, math.floor(value))
            else
                SetVehicleHandlingFloat(vehicle, 'CHandlingData', key, value)
            end
        elseif type(value) == "vector3" then
            SetVehicleHandlingVector(vehicle, 'CHandlingData', key, value)
        end
    end
end

-- Function to get appropriate handling for vehicle
local function GetHandlingForVehicle(vehicle)
    local model = GetEntityModel(vehicle)
    local modelName = string.lower(GetDisplayNameFromVehicleModel(model))
    local vehicleClass = GetVehicleClass(vehicle)
    
    -- Check for specific vehicle override first
    if Config.VehicleHandling[modelName] then
        if Config.Debug then
            print('[bel_handling] Applying specific handling for: ' .. modelName)
        end
        return Config.VehicleHandling[modelName]
    end
    
    -- Use class-based handling
    if Config.ClassHandling[vehicleClass] then
        if Config.Debug then
            print('[bel_handling] Applying class handling for: ' .. Config.VehicleClasses[vehicleClass] .. ' (' .. modelName .. ')')
        end
        return Config.ClassHandling[vehicleClass]
    end
    
    return nil
end

-- Function to check if player has permission
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

-- Main handling application function
local function ApplyHandling(vehicle)
    if not DoesEntityExist(vehicle) then return end
    
    local handlingData = GetHandlingForVehicle(vehicle)
    if handlingData then
        -- Store original handling before applying modifications
        if not originalHandling[vehicle] then
            originalHandling[vehicle] = GetVehicleHandlingData(vehicle)
        end
        
        ApplyHandlingToVehicle(vehicle, handlingData)
        
        if Config.Debug then
            local model = GetEntityModel(vehicle)
            local modelName = GetDisplayNameFromVehicleModel(model)
            print('[bel_handling] Applied handling modifications to: ' .. modelName)
        end
    end
end

-- Event handler for when player enters a vehicle
CreateThread(function()
    while true do
        Wait(1000)
        
        if Config.EnableHandling then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle ~= 0 and vehicle ~= currentVehicle then
                currentVehicle = vehicle
                ApplyHandling(vehicle)
            elseif vehicle == 0 then
                currentVehicle = nil
            end
        end
    end
end)

-- Command to reset vehicle handling
RegisterCommand(Config.Commands.resethandling.command, function()
    if not HasPermission() then
    Notify('You do not have permission to use this command', 'error')
        return
    end
    
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        if originalHandling[vehicle] then
            ApplyHandlingToVehicle(vehicle, originalHandling[vehicle])
            Notify('Vehicle handling reset to default', 'success')
            
            if Config.Debug then
                local model = GetEntityModel(vehicle)
                local modelName = GetDisplayNameFromVehicleModel(model)
                print('[bel_handling] Reset handling for: ' .. modelName)
            end
        else
            Notify('No original handling data found for this vehicle', 'error')
        end
    else
    Notify('You must be in a vehicle to reset handling', 'error')
    end
end, false)

-- Register command suggestions
TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.resethandling.command, Config.Commands.resethandling.description)

-- Export functions for other resources
exports('ApplyHandling', ApplyHandling)
exports('GetVehicleHandlingData', GetVehicleHandlingData)
exports('ApplyHandlingToVehicle', ApplyHandlingToVehicle)