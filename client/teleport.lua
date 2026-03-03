-- Teleport Self
RegisterNUICallback('teleportSelf', function(data, cb)
    AdminPanel.Debug('Teleport self request:', json.encode(data.coords))
    
    local coords = data.coords
    local heading = data.heading or 0.0
    local ped = PlayerPedId()
    
    DoScreenFadeOut(500)
    Wait(500)
    
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, heading)
    
    DoScreenFadeIn(500)
    
    Bridge.Notify(locale('teleport_success'), 'success')
    TriggerServerEvent('adminpanel:server:logAction', 'Teleported', nil, string.format('Teleported to %.2f, %.2f, %.2f', coords.x, coords.y, coords.z))
    
    cb({ success = true })
end)

-- Teleport Player (Server Side)
RegisterNUICallback('teleportPlayer', function(data, cb)
    AdminPanel.Debug('Teleport player request:', data.playerId, json.encode(data.coords))
    TriggerServerEvent('adminpanel:server:teleportPlayer', data.playerId, data.coords, data.heading or 0.0)
    cb({ success = true })
end)

-- Teleport to Waypoint
RegisterNUICallback('tpToWaypoint', function(data, cb)
    local waypoint = GetFirstBlipInfoId(8)
    
    if not DoesBlipExist(waypoint) then
        Bridge.Notify(locale('teleport_no_waypoint'), 'error')
        cb({ success = false, error = 'No waypoint set' })
        return
    end
    
    local coords = GetBlipInfoIdCoord(waypoint)
    local ped = PlayerPedId()
    
    DoScreenFadeOut(500)
    Wait(500)
    
    local found, groundZ = false, coords.z
    for height = 1000.0, 0.0, -25.0 do
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, height, false, false, false)
        Wait(50)
        found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, height, false)
        if found then break end
    end
    
    SetEntityCoords(ped, coords.x, coords.y, groundZ + 1.0, false, false, false, false)
    DoScreenFadeIn(500)
    
    Bridge.Notify(locale('teleport_to_waypoint'), 'success')
    TriggerServerEvent('adminpanel:server:logAction', 'Teleport', nil, 'TP to waypoint')
    cb({ success = true })
end)

-- Client Event: Teleport by Admin
RegisterNetEvent('adminpanel:client:teleport', function(coords, heading)
    local ped = PlayerPedId()
    
    DoScreenFadeOut(500)
    Wait(500)
    
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, heading or 0.0)
    
    DoScreenFadeIn(500)
    
    Bridge.Notify(locale('teleported_by_admin'), 'primary')
end)

-- Coordinate Update Thread
CreateThread(function()
    while true do
        if AdminPanel.isOpen then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            
            SendNUIMessage({
                action = 'updateCoords',
                data = {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z,
                    heading = heading
                }
            })
        end
        Wait(500)
    end
end)
