-- Bridge Server - Inventory System
-- Supports: ox_inventory, qb-inventory, qs-inventory, codem-inventory, origen_inventory

Bridge = Bridge or {}
Bridge.InventoryResource = nil

-- Detect inventory resource
local function DetectInventory()
    if Config.Inventory ~= 'auto' then
        if GetResourceState(Config.Inventory) == 'started' then
            Bridge.InventoryResource = Config.Inventory
            return
        end
    end
    
    -- Auto-detect
    local inventories = {
        'ox_inventory',
        'qb-inventory',
        'qs-inventory',
        'codem-inventory',
        'origen_inventory'
    }
    
    for _, inv in ipairs(inventories) do
        if GetResourceState(inv) == 'started' then
            Bridge.InventoryResource = inv
            break
        end
    end
end

CreateThread(function()
    DetectInventory()
    if Bridge.InventoryResource then
        print('^2[AdminPanel]^0 Detected inventory: ^3' .. Bridge.InventoryResource .. '^0')
    else
        print('^3[AdminPanel]^0 No inventory resource detected')
    end
end)

-- Get inventory resource name
function Bridge.GetInventoryResource()
    return Bridge.InventoryResource
end

-- Check if inventory is available
function Bridge.HasInventory()
    return Bridge.InventoryResource ~= nil
end

-- Force open player inventory (admin action)
function Bridge.ForceOpenPlayerInventory(adminSource, targetSource)
    if not Bridge.InventoryResource then
        return false, 'inventory_not_found'
    end
    
    local targetId = tonumber(targetSource)
    
    if Bridge.InventoryResource == 'ox_inventory' then
        local identifier = Bridge.GetPlayerId(Bridge.GetPlayer(targetId))
        exports.ox_inventory:forceOpenInventory(adminSource, 'player', identifier)
        return true
    elseif Bridge.InventoryResource == 'qb-inventory' then
        exports['qb-inventory']:OpenInventory(adminSource, targetId)
        return true
    elseif Bridge.InventoryResource == 'qs-inventory' then
        exports['qs-inventory']:OpenPlayerInventory(adminSource, targetId)
        return true
    elseif Bridge.InventoryResource == 'codem-inventory' then
        exports['codem-inventory']:OpenPlayerInventory(adminSource, targetId)
        return true
    elseif Bridge.InventoryResource == 'origen_inventory' then
        exports.origen_inventory:openPlayerInventory(adminSource, targetId)
        return true
    end
    
    return false, 'inventory_not_supported'
end

-- Force open stash (admin action)
function Bridge.ForceOpenStash(adminSource, stashId)
    if not Bridge.InventoryResource then
        return false, 'inventory_not_found'
    end
    
    if Bridge.InventoryResource == 'ox_inventory' then
        exports.ox_inventory:forceOpenInventory(adminSource, 'stash', stashId)
        return true
    elseif Bridge.InventoryResource == 'qb-inventory' then
        TriggerClientEvent('inventory:client:OpenInventory', adminSource, 'stash', stashId)
        return true
    elseif Bridge.InventoryResource == 'qs-inventory' then
        TriggerClientEvent('qs-inventory:client:openInventory', adminSource, 'stash', stashId)
        return true
    elseif Bridge.InventoryResource == 'codem-inventory' then
        TriggerClientEvent('codem-inventory:client:OpenStash', adminSource, stashId)
        return true
    elseif Bridge.InventoryResource == 'origen_inventory' then
        exports.origen_inventory:forceOpenInventory(adminSource, 'stash', stashId)
        return true
    end
    
    return false, 'inventory_not_supported'
end

-- Force open trunk (admin action)
function Bridge.ForceOpenTrunk(adminSource, plate)
    if not Bridge.InventoryResource then
        return false, 'inventory_not_found'
    end
    
    local trunkId = 'trunk_' .. plate:gsub('%s+', '')
    
    if Bridge.InventoryResource == 'ox_inventory' then
        exports.ox_inventory:forceOpenInventory(adminSource, 'trunk', trunkId)
        return true
    elseif Bridge.InventoryResource == 'qb-inventory' then
        TriggerClientEvent('inventory:client:OpenInventory', adminSource, 'trunk', plate)
        return true
    elseif Bridge.InventoryResource == 'qs-inventory' then
        TriggerClientEvent('qs-inventory:client:openInventory', adminSource, 'trunk', plate)
        return true
    elseif Bridge.InventoryResource == 'codem-inventory' then
        TriggerClientEvent('codem-inventory:client:OpenTrunk', adminSource, plate)
        return true
    elseif Bridge.InventoryResource == 'origen_inventory' then
        exports.origen_inventory:forceOpenInventory(adminSource, 'trunk', plate)
        return true
    end
    
    return false, 'inventory_not_supported'
