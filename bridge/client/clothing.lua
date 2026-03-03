-- Bridge Client - Clothing/Appearance System
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

-- Open clothing menu for self
function Bridge.OpenClothingMenu()
    if not Bridge.ClothingResource then
        Bridge.Notify(locale('no_clothing_resource'), 'error')
        return false
    end
    
    if Bridge.ClothingResource == 'illenium-appearance' then
        exports['illenium-appearance']:startPlayerCustomization(function(appearance)
            if appearance then
                TriggerServerEvent('illenium-appearance:server:saveAppearance', appearance)
            end
        end)
        return true
    elseif Bridge.ClothingResource == 'fivem-appearance' then
        exports['fivem-appearance']:startPlayerCustomization(function(appearance)
            if appearance then
                TriggerServerEvent('fivem-appearance:server:saveAppearance', appearance)
            end
        end)
        return true
    elseif Bridge.ClothingResource == 'qb-clothing' then
        TriggerEvent('qb-clothing:client:openMenu')
        return true
    elseif Bridge.ClothingResource == 'esx_skin' then
        TriggerEvent('esx_skin:openSaveableMenu')
        return true
    elseif Bridge.ClothingResource == 'skinchanger' then
        TriggerEvent('skinchanger:openMenu')
        return true
    end
    
    return false
end

-- Open outfits menu
function Bridge.OpenOutfitsMenu()
    if not Bridge.ClothingResource then
        Bridge.Notify(locale('no_clothing_resource'), 'error')
        return false
    end
    
    if Bridge.ClothingResource == 'illenium-appearance' then
        exports['illenium-appearance']:openOutfitsMenu()
        return true
    elseif Bridge.ClothingResource == 'fivem-appearance' then
        exports['fivem-appearance']:openOutfitsMenu()
        return true
    elseif Bridge.ClothingResource == 'qb-clothing' then
        TriggerEvent('qb-clothing:client:openOutfitMenu')
        return true
    end
    
    return false
end

-- Open barber menu
function Bridge.OpenBarberMenu()
    if not Bridge.ClothingResource then
        Bridge.Notify(locale('no_clothing_resource'), 'error')
        return false
    end
    
    if Bridge.ClothingResource == 'illenium-appearance' then
        exports['illenium-appearance']:openBarberMenu()
        return true
    elseif Bridge.ClothingResource == 'fivem-appearance' then
        exports['fivem-appearance']:openBarberMenu()
        return true
    elseif Bridge.ClothingResource == 'qb-clothing' then
        TriggerEvent('qb-clothing:client:openBarber')
        return true
    elseif Bridge.ClothingResource == 'esx_skin' then
        TriggerEvent('esx_skin:openBarberMenu')
        return true
    end
    
    return false
end

-- Open tattoo menu
function Bridge.OpenTattooMenu()
    if not Bridge.ClothingResource then
        Bridge.Notify(locale('no_clothing_resource'), 'error')
        return false
    end
    
    if Bridge.ClothingResource == 'illenium-appearance' then
        exports['illenium-appearance']:openTattooMenu()
        return true
    elseif Bridge.ClothingResource == 'fivem-appearance' then
        exports['fivem-appearance']:openTattooMenu()
        return true
    elseif Bridge.ClothingResource == 'qb-clothing' then
        TriggerEvent('qb-clothing:client:openTattoo')
        return true
    end
    
    return false
end

print('^2[AdminPanel]^0 Clothing bridge (client) loaded!')
