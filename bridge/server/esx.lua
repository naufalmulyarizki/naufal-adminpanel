-- ESX Server Bridge
if Bridge.Framework ~= 'esx' then return end

local ESX = exports['es_extended']:getSharedObject()

-- Get Player
function Bridge.GetPlayer(source)
    return ESX.GetPlayerFromId(source)
end

-- Get Player Identifier
function Bridge.GetPlayerIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.identifier
    end
    return nil
end

-- Get Player ID from player object (identifier for ESX)
function Bridge.GetPlayerId(xPlayer)
    if xPlayer then
        return xPlayer.identifier
    end
    return nil
end

-- Get Character Info from player object
function Bridge.GetCharInfo(xPlayer)
    if xPlayer then
        local name = xPlayer.getName() or 'Unknown Player'
        local parts = {}
        for part in string.gmatch(name, "%S+") do
            table.insert(parts, part)
        end
        return {
            firstname = parts[1] or 'Unknown',
            lastname = parts[2] or 'Player'
        }
    end
    return { firstname = 'Unknown', lastname = 'Player' }
end

-- Get Player Identifiers (license, discord, ip)
function Bridge.GetPlayerIdentifiers(xPlayer)
    if xPlayer then
        local identifiers = GetPlayerIdentifiers(xPlayer.source)
        local result = { license = '', discord = '', ip = '' }
        
        for _, v in pairs(identifiers) do
            if string.sub(v, 1, 8) == 'license:' then
                result.license = v
            elseif string.sub(v, 1, 8) == 'discord:' then
                result.discord = v
            elseif string.sub(v, 1, 3) == 'ip:' then
                result.ip = v
            end
        end
        
        return result
    end
    return { license = '', discord = '', ip = '' }
end

