RegisterNUICallback('setWeather', function(data, cb)
    AdminPanel.currentWeather = data.weather
    TriggerServerEvent('adminpanel:server:setWeather', data.weather)
    Bridge.Notify(locale('weather_set', data.weather), 'success')
    cb({ success = true })
end)

RegisterNUICallback('setTime', function(data, cb)
    TriggerServerEvent('adminpanel:server:setTime', data.hour, data.minute or 0)
    Bridge.Notify(locale('time_set', string.format('%02d:%02d', data.hour, data.minute or 0)), 'success')
    cb({ success = true })
end)

RegisterNUICallback('freezeTime', function(data, cb)
    AdminPanel.freezeTime = data.enabled
    TriggerServerEvent('adminpanel:server:freezeTime', data.enabled)
    if data.enabled then
        Bridge.Notify(locale('time_frozen'), 'success')
    else
        Bridge.Notify(locale('time_unfrozen'), 'info')
    end
    cb({ success = true })
end)

RegisterNUICallback('setBlackout', function(data, cb)
    AdminPanel.blackout = data.enabled
    TriggerServerEvent('adminpanel:server:setBlackout', data.enabled)
    if data.enabled then
        Bridge.Notify(locale('blackout_enabled'), 'success')
    else
        Bridge.Notify(locale('blackout_disabled'), 'info')
    end
    cb({ success = true })
end)

RegisterNetEvent('adminpanel:client:setWeather', function(weather)
    AdminPanel.currentWeather = weather
    SetWeatherTypeNowPersist(weather)
    SetWeatherTypeNow(weather)
    SetWeatherTypePersist(weather)
    SetOverrideWeather(weather)
end)

RegisterNetEvent('adminpanel:client:setTime', function(hour, minute)
    AdminPanel.currentHour = hour
    AdminPanel.currentMinute = minute
    NetworkOverrideClockTime(hour, minute, 0)
end)

RegisterNetEvent('adminpanel:client:freezeTime', function(enabled)
    AdminPanel.freezeTime = enabled
end)

RegisterNetEvent('adminpanel:client:setBlackout', function(enabled)
    AdminPanel.blackout = enabled
    SetArtificialLightsState(enabled)
end)

CreateThread(function()
    while true do
        if AdminPanel.freezeTime then
            NetworkOverrideClockTime(AdminPanel.currentHour, AdminPanel.currentMinute, 0)
        end
        Wait(1000)
    end
end)
