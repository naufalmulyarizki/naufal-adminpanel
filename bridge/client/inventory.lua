-- Bridge Client - Inventory System
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

-- Open stash by ID (client-side)
function Bridge.OpenStash(stashId)
    if not Bridge.InventoryResource then
        Bridge.Notify(locale('inventory_not_found'), 'error')
        return false
    end
    
    if Bridge.InventoryResource == 'ox_inventory' then
        exports.ox_inventory:openInventory('stash', stashId)
        return true
    elseif Bridge.InventoryResource == 'qb-inventory' then
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', stashId)
        return true
    elseif Bridge.InventoryResource == 'qs-inventory' then
        TriggerServerEvent('qs-inventory:server:openInventory', 'stash', stashId)
        return true
    elseif Bridge.InventoryResource == 'codem-inventory' then
        exports['codem-inventory']:OpenStash(stashId)
        return true
    elseif Bridge.InventoryResource == 'origen_inventory' then
        exports.origen_inventory:openInventory('stash', stashId)
        return true
    end
    
    return false
end

-- Open trunk by plate (client-side)
function Bridge.OpenTrunk(plate)
    if not Bridge.InventoryResource then
        Bridge.Notify(locale('inventory_not_found'), 'error')
        return false
    end
    
    local trunkId = plate:gsub('%s+', '')
    
    if Bridge.InventoryResource == 'ox_inventory' then
        exports.ox_inventory:openInventory('trunk', trunkId)
        return true
    elseif Bridge.InventoryResource == 'qb-inventory' then
        TriggerServerEvent('inventory:server:OpenInventory', 'trunk', trunkId)
        return true
    elseif Bridge.InventoryResource == 'qs-inventory' then
        TriggerServerEvent('qs-inventory:server:openInventory', 'trunk', trunkId)
        return true
    elseif Bridge.InventoryResource == 'codem-inventory' then
        exports['codem-inventory']:OpenTrunk(trunkId)
        return true
    elseif Bridge.InventoryResource == 'origen_inventory' then
        exports.origen_inventory:openInventory('trunk', trunkId)
        return true
    end
    
    return false
end

-- Open glovebox by plate (client-side)
function Bridge.OpenGlovebox(plate)
    if not Bridge.InventoryResource then
        Bridge.Notify(locale('inventory_not_found'), 'error')
        return false
    end
    
    local gloveboxId = plate:gsub('%s+', '')
    
    if Bridge.InventoryResource == 'ox_inventory' then
        exports.ox_inventory:openInventory('glovebox', gloveboxId)
        return true
    elseif Bridge.InventoryResource == 'qb-inventory' then
        TriggerServerEvent('inventory:server:OpenInventory', 'glovebox', gloveboxId)
        return true
    elseif Bridge.InventoryResource == 'qs-inventory' then
        TriggerServerEvent('qs-inventory:server:openInventory', 'glovebox', gloveboxId)
        return true
    elseif Bridge.InventoryResource == 'codem-inventory' then
        exports['codem-inventory']:OpenGlovebox(gloveboxId)
        return true
    elseif Bridge.InventoryResource == 'origen_inventory' then
        exports.origen_inventory:openInventory('glovebox', gloveboxId)
        return true
    end
    
    return false
end

-- Search item count (client-side)
function Bridge.GetItemCount(itemName)
    if not Bridge.InventoryResource then
        return 0
    end
    
    if Bridge.InventoryResource == 'ox_inventory' then
        return exports.ox_inventory:Search('count', itemName) or 0
    elseif Bridge.InventoryResource == 'qb-inventory' then
        local item = exports['qb-inventory']:GetItemByName(itemName)
        return item and item.amount or 0
    elseif Bridge.InventoryResource == 'qs-inventory' then
        return exports['qs-inventory']:GetItemTotalAmount(itemName) or 0
    elseif Bridge.InventoryResource == 'codem-inventory' then
        return exports['codem-inventory']:GetItemCount(itemName) or 0
    elseif Bridge.InventoryResource == 'origen_inventory' then
        return exports.origen_inventory:getItemCount(itemName) or 0
    end
    
    return 0
end

-- Check if has item
function Bridge.HasItem(itemName, amount)
    amount = amount or 1
    return Bridge.GetItemCount(itemName) >= amount
end

print('^2[AdminPanel]^0 Inventory bridge (client) loaded!')