-- Get Player Name
function Bridge.GetPlayerName(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.getName()
    end
    return 'Unknown'
end

-- Get All Players
function Bridge.GetPlayers()
    local players = {}
    local xPlayers = ESX.GetExtendedPlayers()
    for _, xPlayer in pairs(xPlayers) do
        table.insert(players, xPlayer.source)
    end
    return players
end

-- Get Players Data (for admin panel)
function Bridge.GetPlayersData()
    local players = {}
    local xPlayers = ESX.GetExtendedPlayers()
    
    for _, xPlayer in pairs(xPlayers) do
        table.insert(players, {
            id = xPlayer.source,
            name = xPlayer.getName(),
            identifier = xPlayer.identifier,
            license = xPlayer.identifier,
            money = xPlayer.getMoney() or 0,
            bank = xPlayer.getAccount('bank').money or 0,
            job = xPlayer.job.name or 'unemployed'
        })
    end
    
    return players
end

-- Has Permission
function Bridge.HasPermission(source, permission)
    permission = permission or Config.RequiredPermission
    
    -- Check ACE permissions
    if IsPlayerAceAllowed(source, 'command') then
        return true
    end
    
    -- Check ESX admin permission
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        -- Check if player has admin job or group
        if xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin' then
            return true
        end
        
        -- Check specific permission
        if IsPlayerAceAllowed(source, 'adminpanel.' .. permission) then
            return true
        end
    end
    
    return false
end

-- Get Permission Level
function Bridge.GetPermissionLevel(source)
    if IsPlayerAceAllowed(source, 'command') then
        return Config.PermissionLevels['god'] or 3
    end
    
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local group = xPlayer.getGroup()
        if group == 'superadmin' or group == 'god' then
            return Config.PermissionLevels['god'] or 3
        elseif group == 'admin' then
            return Config.PermissionLevels['admin'] or 2
        elseif group == 'mod' then
            return Config.PermissionLevels['mod'] or 1
        end
    end
    
    return 0
end

-- Create Callback
function Bridge.CreateCallback(name, cb)
    ESX.RegisterServerCallback(name, cb)
end

-- Send Notification to Client
function Bridge.NotifyClient(source, message, type, duration)
    TriggerClientEvent('adminpanel:client:notify', source, message, type)
end

-- Add Money (accepts xPlayer object or source)
function Bridge.AddMoney(playerOrSource, moneyType, amount, reason)
    local xPlayer = type(playerOrSource) == 'table' and playerOrSource or ESX.GetPlayerFromId(playerOrSource)
    if xPlayer then
        if moneyType == 'cash' or moneyType == 'money' then
            xPlayer.addMoney(amount, reason)
        elseif moneyType == 'bank' then
            xPlayer.addAccountMoney('bank', amount, reason)
        end
        return true
    end
    return false
end

-- Remove Money (accepts xPlayer object or source)
function Bridge.RemoveMoney(playerOrSource, moneyType, amount, reason)
    local xPlayer = type(playerOrSource) == 'table' and playerOrSource or ESX.GetPlayerFromId(playerOrSource)
    if xPlayer then
        if moneyType == 'cash' or moneyType == 'money' then
            xPlayer.removeMoney(amount, reason)
        elseif moneyType == 'bank' then
            xPlayer.removeAccountMoney('bank', amount, reason)
        end
        return true
    end
    return false
end

-- Add Item (accepts xPlayer object or source)
function Bridge.AddItem(playerOrSource, itemName, amount, targetId)
    local source = targetId or (type(playerOrSource) == 'number' and playerOrSource or nil)
    local xPlayer = type(playerOrSource) == 'table' and playerOrSource or ESX.GetPlayerFromId(playerOrSource)
    
    if xPlayer then
        source = source or xPlayer.source
        if GetResourceState('ox_inventory') == 'started' then
            return exports.ox_inventory:AddItem(source, itemName, amount)
        else
            xPlayer.addInventoryItem(itemName, amount)
            return true
        end
    end
    return false
end

-- Remove Item (accepts xPlayer object or source)
function Bridge.RemoveItem(playerOrSource, itemName, amount)
    local xPlayer = type(playerOrSource) == 'table' and playerOrSource or ESX.GetPlayerFromId(playerOrSource)
    if xPlayer then
        local source = xPlayer.source
        if GetResourceState('ox_inventory') == 'started' then
            return exports.ox_inventory:RemoveItem(source, itemName, amount)
        else
            xPlayer.removeInventoryItem(itemName, amount)
            return true
        end
    end
    return false
end

-- Clear Inventory (accepts xPlayer object or source)
function Bridge.ClearInventory(playerOrSource, targetId)
    local source = targetId or (type(playerOrSource) == 'number' and playerOrSource or nil)
    local xPlayer = type(playerOrSource) == 'table' and playerOrSource or ESX.GetPlayerFromId(playerOrSource)
    
    if xPlayer then
        source = source or xPlayer.source
        if GetResourceState('ox_inventory') == 'started' then
            exports.ox_inventory:ClearInventory(source)
        else
            -- ESX inventory clear
            local inventory = xPlayer.getInventory()
            for _, item in pairs(inventory) do
                if item.count > 0 then
                    xPlayer.removeInventoryItem(item.name, item.count)
                end
            end
        end
        return true
    end
    return false
end

-- Set Job (accepts xPlayer object or source)
function Bridge.SetJob(playerOrSource, jobName, grade)
    local xPlayer = type(playerOrSource) == 'table' and playerOrSource or ESX.GetPlayerFromId(playerOrSource)
    if xPlayer then
        xPlayer.setJob(jobName, grade or 0)
        return true
    end
    return false
end

-- Set Metadata (accepts xPlayer object or source)
function Bridge.SetMetaData(playerOrSource, key, value)
    local xPlayer = type(playerOrSource) == 'table' and playerOrSource or ESX.GetPlayerFromId(playerOrSource)
    if xPlayer then
        local source = xPlayer.source
        -- For stress, trigger client event
        if key == 'stress' then
            TriggerClientEvent('esx_status:set', source, 'stress', value * 10000)
        end
        return true
    end
    return false
end

-- Revive Player
function Bridge.RevivePlayer(source)
    -- Try different ambulance/death resources
    if GetResourceState('esx_ambulancejob') == 'started' then
        TriggerClientEvent('esx_ambulancejob:revive', source)
    elseif GetResourceState('wasabi_ambulance') == 'started' then
        TriggerClientEvent('wasabi_ambulance:revive', source)
    else
        TriggerClientEvent('esx:onPlayerSpawn', source)
    end
end

-- Kick Player
function Bridge.KickPlayer(source, reason)
    DropPlayer(source, reason or 'Kicked by admin')
end

-- Ban Player
function Bridge.BanPlayer(source, reason, duration, adminSource)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local banExpiry = duration > 0 and os.time() + (duration * 60) or 2147483647
        
        -- Insert ban to database (ESX compatible)
        MySQL.insert('INSERT INTO bans (identifier, reason, expire, banner) VALUES (?, ?, ?, ?)', {
            xPlayer.identifier,
            reason,
            banExpiry,
            Bridge.GetPlayerName(adminSource) .. ' (ID: ' .. adminSource .. ')'
        }, function()
            DropPlayer(source, reason)
        end)
        
        return true
    end
    return false
end

-- Mute Player (pma-voice)
function Bridge.MutePlayer(source, muted)
    if GetResourceState('pma-voice') == 'started' then
        exports['pma-voice']:setPlayerMuted(source, muted)
        return true
    elseif GetResourceState('mumble-voip') == 'started' then
        -- Alternative voice system
        TriggerClientEvent('mumble:SetMuted', source, muted)
        return true
    end
    return false
end

print('^2[AdminPanel]^0 ESX server bridge loaded!')
