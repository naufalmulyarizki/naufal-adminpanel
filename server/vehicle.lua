-- Fix Player Vehicle
RegisterNetEvent('adminpanel:server:fixPlayerVehicle', function(targetId)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        TriggerClientEvent('adminpanel:client:fixVehicle', targetId)
        
        AdminServer.LogAction(src, 'Fix Vehicle', targetId, 'Fixed vehicle for ' .. targetName, 'info')
        TriggerClientEvent('adminpanel:client:notify', src, locale('vehicle_fixed_player', targetName), 'success')
        AdminServer.Debug('Fixed vehicle for:', targetId)
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Give Car to Player
RegisterNetEvent('adminpanel:server:giveCarToPlayer', function(targetId, vehicle, plate)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        TriggerClientEvent('adminpanel:client:spawnCar', targetId, vehicle, plate)
        
        local plateInfo = plate and (' with plate ' .. plate) or ''
        AdminServer.LogAction(src, 'Give Car', targetId, 'Gave ' .. vehicle .. plateInfo .. ' to ' .. targetName, 'info')
        TriggerClientEvent('adminpanel:client:notify', src, locale('vehicle_given_player', vehicle, targetName), 'success')
        AdminServer.Debug('Gave car to:', targetId, vehicle, plate)
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

print('^2[AdminPanel]^0 Vehicle module loaded!')
