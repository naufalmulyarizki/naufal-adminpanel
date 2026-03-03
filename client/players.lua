-- =====================
-- NUI Callbacks
-- =====================

RegisterNUICallback('close', function(data, cb)
    AdminPanel.Close()
    cb({ success = true })
end)

RegisterNUICallback('kick', function(data, cb)
    AdminPanel.Debug('Kick request for player:', data.playerId)
    TriggerServerEvent('adminpanel:server:kickPlayer', data.playerId, data.reason or 'No reason provided')
    cb({ success = true })
end)

RegisterNUICallback('ban', function(data, cb)
    AdminPanel.Debug('Ban request for player:', data.playerId)
    TriggerServerEvent('adminpanel:server:banPlayer', data.playerId, data.reason or 'No reason provided', data.duration or 0)
    cb({ success = true })
end)

RegisterNUICallback('giveMoney', function(data, cb)
    AdminPanel.Debug('Give money request:', data.playerId, data.type, data.amount)
    TriggerServerEvent('adminpanel:server:giveMoney', data.playerId, data.type, data.amount)
    cb({ success = true })
end)

RegisterNUICallback('giveItem', function(data, cb)
    AdminPanel.Debug('Give item request:', data.playerId, data.itemName, data.quantity)
    TriggerServerEvent('adminpanel:server:giveItem', data.playerId, data.itemName, data.quantity)
    cb({ success = true })
end)

RegisterNUICallback('clearLogs', function(data, cb)
    AdminPanel.Debug('Clear logs request')
    TriggerServerEvent('adminpanel:server:clearLogs')
    cb({ success = true })
end)

RegisterNUICallback('getLogs', function(data, cb)
    Bridge.TriggerCallback('adminpanel:server:getLogs', function(logs)
        cb({ success = true, logs = logs })
    end)
end)

RegisterNUICallback('exportLogs', function(data, cb)
    AdminPanel.Debug('Export logs request')
    TriggerServerEvent('adminpanel:server:exportLogs', data.csv, data.filename)
    cb({ success = true })
end)

RegisterNUICallback('clearInventory', function(data, cb)
    TriggerServerEvent('adminpanel:server:clearInventory', data.playerId)
    cb({ success = true })
end)

RegisterNUICallback('freezePlayer', function(data, cb)
    local playerId = data.playerId
    local frozen = data.frozen
    
    if frozen then
        local found = false
        for _, id in ipairs(AdminPanel.playerOptions.frozenPlayers) do
            if id == playerId then found = true break end
        end
        if not found then
            table.insert(AdminPanel.playerOptions.frozenPlayers, playerId)
        end
    else
        for i, id in ipairs(AdminPanel.playerOptions.frozenPlayers) do
            if id == playerId then
                table.remove(AdminPanel.playerOptions.frozenPlayers, i)
                break
            end
        end
    end
    
    TriggerServerEvent('adminpanel:server:freezePlayer', playerId, frozen)
    cb({ success = true })
end)

RegisterNUICallback('giveItemToPlayer', function(data, cb)
    TriggerServerEvent('adminpanel:server:giveItemToPlayer', data.playerId, data.item, data.amount)
    cb({ success = true })
end)

RegisterNUICallback('giveItemToAll', function(data, cb)
    TriggerServerEvent('adminpanel:server:giveItemToAll', data.item, data.amount)
    cb({ success = true })
end)

RegisterNUICallback('giveMoneyToAll', function(data, cb)
    TriggerServerEvent('adminpanel:server:giveMoneyToAll', data.amount, data.type)
    cb({ success = true })
end)

RegisterNUICallback('makePlayerDrunk', function(data, cb)
    TriggerServerEvent('adminpanel:server:makePlayerDrunk', data.playerId)
    cb({ success = true })
end)

