-- Bridge Server - Clothing/Appearance System
-- Supports: illenium-appearance, fivem-appearance, qb-clothing, esx_skin, skinchanger

Bridge = Bridge or {}
Bridge.ClothingResource = nil

-- Detect clothing resource
local function DetectClothing()
    if Config.Clothing ~= 'auto' then
        if GetResourceState(Config.Clothing) == 'started' then
            Bridge.ClothingResource = Config.Clothing
            return
        end
    end
    
    -- Auto-detect
    local clothings = {
        'illenium-appearance',
        'fivem-appearance',
        'qb-clothing',
        'esx_skin',
        'skinchanger'
    }
    
    for _, cloth in ipairs(clothings) do
        if GetResourceState(cloth) == 'started' then
            Bridge.ClothingResource = cloth
            break
        end
    end
end

CreateThread(function()
    DetectClothing()
    if Bridge.ClothingResource then
        print('^2[AdminPanel]^0 Detected clothing: ^3' .. Bridge.ClothingResource .. '^0')
    else
        print('^3[AdminPanel]^0 No clothing resource detected')
    end
end)

-- Get clothing resource name
function Bridge.GetClothingResource()
    return Bridge.ClothingResource
end

-- Check if clothing is available
function Bridge.HasClothing()
    return Bridge.ClothingResource ~= nil
end

-- Open clothing menu for target player (admin action)
function Bridge.OpenClothingMenuForPlayer(targetSource)
    if not Bridge.ClothingResource then
        return false, 'no_clothing_resource'
    end
    
    local targetId = tonumber(targetSource)
    
    if Bridge.ClothingResource == 'illenium-appearance' then
        TriggerClientEvent('illenium-appearance:client:openClothingShop', targetId)
        return true
    elseif Bridge.ClothingResource == 'fivem-appearance' then
        TriggerClientEvent('fivem-appearance:client:openClothingShop', targetId)
        return true
    elseif Bridge.ClothingResource == 'qb-clothing' then
        TriggerClientEvent('qb-clothing:client:openMenu', targetId)
        return true
    elseif Bridge.ClothingResource == 'esx_skin' then
        TriggerClientEvent('esx_skin:openMenu', targetId)
        return true
    elseif Bridge.ClothingResource == 'skinchanger' then
        TriggerClientEvent('skinchanger:openMenu', targetId)
        return true
    end
    
    return false, 'clothing_not_supported'
end

-- Open outfits menu for target player
function Bridge.OpenOutfitsMenuForPlayer(targetSource)
    if not Bridge.ClothingResource then
        return false, 'no_clothing_resource'
    end
    
    local targetId = tonumber(targetSource)
    
    if Bridge.ClothingResource == 'illenium-appearance' then
        TriggerClientEvent('illenium-appearance:client:openOutfitsMenu', targetId)
        return true
    elseif Bridge.ClothingResource == 'fivem-appearance' then
        TriggerClientEvent('fivem-appearance:client:openOutfitsMenu', targetId)
        return true
    elseif Bridge.ClothingResource == 'qb-clothing' then
        TriggerClientEvent('qb-clothing:client:openOutfitMenu', targetId)
        return true
    end
    
    return false, 'clothing_not_supported'
end

-- Open barber menu for target player
function Bridge.OpenBarberMenuForPlayer(targetSource)
    if not Bridge.ClothingResource then
        return false, 'no_clothing_resource'
    end
    
    local targetId = tonumber(targetSource)
    
    if Bridge.ClothingResource == 'illenium-appearance' then
        TriggerClientEvent('illenium-appearance:client:openBarberMenu', targetId)
        return true
    elseif Bridge.ClothingResource == 'fivem-appearance' then
        TriggerClientEvent('fivem-appearance:client:openBarberMenu', targetId)
        return true
    elseif Bridge.ClothingResource == 'qb-clothing' then
        TriggerClientEvent('qb-clothing:client:openBarber', targetId)
        return true
    elseif Bridge.ClothingResource == 'esx_skin' then
        TriggerClientEvent('esx_skin:openBarberMenu', targetId)
        return true
    end
    
    return false, 'clothing_not_supported'
end

print('^2[AdminPanel]^0 Clothing bridge (server) loaded!')