end

-- Clear player inventory
function Bridge.ClearPlayerInventory(targetSource)
    if not Bridge.InventoryResource then
        return false, 'inventory_not_found'
    end
    
    local targetId = tonumber(targetSource)
    
    if Bridge.InventoryResource == 'ox_inventory' then
        exports.ox_inventory:ClearInventory(targetId)
        return true
    elseif Bridge.InventoryResource == 'qb-inventory' then
        exports['qb-inventory']:ClearInventory(targetId)
        return true
    elseif Bridge.InventoryResource == 'qs-inventory' then
        exports['qs-inventory']:ClearInventory(targetId)
        return true
    elseif Bridge.InventoryResource == 'codem-inventory' then
        exports['codem-inventory']:ClearInventory(targetId)
        return true
    elseif Bridge.InventoryResource == 'origen_inventory' then
        exports.origen_inventory:clearInventory(targetId)
        return true
    end
    
    return false, 'inventory_not_supported'
end

-- Add item to player
function Bridge.AddItemToPlayer(targetSource, itemName, amount, metadata)
    if not Bridge.InventoryResource then
        return false, 'inventory_not_found'
    end
    
    local targetId = tonumber(targetSource)
    amount = tonumber(amount) or 1
    
    if Bridge.InventoryResource == 'ox_inventory' then
        return exports.ox_inventory:AddItem(targetId, itemName, amount, metadata)
    elseif Bridge.InventoryResource == 'qb-inventory' then
        return exports['qb-inventory']:AddItem(targetId, itemName, amount, false, metadata)
    elseif Bridge.InventoryResource == 'qs-inventory' then
        return exports['qs-inventory']:AddItem(targetId, itemName, amount, metadata)
    elseif Bridge.InventoryResource == 'codem-inventory' then
        return exports['codem-inventory']:AddItem(targetId, itemName, amount, metadata)
    elseif Bridge.InventoryResource == 'origen_inventory' then
        return exports.origen_inventory:addItem(targetId, itemName, amount, metadata)
    end
    
    return false, 'inventory_not_supported'
end

-- Remove item from player
function Bridge.RemoveItemFromPlayer(targetSource, itemName, amount)
    if not Bridge.InventoryResource then
        return false, 'inventory_not_found'
    end
    
    local targetId = tonumber(targetSource)
    amount = tonumber(amount) or 1
    
    if Bridge.InventoryResource == 'ox_inventory' then
        return exports.ox_inventory:RemoveItem(targetId, itemName, amount)
    elseif Bridge.InventoryResource == 'qb-inventory' then
        return exports['qb-inventory']:RemoveItem(targetId, itemName, amount)
    elseif Bridge.InventoryResource == 'qs-inventory' then
        return exports['qs-inventory']:RemoveItem(targetId, itemName, amount)
    elseif Bridge.InventoryResource == 'codem-inventory' then
        return exports['codem-inventory']:RemoveItem(targetId, itemName, amount)
    elseif Bridge.InventoryResource == 'origen_inventory' then
        return exports.origen_inventory:removeItem(targetId, itemName, amount)
    end
    
    return false, 'inventory_not_supported'
end

-- Get all items in server
function Bridge.GetAllItems()
    if not Bridge.InventoryResource then
        return {}
    end
    
    if Bridge.InventoryResource == 'ox_inventory' then
        local items = exports.ox_inventory:Items()
        local result = {}
        for name, data in pairs(items or {}) do
            table.insert(result, {
                name = name,
                label = data.label or name,
                weight = data.weight or 0
            })
        end
        return result
    elseif Bridge.InventoryResource == 'qb-inventory' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local items = QBCore.Shared.Items
        local result = {}
        for name, data in pairs(items or {}) do
            table.insert(result, {
                name = name,
                label = data.label or name,
                weight = data.weight or 0
            })
        end
        return result
    elseif Bridge.InventoryResource == 'qs-inventory' then
        return exports['qs-inventory']:GetItemList() or {}
    end
    
    return {}
end

print('^2[AdminPanel]^0 Inventory bridge (server) loaded!')
