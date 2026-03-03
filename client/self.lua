-- Self Toggle NUI Callback
RegisterNUICallback('selfToggle', function(data, cb)
    local option = data.option
    local enabled = data.enabled
    local ped = PlayerPedId()
    
    AdminPanel.Debug('Self toggle:', option, enabled)
    
    AdminPanel.selfOptions[option] = enabled
    
    if option == 'godMode' then
        SetEntityInvincible(ped, enabled)
        if enabled then
            Bridge.Notify(locale('godmode_enabled'), 'success')
        else
            Bridge.Notify(locale('godmode_disabled'), 'error')
        end
        
    elseif option == 'invisible' then
        SetEntityVisible(ped, not enabled, false)
        if enabled then
            Bridge.Notify(locale('invisible_enabled'), 'success')
        else
            Bridge.Notify(locale('invisible_disabled'), 'error')
        end
        
    elseif option == 'noclip' then
        if enabled then
            AdminPanel.noclipEntity = ped
            if IsPedInAnyVehicle(ped, false) then
                AdminPanel.noclipEntity = GetVehiclePedIsIn(ped, false)
            end
            FreezeEntityPosition(AdminPanel.noclipEntity, true)
            SetEntityCollision(AdminPanel.noclipEntity, false, false)
            Bridge.Notify(locale('noclip_enabled'), 'success')
        else
            if AdminPanel.noclipEntity then
                FreezeEntityPosition(AdminPanel.noclipEntity, false)
                SetEntityCollision(AdminPanel.noclipEntity, true, true)
                AdminPanel.noclipEntity = nil
            end
            Bridge.Notify(locale('noclip_disabled'), 'error')
        end
        
    elseif option == 'fastRun' then
        if enabled then
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
            Bridge.Notify(locale('fastrun_enabled'), 'success')
        else
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
            Bridge.Notify(locale('fastrun_disabled'), 'error')
        end
        
    elseif option == 'superJump' then
        if enabled then
            Bridge.Notify(locale('superjump_enabled'), 'success')
        else
            Bridge.Notify(locale('superjump_disabled'), 'error')
        end
        
    elseif option == 'infiniteStamina' then
        if enabled then
            Bridge.Notify(locale('infinite_stamina_enabled'), 'success')
        else
            Bridge.Notify(locale('infinite_stamina_disabled'), 'error')
        end
        
    elseif option == 'noRagdoll' then
        SetPedCanRagdoll(ped, not enabled)
        if enabled then
            Bridge.Notify(locale('no_ragdoll_enabled'), 'success')
        else
            Bridge.Notify(locale('no_ragdoll_disabled'), 'error')
        end
        
    elseif option == 'showBlips' then
        if enabled then
            CreateThread(function()
                while AdminPanel.selfOptions.showBlips do
                    for _, playerId in ipairs(GetActivePlayers()) do
                        if playerId ~= PlayerId() then
                            local targetPed = GetPlayerPed(playerId)
                            if targetPed and DoesEntityExist(targetPed) then
                                if not AdminPanel.playerBlips[playerId] then
                                    local blip = AddBlipForEntity(targetPed)
                                    SetBlipSprite(blip, 1)
                                    SetBlipColour(blip, 2)
                                    SetBlipScale(blip, 0.8)
                                    SetBlipAsShortRange(blip, false)
                                    BeginTextCommandSetBlipName("STRING")
                                    AddTextComponentString(GetPlayerName(playerId))
                                    EndTextCommandSetBlipName(blip)
                                    AdminPanel.playerBlips[playerId] = blip
                                end
                            end
                        end
                    end
                    
                    for playerId, blip in pairs(AdminPanel.playerBlips) do
                        local found = false
                        for _, activeId in ipairs(GetActivePlayers()) do
                            if activeId == playerId then found = true break end
                        end
                        if not found then
                            RemoveBlip(blip)
                            AdminPanel.playerBlips[playerId] = nil
                        end
                    end
                    
                    Wait(2000)
                end
            end)
            Bridge.Notify(locale('player_blips_enabled'), 'success')
        else
            for playerId, blip in pairs(AdminPanel.playerBlips) do
                if DoesBlipExist(blip) then
                    RemoveBlip(blip)
                end
            end
            AdminPanel.playerBlips = {}
            Bridge.Notify(locale('player_blips_disabled'), 'error')
        end
        
    elseif option == 'showPlayerNames' then
        AdminPanel.showingNames = enabled
        if enabled then
            CreateThread(function()
                while AdminPanel.showingNames do
                    for _, playerId in ipairs(GetActivePlayers()) do
                        if playerId ~= PlayerId() then
                            local targetPed = GetPlayerPed(playerId)
                            if targetPed and DoesEntityExist(targetPed) then
                                local coords = GetEntityCoords(targetPed)
                                local distance = #(GetEntityCoords(PlayerPedId()) - coords)
                                if distance < 100.0 then
                                    local name = GetPlayerName(playerId) .. " [" .. GetPlayerServerId(playerId) .. "]"
                                    SetDrawOrigin(coords.x, coords.y, coords.z + 1.0, 0)
                                    SetTextFont(4)
                                    SetTextScale(0.35, 0.35)
                                    SetTextColour(255, 255, 255, 255)
                                    SetTextOutline()
                                    SetTextCentre(true)
                                    BeginTextCommandDisplayText("STRING")
                                    AddTextComponentSubstringPlayerName(name)
                                    EndTextCommandDisplayText(0.0, 0.0)
                                    ClearDrawOrigin()
                                end
                            end
                        end
                    end
                    Wait(0)
                end
            end)
            Bridge.Notify(locale('player_names_enabled'), 'success')
        else
            Bridge.Notify(locale('player_names_disabled'), 'error')
        end
    end
    
    TriggerServerEvent('adminpanel:server:logAction', 'Self Toggle', nil, option .. ' ' .. (enabled and 'enabled' or 'disabled'))
    cb({ success = true })
end)

