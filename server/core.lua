-- Server Panel State
AdminServer = AdminServer or {}
AdminServer.AdminLogs = {}
AdminServer.mutedPlayers = {}

-- Debug function
function AdminServer.Debug(...)
    if Config.Debug then
        print('[AdminPanel:Server]', ...)
    end
end

-- Get player's highest permission level
function AdminServer.GetPlayerPermissionLevel(source)
    local Player = Bridge.GetPlayer(source)
    if not Player then return 0 end
    
    -- Check for ace command (usually god/owner)
    if IsPlayerAceAllowed(source, 'command') then
        return Config.PermissionLevels['god'] or 3
    end
    
    -- Check each permission level from highest to lowest
    local highestLevel = 0
    for permission, level in pairs(Config.PermissionLevels) do
        if Bridge.HasPermission(source, permission) then
            if level > highestLevel then
                highestLevel = level
            end
        end
    end
    
    return highestLevel
end

-- Check if player has specific permission level
function AdminServer.HasPermissionLevel(source, requiredPermission)
    local playerLevel = AdminServer.GetPlayerPermissionLevel(source)
    local requiredLevel = Config.PermissionLevels[requiredPermission] or 0
    return playerLevel >= requiredLevel
end

-- Check if player has admin permission (legacy function for basic access)
function AdminServer.HasPermission(source, permission)
    permission = permission or Config.RequiredPermission
    local Player = Bridge.GetPlayer(source)
    if not Player then return false end
    
    return Bridge.HasPermission(source, permission) or IsPlayerAceAllowed(source, 'command')
end

-- Check feature permission
function AdminServer.HasFeaturePermission(source, category, feature)
    if not Config.FeaturePermissions[category] then return false end
    if not Config.FeaturePermissions[category][feature] then return false end
    
    local requiredPermission = Config.FeaturePermissions[category][feature]
    return AdminServer.HasPermissionLevel(source, requiredPermission)
end

-- Get all allowed features for a player
function AdminServer.GetPlayerFeatures(source)
    local features = {}
    local playerLevel = AdminServer.GetPlayerPermissionLevel(source)
    
    for category, categoryFeatures in pairs(Config.FeaturePermissions) do
        features[category] = {}
        for feature, permission in pairs(categoryFeatures) do
            local requiredLevel = Config.PermissionLevels[permission] or 0
            features[category][feature] = playerLevel >= requiredLevel
        end
    end
    
    return features
end

-- Get admin name
function AdminServer.GetAdminName(source)
    local Player = Bridge.GetPlayer(source)
    if Player then
        local charinfo = Bridge.GetCharInfo(Player)
        return charinfo.firstname .. ' ' .. charinfo.lastname .. ' (ID: ' .. source .. ')'
    end
    return 'Unknown Admin (ID: ' .. source .. ')'
end

-- Get target name
function AdminServer.GetTargetName(targetId)
    local Player = Bridge.GetPlayer(tonumber(targetId))
    if Player then
        local charinfo = Bridge.GetCharInfo(Player)
        return charinfo.firstname .. ' ' .. charinfo.lastname .. ' (ID: ' .. targetId .. ')'
    end
    return 'Unknown Player (ID: ' .. targetId .. ')'
end

-- Get all players data
function AdminServer.GetPlayersData()
    return Bridge.GetPlayersData()
end

-- Callbacks
Bridge.CreateCallback('adminpanel:server:hasPermission', function(source, cb)
    local hasAccess = AdminServer.HasPermission(source)
    local features = hasAccess and AdminServer.GetPlayerFeatures(source) or {}
    cb(hasAccess, features)
end)

Bridge.CreateCallback('adminpanel:server:getPlayers', function(source, cb)
    if not AdminServer.HasPermission(source) then
        cb({})
        return
    end
    cb(AdminServer.GetPlayersData())
end)

Bridge.CreateCallback('adminpanel:server:getFeatures', function(source, cb)
    if not AdminServer.HasPermission(source) then
        cb({})
        return
    end
    cb(AdminServer.GetPlayerFeatures(source))
end)

Bridge.CreateCallback('adminpanel:server:getLogs', function(source, cb)
    if not AdminServer.HasPermission(source) then
        cb({})
        return
    end
    cb(AdminServer.AdminLogs)
end)

-- Player joined - update admin panels
RegisterNetEvent('adminpanel:server:playerLoaded', function()
    local src = source
    Citizen.SetTimeout(1000, function()
        local admins = Bridge.GetPlayers()
        for _, adminId in ipairs(admins) do
            if AdminServer.HasPermission(adminId) then
                TriggerClientEvent('adminpanel:client:updatePlayers', adminId, AdminServer.GetPlayersData())
            end
        end
    end)
end)

-- Listen for QBCore/ESX player loaded
if Bridge.Framework == 'qb' then
    AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
        TriggerEvent('adminpanel:server:playerLoaded')
    end)
elseif Bridge.Framework == 'esx' then
    AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
        TriggerEvent('adminpanel:server:playerLoaded')
    end)
end

-- Player left - update admin panels
AddEventHandler('playerDropped', function(reason)
    local src = source
    Citizen.SetTimeout(1000, function()
        local admins = Bridge.GetPlayers()
        for _, adminId in ipairs(admins) do
            if AdminServer.HasPermission(adminId) then
                TriggerClientEvent('adminpanel:client:updatePlayers', adminId, AdminServer.GetPlayersData())
            end
        end
    end)
end)

-- Export functions
exports('HasPermission', AdminServer.HasPermission)
exports('GetPlayersData', AdminServer.GetPlayersData)

print('^2[AdminPanel]^0 Core module loaded!')
