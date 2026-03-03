-- ESX Client Bridge
if Bridge.Framework ~= 'esx' then return end

local ESX = exports['es_extended']:getSharedObject()

-- Notification
function Bridge.Notify(message, type, duration)
    type = type or 'info'
    duration = duration or 5000
    
    -- Convert QB types to ESX types
    local esxType = 'info'
    if type == 'success' then esxType = 'success'
    elseif type == 'error' then esxType = 'error'
    elseif type == 'warning' then esxType = 'warning'
    elseif type == 'primary' then esxType = 'info'
    end
    
    -- Try different notification systems
    if GetResourceState('esx_notify') == 'started' then
        exports['esx_notify']:Notify(esxType, duration, message)
    elseif GetResourceState('ox_lib') == 'started' then
        exports.ox_lib:notify({
            title = 'Admin Panel',
            description = message,
            type = esxType,
            duration = duration
        })
    else
        -- Fallback to ESX showNotification
        ESX.ShowNotification(message)
    end
end

-- Get Player Data
function Bridge.GetPlayerData()
    return ESX.GetPlayerData()
end

-- Trigger Callback
function Bridge.TriggerCallback(name, cb, ...)
    ESX.TriggerServerCallback(name, cb, ...)
end

-- Get Player Ped
function Bridge.GetPlayerPed()
    return PlayerPedId()
end

-- Get Vehicle Plate
function Bridge.GetVehiclePlate(vehicle)
    return GetVehicleNumberPlateText(vehicle)
end

-- Progress Bar (if available)
function Bridge.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if GetResourceState('ox_lib') == 'started' then
        local success = exports.ox_lib:progressBar({
            duration = duration,
            label = label,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            disable = disableControls,
            anim = animation
        })
        if success then
            if onFinish then onFinish() end
        else
            if onCancel then onCancel() end
        end
    elseif GetResourceState('esx_progressbar') == 'started' then
        exports['esx_progressbar']:Progressbar(label, duration, {
            FreezePlayer = disableControls and disableControls.disableMovement or false,
            animation = animation,
            onFinish = onFinish,
            onCancel = onCancel
        })
    else
        -- Fallback: just wait
        Wait(duration)
        if onFinish then onFinish() end
    end
end

-- Has Item (client side check)
function Bridge.HasItem(itemName, amount)
    amount = amount or 1
    if GetResourceState('ox_inventory') == 'started' then
        local count = exports.ox_inventory:Search('count', itemName)
        return count >= amount
    end
    -- ESX inventory check
    local playerData = ESX.GetPlayerData()
    if playerData and playerData.inventory then
        for _, item in pairs(playerData.inventory) do
            if item.name == itemName and item.count >= amount then
                return true
            end
        end
    end
    return false
end

-- Draw 3D Text
function Bridge.DrawText3D(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextFont(4)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

-- Vehicle Keys
function Bridge.GiveVehicleKeys(plate)
    -- Try different vehicle key systems
    if GetResourceState('qs-vehiclekeys') == 'started' then
        TriggerEvent('qs-vehiclekeys:client:GiveKeys', plate)
    elseif GetResourceState('wasabi_carlock') == 'started' then
        exports.wasabi_carlock:GiveKey(plate)
    elseif GetResourceState('cd_garage') == 'started' then
        TriggerEvent('cd_garage:AddKeys', plate)
    end
end

print('^2[AdminPanel]^0 ESX client bridge loaded!')