RegisterNUICallback('mutePlayer', function(data, cb)
    local playerId = data.playerId
    local muted = data.muted
    
    if muted then
        local found = false
        for _, id in ipairs(AdminPanel.playerOptions.mutedPlayers) do
            if id == playerId then found = true break end
        end
        if not found then
            table.insert(AdminPanel.playerOptions.mutedPlayers, playerId)
        end
    else
        for i, id in ipairs(AdminPanel.playerOptions.mutedPlayers) do
            if id == playerId then
                table.remove(AdminPanel.playerOptions.mutedPlayers, i)
                break
            end
        end
    end
    
    TriggerServerEvent('adminpanel:server:mutePlayer', playerId, muted)
    cb({ success = true })
end)

RegisterNUICallback('openPlayerInventory', function(data, cb)
    TriggerServerEvent('adminpanel:server:openPlayerInventory', data.playerId)
    cb({ success = true })
end)

RegisterNUICallback('openStashInventory', function(data, cb)
    TriggerServerEvent('adminpanel:server:openStashInventory', data.playerId)
    cb({ success = true })
end)

RegisterNUICallback('openTrunkInventory', function(data, cb)
    TriggerServerEvent('adminpanel:server:openTrunkInventory', data.playerId)
    cb({ success = true })
end)

RegisterNUICallback('openStashById', function(data, cb)
    if not data.stashId or data.stashId == '' then
        cb({ success = false, error = 'No stash ID provided' })
        return
    end
    Bridge.OpenStash(data.stashId)
    cb({ success = true })
end)

RegisterNUICallback('openTrunkByPlate', function(data, cb)
    if not data.plate or data.plate == '' then
        cb({ success = false, error = 'No plate provided' })
        return
    end
    Bridge.OpenTrunk(data.plate)
    cb({ success = true })
end)

RegisterNUICallback('removeMoneyPlayer', function(data, cb)
    TriggerServerEvent('adminpanel:server:removeMoneyPlayer', data.playerId, data.amount, data.type)
    cb({ success = true })
end)

RegisterNUICallback('removeStress', function(data, cb)
    TriggerServerEvent('adminpanel:server:removeStress', data.playerId)
    cb({ success = true })
end)

RegisterNUICallback('reviveRadius', function(data, cb)
    TriggerServerEvent('adminpanel:server:reviveRadius', data.playerId)
    cb({ success = true })
end)

RegisterNUICallback('setPlayerPed', function(data, cb)
    TriggerServerEvent('adminpanel:server:setPlayerPed', data.playerId, data.ped)
    cb({ success = true })
end)

RegisterNUICallback('setRoutingBucket', function(data, cb)
    TriggerServerEvent('adminpanel:server:setRoutingBucket', data.playerId, data.bucket)
    cb({ success = true })
end)

RegisterNUICallback('spectatePlayer', function(data, cb)
    local playerId = data.playerId
    local spectate = data.spectate
    
    if spectate then
        AdminPanel.playerOptions.spectatingPlayer = playerId
        TriggerServerEvent('adminpanel:server:spectatePlayer', playerId, true)
    else
        AdminPanel.playerOptions.spectatingPlayer = nil
        TriggerServerEvent('adminpanel:server:spectatePlayer', playerId, false)
    end
    
    cb({ success = true })
end)

RegisterNUICallback('giveClothingMenu', function(data, cb)
    TriggerServerEvent('adminpanel:server:giveClothingMenu', data.playerId)
    cb({ success = true })
end)

-- =====================
-- Client Events
-- =====================

RegisterNetEvent('adminpanel:client:freeze', function(frozen)
    AdminPanel.isFrozen = frozen
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, frozen)
    if frozen then
        Bridge.Notify(locale('frozen_by_admin'), 'error')
    else
        Bridge.Notify(locale('unfrozen_by_admin'), 'success')
    end
end)

RegisterNetEvent('adminpanel:client:updatePlayers', function(players)
    if AdminPanel.isOpen then
        SendNUIMessage({
            action = 'playersUpdated',
            data = {
                players = players
            }
        })
    end
end)

