# Bel Handling - Vehicle Handling System for All GTA 5 Cars

## Description
A comprehensive FiveM resource that provides custom handling modifications for all GTA 5 vehicles. This system automatically applies handling modifications based on vehicle class and allows for specific vehicle overrides.

## Features
- **Automatic Handling Application**: Applies handling modifications when entering vehicles
- **Class-Based System**: Different handling profiles for each vehicle class (Compacts, Sedans, Sports, Super, etc.)
- **Individual Vehicle Overrides**: Specific handling for individual vehicle models
- **Multiple Presets**: Performance, Drift, and Realistic handling presets
- **Permission System**: Optional permission system for admin control
- **Interactive Menu**: User-friendly menu system (requires ox_lib for full functionality)
- **Debug Mode**: Detailed logging for troubleshooting
- **Export Functions**: Allows other resources to interact with the handling system
- **All Vehicles JSON**: Generates `shared/all_vehicles.json` containing every GTA V/FiveM vehicle spawn name (plus categories)

## Installation

1. Download and place the `bel_handling` folder in your `resources/[belmont]` directory
2. Add `ensure bel_handling` to your `server.cfg`
3. Restart your server or use `refresh` and `ensure bel_handling`

Optional: add an ACE to allow in-game regeneration of the JSON file via `/regenvehiclesjson`:

```
add_ace group.admin bel_handling.regenvehiclesjson allow
```

## Dependencies
- **QBX Core**: Required for core functionality
- **ox_lib**: Optional (for enhanced menu system)

## Configuration

### Basic Settings (`shared/config.lua`)
```lua
Config.EnableHandling = true          -- Enable/disable the system
Config.Debug = false                  -- Enable debug logging
Config.UsePermissions = false         -- Enable permission system
Config.AdminGroups = {'admin', 'moderator'}  -- Admin job names
```

### Vehicle Classes
The system supports all GTA 5 vehicle classes:
- Compacts (0)
- Sedans (1)
- SUVs (2)
- Coupes (3)
- Muscle (4)
- Sports Classics (5)
- Sports (6)
- Super (7)
- Motorcycles (8)
- Off-road (9)
- And more...

### Individual Vehicle Overrides
Add specific handling for individual vehicles in `Config.VehicleHandling`:
```lua
['adder'] = {
    fInitialDriveForce = 1.6,
    fInitialDriveMaxFlatVel = 1.5,
    fMass = 1200.0,
    fBrakeForce = 1.8,
    fTractionCurveMax = 3.2
}
```

## Commands

### Admin Commands (require permission if enabled)
- `/handling` - Open the handling menu
- `/resethandling` - Reset current vehicle to default handling
- `/applyperformance` - Apply performance handling preset
- `/applydrift` - Apply drift handling preset
- `/applyrealistic` - Apply realistic handling preset
- `/reloadhandling` - Reload configuration (server command)

### General Commands
- `/vehiclestats` - View current vehicle statistics

## Handling Parameters

The system supports all major GTA 5 handling parameters:

### Drive & Engine
- `fInitialDriveForce` - Engine power
- `fInitialDriveMaxFlatVel` - Top speed
- `fDriveInertia` - Engine inertia
- `fClutchChangeRateScaleUpShift` - Upshift speed
- `fClutchChangeRateScaleDownShift` - Downshift speed

### Braking
- `fBrakeForce` - Brake strength
- `fBrakeBiasFront` - Front/rear brake balance
- `fHandBrakeForce` - Handbrake strength

### Suspension
- `fSuspensionForce` - Suspension stiffness
- `fSuspensionCompDamp` - Compression damping
- `fSuspensionReboundDamp` - Rebound damping
- `fSuspensionRaise` - Ride height adjustment

### Traction & Handling
- `fTractionCurveMax` - Maximum traction
- `fTractionCurveMin` - Minimum traction
- `fTractionLossMult` - Traction loss multiplier
- `fSteeringLock` - Maximum steering angle

### Physical Properties
- `fMass` - Vehicle weight
- `fCollisionDamageMult` - Collision damage
- `fDeformationDamageMult` - Deformation damage

## Usage Examples

### Automatic Handling
The system automatically applies handling modifications when you enter a vehicle based on its class or specific model overrides.

### Manual Application
Use the `/handling` command to open the menu and select from various presets:
- **Performance**: Enhanced acceleration, braking, and handling
- **Drift**: Reduced traction for easier drifting
- **Realistic**: More realistic driving physics

### For Developers
```lua
-- Apply custom handling to a vehicle
local customHandling = {
    fInitialDriveForce = 1.3,
    fBrakeForce = 1.2,
    fTractionCurveMax = 2.8
}
exports['bel_handling']:ApplyHandlingToVehicle(vehicle, customHandling)

-- Get current vehicle handling data
local handlingData = exports['bel_handling']:GetVehicleHandlingData(vehicle)
```

### All Vehicles JSON
This resource generates `shared/all_vehicles.json` on startup using the authoritative list from `qbx_core/shared/vehicles.lua`.

Structure:
```
{
    "generatedAt": "2025-10-25T11:22:33Z",
    "source": "qbx_core/shared/vehicles.lua",
    "count": 600,
    "all": ["adder", "airbus", "akula", ...],
    "categories": {
        "sports": ["alpha", "banshee", ...],
        "super": ["adder", "t20", ...],
        ...
    }
}
```

Regenerate manually from console or for admins with ACE:
```
regenvehiclesjson
```

## Troubleshooting

### Common Issues
1. **Handling not applying**: Check if `Config.EnableHandling` is set to `true`
2. **Permission denied**: Verify admin groups in config match your framework setup
3. **Menu not working**: Ensure ox_lib is installed for full menu functionality

### Debug Mode
Enable debug mode in config to see detailed logs:
```lua
Config.Debug = true
```

## Customization

### Adding New Vehicle Classes
Modify `Config.ClassHandling` to add handling for new vehicle classes.

### Creating Custom Presets
Add new handling presets in the menu system by modifying `client/menu.lua`.

### Integration with Other Resources
Use the export functions to integrate with other vehicle-related resources.

## Version History
- **v1.0.0**: Initial release with full handling system

## Support
For support and updates, contact Belmont0101 or visit the resource documentation.

## License
This resource is provided as-is for FiveM servers. Modify and distribute as needed for your server's requirements.