-- Heal Self
RegisterNUICallback('healSelf', function(data, cb)
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100)
    ClearPedBloodDamage(ped)
    Bridge.Notify(locale('healed_armored'), 'success')
    TriggerServerEvent('adminpanel:server:logAction', 'Heal Self', nil, 'Healed self')
    cb({ success = true })
end)

-- Revive Self
RegisterNUICallback('reviveSelf', function(data, cb)
    TriggerServerEvent('adminpanel:server:reviveSelf')
    cb({ success = true })
end)

-- Toggle Duty
RegisterNUICallback('toggleDuty', function(data, cb)
    -- Framework specific duty toggle
    if Bridge.Framework == 'qb' then
        TriggerServerEvent('QBCore:ToggleDuty')
    elseif Bridge.Framework == 'esx' then
        -- ESX doesn't have duty toggle by default, but some jobs might
        TriggerEvent('esx_service:toggleDuty')
    end
    Bridge.Notify(locale('duty_toggled'), 'success')
    TriggerServerEvent('adminpanel:server:logAction', 'Toggle Duty', nil, 'Toggled duty')
    cb({ success = true })
end)

-- Open Clothing Menu
RegisterNUICallback('openClothingMenu', function(data, cb)
    Bridge.OpenClothingMenu()
    cb({ success = true })
end)

-- NoClip Thread
CreateThread(function()
    while true do
        if AdminPanel.selfOptions.noclip and AdminPanel.noclipEntity then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(AdminPanel.noclipEntity)
            local speed = AdminPanel.noclipSpeed
            
            if IsControlPressed(0, 21) then
                speed = speed * 3.0
            end
            if IsControlPressed(0, 36) then
                speed = speed * 0.3
            end
            
            local newCoords = coords
            
            if IsControlPressed(0, 32) then
                local forward = GetEntityForwardVector(AdminPanel.noclipEntity)
                newCoords = newCoords + forward * speed
            end
            if IsControlPressed(0, 33) then
                local forward = GetEntityForwardVector(AdminPanel.noclipEntity)
                newCoords = newCoords - forward * speed
            end
            if IsControlPressed(0, 34) then
                local heading = GetEntityHeading(AdminPanel.noclipEntity)
                SetEntityHeading(AdminPanel.noclipEntity, heading + 2.0)
            end
            if IsControlPressed(0, 35) then
                local heading = GetEntityHeading(AdminPanel.noclipEntity)
                SetEntityHeading(AdminPanel.noclipEntity, heading - 2.0)
            end
            if IsControlPressed(0, 44) then
                newCoords = vector3(newCoords.x, newCoords.y, newCoords.z - speed)
            end
            if IsControlPressed(0, 38) then
                newCoords = vector3(newCoords.x, newCoords.y, newCoords.z + speed)
            end
            
            SetEntityCoordsNoOffset(AdminPanel.noclipEntity, newCoords.x, newCoords.y, newCoords.z, true, true, true)
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- Stamina & Jump Thread
CreateThread(function()
    while true do
        if AdminPanel.selfOptions.infiniteStamina then
            RestorePlayerStamina(PlayerId(), 1.0)
        end
        
        if AdminPanel.selfOptions.superJump then
            SetSuperJumpThisFrame(PlayerId())
        end
        
        Wait(0)
    end
end)
