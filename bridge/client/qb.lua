-- QBCore Client Bridge
if Bridge.Framework ~= 'qb' then return end

local QBCore = exports['qb-core']:GetCoreObject()

-- Notification
function Bridge.Notify(message, type, duration)
    type = type or 'primary'
    duration = duration or 5000
    QBCore.Functions.Notify(message, type, duration)
end

-- Get Player Data
function Bridge.GetPlayerData()
    return QBCore.Functions.GetPlayerData()
end

-- Trigger Callback
function Bridge.TriggerCallback(name, cb, ...)
    QBCore.Functions.TriggerCallback(name, cb, ...)
end

-- Get Player Ped
function Bridge.GetPlayerPed()
    return PlayerPedId()
end

-- Get Vehicle Plate
function Bridge.GetVehiclePlate(vehicle)
    return QBCore.Functions.GetPlate(vehicle)
end

-- Progress Bar (if available)
function Bridge.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if exports['progressbar'] then
        exports['progressbar']:Progress({
            name = name,
            duration = duration,
            label = label,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            controlDisables = disableControls,
            animation = animation,
            prop = prop,
            propTwo = propTwo
        }, function(cancelled)
            if not cancelled then
                if onFinish then onFinish() end
            else
                if onCancel then onCancel() end
            end
        end)
    else
        -- Fallback: just wait
        Wait(duration)
        if onFinish then onFinish() end
    end
end

-- Has Item (client side check - requires ox_inventory or similar)
function Bridge.HasItem(itemName, amount)
    amount = amount or 1
    if GetResourceState('ox_inventory') == 'started' then
        local count = exports.ox_inventory:Search('count', itemName)
        return count >= amount
    elseif GetResourceState('qb-inventory') == 'started' then
        return exports['qb-inventory']:HasItem(itemName, amount)
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
    TriggerEvent("vehiclekeys:client:SetOwner", plate)
end

print('^2[AdminPanel]^0 QBCore client bridge loaded!')
