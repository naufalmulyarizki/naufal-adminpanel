-- QBCore Server Bridge
if Bridge.Framework ~= 'qb' then return end

local QBCore = exports['qb-core']:GetCoreObject()

-- Get Player
function Bridge.GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

-- Get Player Identifier (citizenid)
function Bridge.GetPlayerIdentifier(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.citizenid
    end
    return nil
end

-- Get Player ID from player object (citizenid for QBCore)
function Bridge.GetPlayerId(Player)
    if Player and Player.PlayerData then
        return Player.PlayerData.citizenid
    end
    return nil
end

-- Get Character Info from player object
function Bridge.GetCharInfo(Player)
    if Player and Player.PlayerData and Player.PlayerData.charinfo then
        return Player.PlayerData.charinfo
    end
    return { firstname = 'Unknown', lastname = 'Player' }
end

-- Get Player Identifiers (license, discord, ip)
function Bridge.GetPlayerIdentifiers(Player)
    if Player and Player.PlayerData then
        return {
            license = Player.PlayerData.license or '',
            discord = Player.PlayerData.discord or '',
            ip = Player.PlayerData.ip or ''
        }
    end
    return { license = '', discord = '', ip = '' }
end

-- Get Player Name
function Bridge.GetPlayerName(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    end
    return 'Unknown'
end

-- Get All Players
function Bridge.GetPlayers()
    return QBCore.Functions.GetPlayers()
end

-- Get Players Data (for admin panel)
function Bridge.GetPlayersData()
    local players = {}
    local qbPlayers = QBCore.Functions.GetPlayers()
    
    for _, playerId in ipairs(qbPlayers) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            table.insert(players, {
                id = playerId,
                name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                identifier = Player.PlayerData.citizenid,
                license = Player.PlayerData.license or 'Unknown',
                money = Player.PlayerData.money.cash or 0,
                bank = Player.PlayerData.money.bank or 0,
                job = Player.PlayerData.job.name or 'unemployed'
            })
        end
    end
    
    return players
end

-- Has Permission
function Bridge.HasPermission(source, permission)
    permission = permission or Config.RequiredPermission
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    return QBCore.Functions.HasPermission(source, permission) or IsPlayerAceAllowed(source, 'command')
end

-- Get Permission Level
function Bridge.GetPermissionLevel(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return 0 end
    
    if IsPlayerAceAllowed(source, 'command') then
        return Config.PermissionLevels['god'] or 3
    end
    
    local highestLevel = 0
    for permission, level in pairs(Config.PermissionLevels) do
        if QBCore.Functions.HasPermission(source, permission) then
            if level > highestLevel then
                highestLevel = level
            end
        end
    end
    
    return highestLevel
end

-- Create Callback
function Bridge.CreateCallback(name, cb)
    QBCore.Functions.CreateCallback(name, cb)
end

-- Send Notification to Client
function Bridge.NotifyClient(source, message, type, duration)
    TriggerClientEvent('adminpanel:client:notify', source, message, type)
end

-- Add Money (accepts Player object or source)
function Bridge.AddMoney(playerOrSource, moneyType, amount, reason)
    local Player = type(playerOrSource) == 'table' and playerOrSource or QBCore.Functions.GetPlayer(playerOrSource)
    if Player then
        if moneyType == 'cash' or moneyType == 'money' then
            Player.Functions.AddMoney('cash', amount, reason or 'admin-panel')
        elseif moneyType == 'bank' then
            Player.Functions.AddMoney('bank', amount, reason or 'admin-panel')
        end
        return true
    end
    return false
end

-- Remove Money (accepts Player object or source)
function Bridge.RemoveMoney(playerOrSource, moneyType, amount, reason)
    local Player = type(playerOrSource) == 'table' and playerOrSource or QBCore.Functions.GetPlayer(playerOrSource)
    if Player then
        if moneyType == 'cash' or moneyType == 'money' then
            Player.Functions.RemoveMoney('cash', amount, reason or 'admin-panel')
        elseif moneyType == 'bank' then
            Player.Functions.RemoveMoney('bank', amount, reason or 'admin-panel')
        end
        return true
    end
    return false
end

-- Add Item (accepts Player object or source)
function Bridge.AddItem(playerOrSource, itemName, amount, targetId)
    local source = targetId or (type(playerOrSource) == 'number' and playerOrSource or nil)
    local Player = type(playerOrSource) == 'table' and playerOrSource or QBCore.Functions.GetPlayer(playerOrSource)
    
    if Player then
        source = source or Player.PlayerData.source
        if GetResourceState('ox_inventory') == 'started' then
            return exports.ox_inventory:AddItem(source, itemName, amount)
        else
            local success = Player.Functions.AddItem(itemName, amount)
            if success then
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[itemName], 'add', amount)
            end
            return success
        end
    end
    return false
end

-- Remove Item (accepts Player object or source)
function Bridge.RemoveItem(playerOrSource, itemName, amount)
    local Player = type(playerOrSource) == 'table' and playerOrSource or QBCore.Functions.GetPlayer(playerOrSource)
    if Player then
        local source = Player.PlayerData.source
        if GetResourceState('ox_inventory') == 'started' then
            return exports.ox_inventory:RemoveItem(source, itemName, amount)
        else
            return Player.Functions.RemoveItem(itemName, amount)
        end
    end
    return false
end

-- Clear Inventory (accepts Player object or source)
function Bridge.ClearInventory(playerOrSource, targetId)
    local source = targetId or (type(playerOrSource) == 'number' and playerOrSource or nil)
    local Player = type(playerOrSource) == 'table' and playerOrSource or QBCore.Functions.GetPlayer(playerOrSource)
    
    if Player then
        source = source or Player.PlayerData.source
        if GetResourceState('ox_inventory') == 'started' then
            exports.ox_inventory:ClearInventory(source)
        else
            local items = Player.PlayerData.items
            for slot, item in pairs(items) do
                if item then
                    Player.Functions.RemoveItem(item.name, item.amount, slot)
                end
            end
        end
        return true
    end
    return false
end

-- Set Job (accepts Player object or source)
function Bridge.SetJob(playerOrSource, jobName, grade)
    local Player = type(playerOrSource) == 'table' and playerOrSource or QBCore.Functions.GetPlayer(playerOrSource)
    if Player then
        Player.Functions.SetJob(jobName, grade or 0)
        return true
    end
    return false
end

-- Set Metadata (accepts Player object or source)
function Bridge.SetMetaData(playerOrSource, key, value)
    local Player = type(playerOrSource) == 'table' and playerOrSource or QBCore.Functions.GetPlayer(playerOrSource)
    if Player then
        Player.Functions.SetMetaData(key, value)
        return true
    end
    return false
end

-- Revive Player
function Bridge.RevivePlayer(source)
    TriggerClientEvent('hospital:client:Revive', source)
end

-- Kick Player
function Bridge.KickPlayer(source, reason)
    DropPlayer(source, reason or 'Kicked by admin')
end

-- Ban Player
function Bridge.BanPlayer(source, reason, duration, adminSource)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local banExpiry = duration > 0 and os.time() + (duration * 60) or 2147483647
        
        local banData = {
            name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            license = Player.PlayerData.license,
            discord = Player.PlayerData.discord or '',
            ip = Player.PlayerData.ip or '',
            reason = reason,
            expire = banExpiry,
            bannedby = Bridge.GetPlayerName(adminSource) .. ' (ID: ' .. adminSource .. ')'
        }
        
        MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            banData.name,
            banData.license,
            banData.discord,
            banData.ip,
            banData.reason,
            banData.expire,
            banData.bannedby
        })
        
        DropPlayer(source, reason)
        return true
    end
    return false
end

-- Mute Player (pma-voice)
function Bridge.MutePlayer(source, muted)
    if GetResourceState('pma-voice') == 'started' then
        exports['pma-voice']:setPlayerMuted(source, muted)
        return true
    end
    return false
end

print('^2[AdminPanel]^0 QBCore server bridge loaded!')