RegisterNetEvent('adminpanel:client:notify', function(message, type)
    Bridge.Notify(message, type or 'primary')
end)

RegisterNetEvent('adminpanel:client:startSpectate', function(targetServerId)
    local targetPlayer = GetPlayerFromServerId(targetServerId)
    if targetPlayer == -1 then
        Bridge.Notify(locale('player_not_found'), 'error')
        return
    end
    
    local targetPed = GetPlayerPed(targetPlayer)
    if not DoesEntityExist(targetPed) then
        Bridge.Notify(locale('player_ped_not_found'), 'error')
        return
    end
    
    AdminPanel.isSpectating = true
    AdminPanel.spectateTarget = targetPed
    
    local coords = GetEntityCoords(targetPed)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityVisible(PlayerPedId(), false, false)
    SetEntityInvincible(PlayerPedId(), true)
    SetEntityCollision(PlayerPedId(), false, false)
    FreezeEntityPosition(PlayerPedId(), true)
    
    NetworkSetInSpectatorMode(true, targetPed)
    Bridge.Notify(locale('spectating_player'), 'success')
end)

RegisterNetEvent('adminpanel:client:stopSpectate', function()
    if AdminPanel.isSpectating then
        NetworkSetInSpectatorMode(false, PlayerPedId())
        SetEntityVisible(PlayerPedId(), true, false)
        SetEntityInvincible(PlayerPedId(), AdminPanel.selfOptions.godMode)
        SetEntityCollision(PlayerPedId(), true, true)
        FreezeEntityPosition(PlayerPedId(), false)
        AdminPanel.isSpectating = false
        AdminPanel.spectateTarget = nil
        Bridge.Notify(locale('spectate_stopped'), 'info')
    end
end)

RegisterNetEvent('adminpanel:client:makeDrunk', function()
    SetPedIsDrunk(PlayerPedId(), true)
    ShakeGameplayCam('DRUNK_SHAKE', 2.0)
    SetTimecycleModifier('Drunk')
    SetTimecycleModifierStrength(1.0)
    
    Bridge.Notify(locale('drunk_effect'), 'info')
    
    SetTimeout(60000, function()
        SetPedIsDrunk(PlayerPedId(), false)
        StopGameplayCamShaking(true)
        ClearTimecycleModifier()
    end)
end)

RegisterNetEvent('adminpanel:client:setPed', function(pedModel)
    local model = GetHashKey(pedModel)
    
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do
        Wait(100)
        timeout = timeout + 1
    end
    
    if HasModelLoaded(model) then
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        Bridge.Notify(locale('ped_changed', pedModel), 'success')
    else
        Bridge.Notify(locale('ped_load_failed'), 'error')
    end
end)

RegisterNetEvent('adminpanel:client:removeStress', function()
    if GetResourceState('hud') == 'started' then
        TriggerEvent('hud:client:UpdateStress', 0)
    end
    Bridge.Notify(locale('stress_removed'), 'success')
end)

RegisterNetEvent('adminpanel:client:reviveRadius', function(radius)
    radius = radius or 10.0
    local myCoords = GetEntityCoords(PlayerPedId())
    local count = 0
    
    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed and DoesEntityExist(targetPed) then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(myCoords - targetCoords)
            if distance <= radius then
                TriggerServerEvent('adminpanel:server:revivePlayerInRadius', GetPlayerServerId(playerId))
                count = count + 1
            end
        end
    end
    
    Bridge.Notify(locale('revived_in_radius', count), 'success')
end)

RegisterNetEvent('adminpanel:client:openTrunk', function(adminId)
    local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 71)
    
    if vehicle and DoesEntityExist(vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)
        TriggerServerEvent('adminpanel:server:openTrunkByPlate', adminId, plate)
    else
        TriggerServerEvent('adminpanel:client:notify', -1, 'No vehicle nearby', 'error')
    end
end)
