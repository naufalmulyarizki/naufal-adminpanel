-- Kick Player
RegisterNetEvent('adminpanel:server:kickPlayer', function(targetId, reason)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        DropPlayer(targetId, reason or Config.Notifications.kickMessage)
        AdminServer.LogAction(src, 'Player Kicked', targetId, 'Reason: ' .. (reason or 'No reason'), 'warning')
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_kicked', targetName), 'success')
        AdminServer.Debug('Player kicked:', targetId, 'Reason:', reason)
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Ban Player
RegisterNetEvent('adminpanel:server:banPlayer', function(targetId, reason, duration)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    duration = tonumber(duration) or 0
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        local banExpiry = duration > 0 and os.time() + (duration * 60) or 2147483647 -- 2038 for permanent
        
        -- Get player data for ban
        local charinfo = Bridge.GetCharInfo(Target)
        local identifiers = Bridge.GetPlayerIdentifiers(Target)
        
        local banData = {
            name = charinfo.firstname .. ' ' .. charinfo.lastname,
            license = identifiers.license or '',
            discord = identifiers.discord or '',
            ip = identifiers.ip or '',
            reason = reason or Config.Notifications.banMessage,
            expire = banExpiry,
            bannedby = AdminServer.GetAdminName(src)
        }
        
        -- Insert ban to database
        MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            banData.name,
            banData.license,
            banData.discord,
            banData.ip,
            banData.reason,
            banData.expire,
            banData.bannedby
        })
        
        DropPlayer(targetId, banData.reason)
        
        local durationText = duration > 0 and (duration .. ' minutes') or 'Permanent'
        AdminServer.LogAction(src, 'Player Banned', targetId, 'Duration: ' .. durationText .. ', Reason: ' .. (reason or 'No reason'), 'error')
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_banned', targetName), 'success')
        AdminServer.Debug('Player banned:', targetId, 'Duration:', duration, 'Reason:', reason)
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Give Money
RegisterNetEvent('adminpanel:server:giveMoney', function(targetId, moneyType, amount)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    amount = tonumber(amount)
    
    if not amount or amount <= 0 then
        TriggerClientEvent('adminpanel:client:notify', src, locale('invalid_amount'), 'error')
        return
    end
    
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        
        if moneyType == 'money' or moneyType == 'cash' then
            Bridge.AddMoney(Target, 'cash', amount, 'admin-panel-give')
        elseif moneyType == 'bank' then
            Bridge.AddMoney(Target, 'bank', amount, 'admin-panel-give')
        end
        
        AdminServer.LogAction(src, 'Money Given', targetId, 'Type: ' .. moneyType .. ', Amount: $' .. amount, 'info')
        TriggerClientEvent('adminpanel:client:notify', src, locale('money_given', amount, moneyType, targetName), 'success')
        TriggerClientEvent('adminpanel:client:notify', targetId, locale('money_received', amount, moneyType), 'success')
        AdminServer.Debug('Money given:', targetId, moneyType, amount)
        
        -- Update players list
        TriggerClientEvent('adminpanel:client:updatePlayers', src, AdminServer.GetPlayersData())
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Give Item
RegisterNetEvent('adminpanel:server:giveItem', function(targetId, itemName, quantity)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    quantity = tonumber(quantity) or 1
    
    if quantity <= 0 then
        TriggerClientEvent('adminpanel:client:notify', src, locale('invalid_quantity'), 'error')
        return
    end
    
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        local success = Bridge.AddItem(Target, itemName, quantity)
        
        if success then
            AdminServer.LogAction(src, 'Item Given', targetId, 'Item: ' .. itemName .. ', Quantity: ' .. quantity, 'info')
            TriggerClientEvent('adminpanel:client:notify', src, locale('item_given', quantity, itemName, targetName), 'success')
            TriggerClientEvent('adminpanel:client:notify', targetId, locale('item_received', quantity, itemName), 'success')
            AdminServer.Debug('Item given:', targetId, itemName, quantity)
        else
            TriggerClientEvent('adminpanel:client:notify', src, locale('item_give_failed'), 'error')
        end
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Teleport Player
RegisterNetEvent('adminpanel:server:teleportPlayer', function(targetId, coords, heading)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        TriggerClientEvent('adminpanel:client:teleport', targetId, coords, heading)
        AdminServer.LogAction(src, 'Teleported Player', targetId, string.format('To: %.2f, %.2f, %.2f', coords.x, coords.y, coords.z), 'warning')
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_teleported', targetName), 'success')
        AdminServer.Debug('Player teleported:', targetId, coords.x, coords.y, coords.z)
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Clear Inventory (ox_inventory)
RegisterNetEvent('adminpanel:server:clearInventory', function(targetId)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        
        Bridge.ClearInventory(Target, targetId)
        
        AdminServer.LogAction(src, 'Clear Inventory', targetId, 'Cleared inventory of ' .. targetName, 'warning')
        TriggerClientEvent('adminpanel:client:notify', src, locale('inventory_cleared', targetName), 'success')
        TriggerClientEvent('adminpanel:client:notify', targetId, locale('inventory_cleared_by_admin'), 'error')
        AdminServer.Debug('Inventory cleared:', targetId)
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Freeze Player
RegisterNetEvent('adminpanel:server:freezePlayer', function(targetId, frozen)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        TriggerClientEvent('adminpanel:client:freeze', targetId, frozen)
        
        local action = frozen and 'Frozen' or 'Unfrozen'
        AdminServer.LogAction(src, action .. ' Player', targetId, targetName .. ' was ' .. action:lower(), 'warning')
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_freeze_action', targetName, action:lower()), 'success')
        AdminServer.Debug('Player ' .. action:lower() .. ':', targetId)
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Give Item to Player
RegisterNetEvent('adminpanel:server:giveItemToPlayer', function(targetId, item, amount)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    amount = tonumber(amount) or 1
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        
        Bridge.AddItem(Target, item, amount, targetId)
        
        AdminServer.LogAction(src, 'Give Item', targetId, 'Gave ' .. amount .. 'x ' .. item .. ' to ' .. targetName, 'info')
        TriggerClientEvent('adminpanel:client:notify', src, locale('item_given', amount, item, targetName), 'success')
        TriggerClientEvent('adminpanel:client:notify', targetId, locale('item_received', amount, item), 'success')
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Give Item to All
RegisterNetEvent('adminpanel:server:giveItemToAll', function(item, amount)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    amount = tonumber(amount) or 1
    local players = Bridge.GetPlayers()
    local count = 0
    
    for _, playerId in ipairs(players) do
        local Target = Bridge.GetPlayer(playerId)
        if Target then
            Bridge.AddItem(Target, item, amount, playerId)
            TriggerClientEvent('adminpanel:client:notify', playerId, locale('item_received', amount, item), 'success')
            count = count + 1
        end
    end
    
    AdminServer.LogAction(src, 'Give Item to All', nil, 'Gave ' .. amount .. 'x ' .. item .. ' to ' .. count .. ' players', 'success')
    TriggerClientEvent('adminpanel:client:notify', src, locale('item_given_to_all', amount, item, count), 'success')
end)

-- Give Money to All Players
RegisterNetEvent('adminpanel:server:giveMoneyToAll', function(amount, moneyType)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    amount = tonumber(amount) or 0
    moneyType = moneyType or 'money'
    local players = Bridge.GetPlayers()
    local count = 0
    
    for _, playerId in ipairs(players) do
        local Target = Bridge.GetPlayer(playerId)
        if Target then
            if moneyType == 'bank' then
                Bridge.AddMoney(Target, 'bank', amount, 'admin-panel')
            else
                Bridge.AddMoney(Target, 'cash', amount, 'admin-panel')
            end
            TriggerClientEvent('adminpanel:client:notify', playerId, locale('money_received', amount, moneyType), 'success')
            count = count + 1
        end
    end
    
    AdminServer.LogAction(src, 'Give Money to All', nil, 'Gave $' .. amount .. ' (' .. moneyType .. ') to ' .. count .. ' players', 'success')
    TriggerClientEvent('adminpanel:client:notify', src, locale('money_given_to_all', amount, count), 'success')
end)

-- Make Player Drunk
RegisterNetEvent('adminpanel:server:makePlayerDrunk', function(targetId)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        TriggerClientEvent('adminpanel:client:makeDrunk', targetId)
        
        AdminServer.LogAction(src, 'Make Drunk', targetId, 'Made ' .. targetName .. ' drunk', 'warning')
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_made_drunk', targetName), 'success')
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Mute Player
RegisterNetEvent('adminpanel:server:mutePlayer', function(targetId, muted)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        AdminServer.mutedPlayers[targetId] = muted
        
        -- If using pma-voice
        if GetResourceState('pma-voice') == 'started' then
            exports['pma-voice']:setPlayerMuted(targetId, muted)
        end
        
        local action = muted and 'Muted' or 'Unmuted'
        AdminServer.LogAction(src, action .. ' Player', targetId, targetName .. ' was ' .. action:lower(), 'warning')
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_mute_action', targetName, action:lower()), 'success')
        
        if muted then
            TriggerClientEvent('adminpanel:client:notify', targetId, locale('muted_by_admin'), 'error')
        else
            TriggerClientEvent('adminpanel:client:notify', targetId, locale('unmuted'), 'success')
        end
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Remove Money from Player
RegisterNetEvent('adminpanel:server:removeMoneyPlayer', function(targetId, amount, moneyType)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    amount = tonumber(amount) or 0
    moneyType = moneyType or 'money'
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        
        if moneyType == 'bank' then
            Bridge.RemoveMoney(Target, 'bank', amount, 'admin-panel')
        else
            Bridge.RemoveMoney(Target, 'cash', amount, 'admin-panel')
        end
        
        AdminServer.LogAction(src, 'Remove Money', targetId, 'Removed $' .. amount .. ' (' .. moneyType .. ') from ' .. targetName, 'warning')
        TriggerClientEvent('adminpanel:client:notify', src, locale('money_removed', amount, targetName), 'success')
        TriggerClientEvent('adminpanel:client:notify', targetId, locale('money_removed_from_you', amount, moneyType), 'error')
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Remove Stress
RegisterNetEvent('adminpanel:server:removeStress', function(targetId)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        
        Bridge.SetMetaData(Target, 'stress', 0)
        TriggerClientEvent('adminpanel:client:removeStress', targetId)
        TriggerClientEvent('hud:client:UpdateStress', targetId, 0)
        
        AdminServer.LogAction(src, 'Remove Stress', targetId, 'Removed stress from ' .. targetName, 'info')
        TriggerClientEvent('adminpanel:client:notify', src, locale('stress_removed_from', targetName), 'success')
        TriggerClientEvent('adminpanel:client:notify', targetId, locale('your_stress_removed'), 'success')
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Revive Radius
RegisterNetEvent('adminpanel:server:reviveRadius', function(targetId)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        local radius = 10.0
        
        -- Get target coords from server
        TriggerClientEvent('adminpanel:client:reviveRadius', targetId, radius)
        
        AdminServer.LogAction(src, 'Revive Radius', targetId, 'Revived players in radius around ' .. targetName, 'success')
        TriggerClientEvent('adminpanel:client:notify', src, locale('reviving_in_radius'), 'success')
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Set Player Ped
RegisterNetEvent('adminpanel:server:setPlayerPed', function(targetId, pedModel)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        TriggerClientEvent('adminpanel:client:setPed', targetId, pedModel)
        
        AdminServer.LogAction(src, 'Set Ped', targetId, 'Changed ' .. targetName .. "'s ped to " .. pedModel, 'info')
        TriggerClientEvent('adminpanel:client:notify', src, locale('ped_changed_player', targetName, pedModel), 'success')
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Set Routing Bucket
RegisterNetEvent('adminpanel:server:setRoutingBucket', function(targetId, bucket)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    bucket = tonumber(bucket) or 0
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        SetPlayerRoutingBucket(targetId, bucket)
        
        AdminServer.LogAction(src, 'Set Bucket', targetId, 'Set ' .. targetName .. "'s routing bucket to " .. bucket, 'info')
        TriggerClientEvent('adminpanel:client:notify', src, locale('bucket_set_player', targetName, bucket), 'success')
        TriggerClientEvent('adminpanel:client:notify', targetId, locale('bucket_moved', bucket), 'info')
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Spectate Player
RegisterNetEvent('adminpanel:server:spectatePlayer', function(targetId, spectate)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        
        if spectate then
            TriggerClientEvent('adminpanel:client:startSpectate', src, targetId)
            AdminServer.LogAction(src, 'Spectate', targetId, 'Started spectating ' .. targetName, 'info')
        else
            TriggerClientEvent('adminpanel:client:stopSpectate', src)
            AdminServer.LogAction(src, 'Stop Spectate', targetId, 'Stopped spectating ' .. targetName, 'info')
        end
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Give Clothing Menu
RegisterNetEvent('adminpanel:server:giveClothingMenu', function(targetId)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        local targetName = AdminServer.GetTargetName(targetId)
        
        local success, err = Bridge.OpenClothingMenuForPlayer(targetId)
        if success then
            AdminServer.LogAction(src, 'Give Clothing', targetId, 'Opened clothing menu for ' .. targetName, 'info')
            TriggerClientEvent('adminpanel:client:notify', src, locale('clothing_menu_opened', targetName), 'success')
        else
            TriggerClientEvent('adminpanel:client:notify', src, locale('clothing_not_found'), 'error')
        end
    else
        TriggerClientEvent('adminpanel:client:notify', src, locale('player_not_found'), 'error')
    end
end)

-- Revive Player in Radius (helper)
RegisterNetEvent('adminpanel:server:revivePlayerInRadius', function(targetId)
    local src = source
    targetId = tonumber(targetId)
    local Target = Bridge.GetPlayer(targetId)
    
    if Target then
        -- Use hospital/ambulance job resource if available
        if GetResourceState('hospital') == 'started' then
            TriggerClientEvent('hospital:client:Revive', targetId)
        elseif GetResourceState('qb-ambulancejob') == 'started' then
            TriggerClientEvent('hospital:client:Revive', targetId)
        elseif GetResourceState('esx_ambulancejob') == 'started' then
            TriggerClientEvent('esx_ambulancejob:revive', targetId)
        else
            TriggerClientEvent('adminpanel:client:revive', targetId)
        end
    end
end)

print('^2[AdminPanel]^0 Players module loaded!')
