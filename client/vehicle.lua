-- Spawn Vehicle
RegisterNUICallback('spawnVehicle', function(data, cb)
    local model = data.vehicle
    
    if not IsModelValid(model) then
        Bridge.Notify(locale('vehicle_invalid_model'), 'error')
        cb({ success = false })
        return
    end
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    if IsPedInAnyVehicle(ped, false) then
        local oldVeh = GetVehiclePedIsIn(ped, false)
        DeleteVehicle(oldVeh)
    end
    
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    SetModelAsNoLongerNeeded(model)
    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, "OFF")
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    
    Bridge.GiveVehicleKeys(Bridge.GetVehiclePlate(vehicle))
    
    Bridge.Notify(locale('vehicle_spawned', model), 'success')
    TriggerServerEvent('adminpanel:server:logAction', 'Spawn Vehicle', nil, 'Spawned ' .. model)
    cb({ success = true })
end)

-- Delete Vehicle
RegisterNUICallback('deleteVehicle', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = nil
    
    if IsPedInAnyVehicle(ped, false) then
        vehicle = GetVehiclePedIsIn(ped, false)
    else
        vehicle = GetVehiclePedIsIn(ped, true)
        if not DoesEntityExist(vehicle) then
            local coords = GetEntityCoords(ped)
            local forward = GetEntityForwardVector(ped)
            local endCoords = coords + forward * 5.0
            local hit, _, _, _, entityHit = GetShapeTestResult(StartShapeTestRay(coords.x, coords.y, coords.z, endCoords.x, endCoords.y, endCoords.z, 10, ped, 0))
            if hit == 1 and IsEntityAVehicle(entityHit) then
                vehicle = entityHit
            end
        end
    end
    
    if DoesEntityExist(vehicle) then
        DeleteVehicle(vehicle)
        Bridge.Notify(locale('vehicle_deleted'), 'success')
        TriggerServerEvent('adminpanel:server:logAction', 'Delete Vehicle', nil, 'Deleted vehicle')
    else
        Bridge.Notify(locale('vehicle_not_found'), 'error')
    end
    
    cb({ success = true })
end)

-- Repair Vehicle
RegisterNUICallback('repairVehicle', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if not DoesEntityExist(vehicle) then
        Bridge.Notify(locale('vehicle_must_be_in'), 'error')
        cb({ success = false })
        return
    end
    
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleUndriveable(vehicle, false)
    SetVehicleEngineOn(vehicle, true, true, false)
    
    Bridge.Notify(locale('vehicle_repaired'), 'success')
    TriggerServerEvent('adminpanel:server:logAction', 'Repair Vehicle', nil, 'Repaired vehicle')
    cb({ success = true })
end)

-- Refuel Vehicle
RegisterNUICallback('refuelVehicle', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if not DoesEntityExist(vehicle) then
        Bridge.Notify(locale('vehicle_must_be_in'), 'error')
        cb({ success = false })
        return
    end
    
    exports[Config.Fuel]:SetFuel(vehicle, 100.0)
    
    Bridge.Notify(locale('vehicle_refueled'), 'success')
    TriggerServerEvent('adminpanel:server:logAction', 'Refuel Vehicle', nil, 'Refueled vehicle')
    cb({ success = true })
end)

-- Flip Vehicle
RegisterNUICallback('flipVehicle', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if not DoesEntityExist(vehicle) then
        Bridge.Notify(locale('vehicle_must_be_in'), 'error')
        cb({ success = false })
        return
    end
    
    SetVehicleOnGroundProperly(vehicle)
    
    Bridge.Notify(locale('vehicle_flipped'), 'success')
    TriggerServerEvent('adminpanel:server:logAction', 'Flip Vehicle', nil, 'Flipped vehicle')
    cb({ success = true })
end)

-- Max Upgrade Vehicle
RegisterNUICallback('maxUpgradeVehicle', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if not DoesEntityExist(vehicle) then
        Bridge.Notify(locale('vehicle_must_be_in'), 'error')
        cb({ success = false })
        return
    end
    
    SetVehicleModKit(vehicle, 0)
    
    for i = 0, 48 do
        local max = GetNumVehicleMods(vehicle, i) - 1
        if max >= 0 then
            SetVehicleMod(vehicle, i, max, false)
        end
    end
    
    ToggleVehicleMod(vehicle, 18, true) 
    ToggleVehicleMod(vehicle, 20, true) 
    ToggleVehicleMod(vehicle, 22, true) 
    
    SetVehicleWindowTint(vehicle, 1)
    SetVehicleTyresCanBurst(vehicle, false)
    
    Bridge.Notify(locale('vehicle_upgraded'), 'success')
    TriggerServerEvent('adminpanel:server:logAction', 'Max Upgrade', nil, 'Max upgraded vehicle')
    cb({ success = true })
end)

-- Change Plate
RegisterNUICallback('changePlate', function(data, cb)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if not DoesEntityExist(vehicle) then
        Bridge.Notify(locale('vehicle_must_be_in'), 'error')
        cb({ success = false })
        return
    end
    
    local newPlate = data.plate:upper():sub(1, 8)
    SetVehicleNumberPlateText(vehicle, newPlate)
    
    Bridge.Notify(locale('vehicle_plate_changed', newPlate), 'success')
    TriggerServerEvent('adminpanel:server:logAction', 'Change Plate', nil, 'Changed plate to ' .. newPlate)
    cb({ success = true })
end)

-- Fix Player Vehicle (Server Event)
RegisterNUICallback('fixPlayerVehicle', function(data, cb)
    TriggerServerEvent('adminpanel:server:fixPlayerVehicle', data.playerId)
    cb({ success = true })
end)

-- Give Car To Player
RegisterNUICallback('giveCarToPlayer', function(data, cb)
    TriggerServerEvent('adminpanel:server:giveCarToPlayer', data.playerId, data.vehicle, data.plate)
    cb({ success = true })
end)

-- Client Event: Fix Vehicle
RegisterNetEvent('adminpanel:client:fixVehicle', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if DoesEntityExist(vehicle) then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true, false)
        Bridge.Notify(locale('vehicle_repaired_by_admin'), 'success')
    end
end)

-- Client Event: Spawn Car
RegisterNetEvent('adminpanel:client:spawnCar', function(model, plate)
    local ped = PlayerPedId()
    
    if not IsModelValid(model) then
        Bridge.Notify(locale('vehicle_invalid_model'), 'error')
        return
    end
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    if IsPedInAnyVehicle(ped, false) then
        local oldVeh = GetVehiclePedIsIn(ped, false)
        DeleteVehicle(oldVeh)
    end
    
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    SetModelAsNoLongerNeeded(model)
    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, "OFF")
    
    if plate and plate ~= '' then
        SetVehicleNumberPlateText(vehicle, plate)
    end
    
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    
    Bridge.GiveVehicleKeys(Bridge.GetVehiclePlate(vehicle))
    
    Bridge.Notify(locale('vehicle_received_from_admin'), 'success')
end)
