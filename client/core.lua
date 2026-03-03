-- State Variables (shared across client modules)
AdminPanel = AdminPanel or {}
AdminPanel.isOpen = false
AdminPanel.currentWeather = 'EXTRASUNNY'
AdminPanel.currentHour = 12
AdminPanel.currentMinute = 0
AdminPanel.freezeTime = false
AdminPanel.blackout = false

AdminPanel.selfOptions = {
    godMode = false,
    invisible = false,
    noclip = false,
    infiniteStamina = false,
    noRagdoll = false,
    fastRun = false,
    superJump = false,
    showBlips = false,
    showPlayerNames = false
}

AdminPanel.playerOptions = {
    frozenPlayers = {},
    mutedPlayers = {},
    spectatingPlayer = nil
}

AdminPanel.playerBlips = {}
AdminPanel.showingNames = false
AdminPanel.noclipEntity = nil
AdminPanel.noclipSpeed = 1.0
AdminPanel.isSpectating = false
AdminPanel.spectateTarget = nil
AdminPanel.isFrozen = false

-- Debug function
function AdminPanel.Debug(...)
    if Config.Debug then
        print('[AdminPanel:Client]', ...)
    end
end

-- Open Admin Panel
function AdminPanel.Open()
    if AdminPanel.isOpen then return end
    
    Bridge.TriggerCallback('adminpanel:server:hasPermission', function(hasPermission, features)
        if not hasPermission then
            Bridge.Notify(locale('no_permission'), 'error')
            return
        end
        
        Bridge.TriggerCallback('adminpanel:server:getPlayers', function(players)
            AdminPanel.isOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'open',
                data = {
                    players = players,
                    selfOptions = AdminPanel.selfOptions, 
                    worldOptions = {
                        weather = AdminPanel.currentWeather,
                        freezeTime = AdminPanel.freezeTime,
                        blackout = AdminPanel.blackout
                    },
                    playerOptions = AdminPanel.playerOptions, 
                    features = features
                }
            })
            AdminPanel.Debug('Admin panel opened with features:', json.encode(features))
        end)
    end)
end

-- Close Admin Panel
function AdminPanel.Close()
    if not AdminPanel.isOpen then return end
    AdminPanel.isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
    AdminPanel.Debug('Admin panel closed')
end

-- Toggle Admin Panel
function AdminPanel.Toggle()
    if AdminPanel.isOpen then
        AdminPanel.Close()
    else
        AdminPanel.Open()
    end
end

-- Register Command
RegisterCommand(Config.OpenCommand, function()
    AdminPanel.Toggle()
end, false)

-- Register Key Mapping
if Config.OpenKey then
    RegisterKeyMapping(Config.OpenCommand, 'Open Admin Panel', 'keyboard', Config.OpenKey)
end

-- Resource Stop Handler
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    AdminPanel.Close()
end)

-- Exports
exports('OpenAdminPanel', AdminPanel.Open)
exports('CloseAdminPanel', AdminPanel.Close)
exports('ToggleAdminPanel', AdminPanel.Toggle)
exports('IsAdminPanelOpen', function() return AdminPanel.isOpen end)
