-- bel_handling: generate a JSON file with all GTA V/FiveM vehicle spawn names
-- Uses the authoritative list from qbx_core/shared/vehicles.lua

local VEH_RESOURCE = 'qbx_core'
local VEH_PATH = 'shared/vehicles.lua'

local function generateVehiclesJson()
    local raw = LoadResourceFile(VEH_RESOURCE, VEH_PATH)
    if not raw then
        print(('^1[bel_handling]^7 Failed to load %s/%s'):format(VEH_RESOURCE, VEH_PATH))
        return false
    end

    local chunk, err = load(raw, '@' .. VEH_RESOURCE .. '/' .. VEH_PATH)
    if not chunk then
        print(('^1[bel_handling]^7 Failed to parse vehicles table: %s'):format(err or 'unknown'))
        return false
    end

    local ok, vehicles = pcall(chunk)
    if not ok or type(vehicles) ~= 'table' then
        print(('^1[bel_handling]^7 Vehicles file did not return a table: %s'):format(tostring(vehicles)))
        return false
    end

    local all = {}
    local byCategory = {}

    for spawn, data in pairs(vehicles) do
        all[#all + 1] = spawn
        local cat = (type(data) == 'table' and data.category) or 'unknown'
        if not byCategory[cat] then byCategory[cat] = {} end
        byCategory[cat][#byCategory[cat] + 1] = spawn
    end

    table.sort(all)
    for _, list in pairs(byCategory) do
        table.sort(list)
    end

    local payload = {
        generatedAt = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        source = VEH_RESOURCE .. '/' .. VEH_PATH,
        count = #all,
        all = all,
        categories = byCategory,
    }

    local jsonStr = json.encode(payload)
    local outPath = 'shared/all_vehicles.json'
    SaveResourceFile(GetCurrentResourceName(), outPath, jsonStr, #jsonStr)

    print(('^2[bel_handling]^7 Wrote %s with %d vehicles'):format(outPath, #all))
    return true
end

-- Generate on resource start (server-side)
CreateThread(function()
    -- Small delay to ensure qbx_core is started
    Wait(1000)
    generateVehiclesJson()
end)

-- Command to regenerate on demand
RegisterCommand('regenvehiclesjson', function(source)
    local src = source
    -- Allow from console or from players (admin check optional)
    if src ~= 0 then
        -- Optional: integrate with your permission system if needed
        -- For now, only allow server console or players with ACE permission
        if not IsPlayerAceAllowed(src, 'bel_handling.regenvehiclesjson') then
            TriggerClientEvent('chat:addMessage', src, { args = { '^1bel_handling', 'You do not have permission to run this command.' } })
            return
        end
    end

    local ok = generateVehiclesJson()
    if src ~= 0 then
        if ok then
            TriggerClientEvent('chat:addMessage', src, { args = { '^2bel_handling', 'Regenerated shared/all_vehicles.json' } })
        else
            TriggerClientEvent('chat:addMessage', src, { args = { '^1bel_handling', 'Failed to regenerate JSON file' } })
        end
    end
end, true)