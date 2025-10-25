Config = {}

-- Enable/Disable the handling system
Config.EnableHandling = true

-- Debug mode (prints handling changes to console)
Config.Debug = false

-- Permission system (set to false to allow all players)
Config.UsePermissions = false
Config.AdminGroups = {'admin', 'moderator'}

-- Default handling multipliers for different vehicle classes
Config.VehicleClasses = {
    [0] = "Compacts",
    [1] = "Sedans", 
    [2] = "SUVs",
    [3] = "Coupes",
    [4] = "Muscle",
    [5] = "Sports Classics",
    [6] = "Sports",
    [7] = "Super",
    [8] = "Motorcycles",
    [9] = "Off-road",
    [10] = "Industrial",
    [11] = "Utility",
    [12] = "Vans",
    [13] = "Cycles",
    [14] = "Boats",
    [15] = "Helicopters",
    [16] = "Planes",
    [17] = "Service",
    [18] = "Emergency",
    [19] = "Military",
    [20] = "Commercial",
    [21] = "Trains"
}

-- Handling modifications for each vehicle class
Config.ClassHandling = {
    [0] = { -- Compacts
        fMass = 1200.0,
        fInitialDragCoeff = 0.9,
        fPercentSubmerged = 85.0,
        fSubmergedRatio = 1.0,
        vecCentreOfMassOffset = vector3(0.0, 0.0, 0.0),
        vecInertiaMultiplier = vector3(1.0, 1.0, 1.0),
        fDriveBiasFront = 0.0,
        nInitialDriveGears = 5,
        fInitialDriveForce = 0.25,
        fDriveInertia = 1.0,
        fClutchChangeRateScaleUpShift = 2.3,
        fClutchChangeRateScaleDownShift = 2.3,
        fInitialDriveMaxFlatVel = 150.0,
        fBrakeForce = 1.0,
        fBrakeBiasFront = 0.5,
        fHandBrakeForce = 0.7,
        fSteeringLock = 40.0,
        fTractionCurveMax = 2.5,
        fTractionCurveMin = 2.0,
        fTractionCurveLateral = 22.5,
        fTractionSpringDeltaMax = 0.15,
        fLowSpeedTractionLossMult = 1.0,
        fCamberStiffnesss = 0.0,
        fTractionBiasFront = 0.48,
        fTractionLossMult = 1.0,
        fSuspensionForce = 2.2,
        fSuspensionCompDamp = 1.4,
        fSuspensionReboundDamp = 2.5,
        fSuspensionUpperLimit = 0.1,
        fSuspensionLowerLimit = -0.15,
        fSuspensionRaise = 0.0,
        fSuspensionBiasFront = 0.52,
        fAntiRollBarForce = 0.9,
        fAntiRollBarBiasFront = 0.6,
        fRollCentreHeightFront = 0.36,
        fRollCentreHeightRear = 0.36,
        fCollisionDamageMult = 1.0,
        fWeaponDamageMult = 1.0,
        fDeformationDamageMult = 0.7,
        fEngineDamageMult = 1.5,
        fPetrolTankVolume = 65.0,
        fOilVolume = 5.0,
        fSeatOffsetDistX = 0.0,
        fSeatOffsetDistY = 0.0,
        fSeatOffsetDistZ = 0.0,
        nMonetaryValue = 35000
    },
    [1] = { -- Sedans
        fInitialDriveMaxFlatVel = 1.0,
        fInitialDriveForce = 1.0,
        fDriveInertia = 1.0,
        fClutchChangeRateScaleUpShift = 1.0,
        fClutchChangeRateScaleDownShift = 1.0,
        fMass = 1400.0,
        fBrakeForce = 1.0,
        fSteeringLock = 35.0,
        fTractionCurveMax = 2.4,
        fSuspensionForce = 2.0
    },
    [2] = { -- SUVs
        fMass = 2200.0,
        fBrakeForce = 1.2,
        fSteeringLock = 32.0,
        fSuspensionForce = 2.8,
        fSuspensionRaise = 0.05
    },
    [4] = { -- Muscle
        fInitialDriveForce = 1.3,
        fInitialDriveMaxFlatVel = 1.2,
        fMass = 1600.0,
        fTractionCurveMax = 2.8,
        fSuspensionForce = 2.4
    },
    [6] = { -- Sports
        fInitialDriveForce = 1.4,
        fInitialDriveMaxFlatVel = 1.3,
        fMass = 1200.0,
        fBrakeForce = 1.3,
        fTractionCurveMax = 2.9,
        fSuspensionForce = 2.6
    },
    [7] = { -- Super
        fInitialDriveForce = 1.5,
        fInitialDriveMaxFlatVel = 1.4,
        fMass = 1100.0,
        fBrakeForce = 1.5,
        fTractionCurveMax = 3.0,
        fSuspensionForce = 2.8
    },
    [8] = { -- Motorcycles
        fMass = 180.0,
        fBrakeForce = 0.8,
        fSteeringLock = 45.0,
        fTractionCurveMax = 2.2,
        fSuspensionForce = 1.8
    }
}

-- Individual vehicle handling overrides (specific vehicle models)
Config.VehicleHandling = {
    -- Example overrides for specific vehicles
    ['adder'] = {
        fInitialDriveForce = 1.6,
        fInitialDriveMaxFlatVel = 1.5,
        fMass = 1200.0,
        fBrakeForce = 1.8,
        fTractionCurveMax = 3.2
    },
    ['zentorno'] = {
        fInitialDriveForce = 1.5,
        fInitialDriveMaxFlatVel = 1.4,
        fMass = 1150.0,
        fBrakeForce = 1.7,
        fTractionCurveMax = 3.1
    },
    ['t20'] = {
        fInitialDriveForce = 1.55,
        fInitialDriveMaxFlatVel = 1.45,
        fMass = 1180.0,
        fBrakeForce = 1.75,
        fTractionCurveMax = 3.15
    }
}

-- Commands configuration
Config.Commands = {
    ['handling'] = {
        command = 'handling',
        description = 'Open handling menu',
        permission = 'admin'
    },
    ['resethandling'] = {
        command = 'resethandling',
        description = 'Reset vehicle handling to default',
        permission = 'admin'
    }
}