-- Open Player Inventory
RegisterNetEvent('adminpanel:server:openPlayerInventory', function(targetId)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        
        local success, err = Bridge.ForceOpenPlayerInventory(src, targetId)
        if success then
            AdminServer.LogAction(src, 'Open Inventory', targetId, 'Opened ' .. targetName .. "'s inventory", 'info')
            TriggerClientEvent('adminpanel:client:notify', src, locale('inventory_opened', targetName), 'success')
        else
            TriggerClientEvent('adminpanel:client:notify', src, locale('inventory_not_found'), 'error')
        end
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Open Stash Inventory
RegisterNetEvent('adminpanel:server:openStashInventory', function(targetId)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        local stashId = 'admin_stash_' .. Bridge.GetPlayerId(Target)
        
        local success, err = Bridge.ForceOpenStash(src, stashId)
        if success then
            AdminServer.LogAction(src, 'Open Stash', targetId, 'Opened stash near ' .. targetName, 'info')
            TriggerClientEvent('adminpanel:client:notify', src, locale('stash_opened'), 'success')
        else
            TriggerClientEvent('adminpanel:client:notify', src, locale('inventory_not_found'), 'error')
        end
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Open Trunk Inventory
RegisterNetEvent('adminpanel:server:openTrunkInventory', function(targetId)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        
        if Bridge.HasInventory() then
            -- Get nearest vehicle trunk to target
            TriggerClientEvent('adminpanel:client:openTrunk', targetId, src)
            AdminServer.LogAction(src, 'Open Trunk', targetId, 'Opened trunk near ' .. targetName, 'info')
            TriggerClientEvent('adminpanel:client:notify', src, locale('trunk_opening'), 'success')
        else
            TriggerClientEvent('adminpanel:client:notify', src, locale('inventory_not_found'), 'error')
        end
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Open Trunk by Plate (helper)
RegisterNetEvent('adminpanel:server:openTrunkByPlate', function(adminId, plate)
    local src = source
    
    local success, err = Bridge.ForceOpenTrunk(adminId, plate)
    if success then
        TriggerClientEvent('adminpanel:client:notify', adminId, locale('trunk_opened', plate), 'success')
    else
        TriggerClientEvent('adminpanel:client:notify', adminId, locale('inventory_not_found'), 'error')
    end
end)

print('^2[AdminPanel]^0 Inventory module loaded!')
