-- Bridge Shared - Framework Detection
Bridge = Bridge or {}

-- Detect which framework is being used
Bridge.Framework = nil

if GetResourceState('qb-core') == 'started' then
    Bridge.Framework = 'qb'
    print('^2[AdminPanel]^0 Detected framework: ^3QBCore^0')
elseif GetResourceState('es_extended') == 'started' then
    Bridge.Framework = 'esx'
    print('^2[AdminPanel]^0 Detected framework: ^3ESX^0')
else
    print('^1[AdminPanel]^0 ^1ERROR: No supported framework detected! Please ensure QBCore or ESX is running.^0')
end

-- Check if framework is valid
function Bridge.IsFrameworkValid()
    return Bridge.Framework ~= nil
end

-- Get framework name
function Bridge.GetFrameworkName()
    return Bridge.Framework or 'unknown'
end
