-- Set Weather
RegisterNetEvent('adminpanel:server:setWeather', function(weather)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    -- Use qb-weathersync if available
    TriggerEvent('qb-weathersync:server:setWeather', weather)
    
    -- Fallback: set weather for all clients
    TriggerClientEvent('adminpanel:client:setWeather', -1, weather)
    
    AdminServer.LogAction(src, 'Set Weather', nil, 'Weather: ' .. weather, 'info')
    AdminServer.Debug('Weather set to:', weather)
end)

-- Set Time
RegisterNetEvent('adminpanel:server:setTime', function(hour, minute)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    hour = tonumber(hour) or 12
    minute = tonumber(minute) or 0
    
    -- Use qb-weathersync if available
    TriggerEvent('qb-weathersync:server:setTime', hour, minute)
    
    -- Fallback: set time for all clients
    TriggerClientEvent('adminpanel:client:setTime', -1, hour, minute)
    
    AdminServer.LogAction(src, 'Set Time', nil, string.format('Time: %02d:%02d', hour, minute), 'info')
    AdminServer.Debug('Time set to:', hour, minute)
end)

-- Freeze Time
RegisterNetEvent('adminpanel:server:freezeTime', function(enabled)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    -- Use qb-weathersync if available
    TriggerEvent('qb-weathersync:server:toggleFreeze', enabled)
    
    -- Fallback
    TriggerClientEvent('adminpanel:client:freezeTime', -1, enabled)
    
    AdminServer.LogAction(src, 'Freeze Time', nil, enabled and 'Enabled' or 'Disabled', 'info')
    AdminServer.Debug('Freeze time:', enabled)
end)

-- Blackout
RegisterNetEvent('adminpanel:server:setBlackout', function(enabled)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    -- Use qb-weathersync if available
    TriggerEvent('qb-weathersync:server:setBlackout', enabled)
    
    -- Fallback
    TriggerClientEvent('adminpanel:client:setBlackout', -1, enabled)
    
    AdminServer.LogAction(src, 'Blackout', nil, enabled and 'Enabled' or 'Disabled', 'info')
    AdminServer.Debug('Blackout:', enabled)
end)

-- Revive Self
RegisterNetEvent('adminpanel:server:reviveSelf', function()
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    -- Use qb-ambulancejob revive
    TriggerClientEvent('hospital:client:Revive', src)
    
    AdminServer.LogAction(src, 'Revive Self', nil, 'Self revived', 'info')
    AdminServer.Debug('Admin revived self:', src)
end)

print('^2[AdminPanel]^0 World module loaded!')
