-- Log admin action
function AdminServer.LogAction(adminSource, action, targetId, details, logType)
    logType = logType or 'info'
    
    local log = {
        id = #AdminServer.AdminLogs + 1,
        timestamp = os.date('%Y-%m-%d %H:%M:%S'),
        type = logType,
        action = action,
        admin = AdminServer.GetAdminName(adminSource),
        target = targetId and AdminServer.GetTargetName(targetId) or nil,
        details = details or ''
    }
    
    table.insert(AdminServer.AdminLogs, 1, log) -- Insert at beginning
    
    -- Limit logs
    if #AdminServer.AdminLogs > Config.Logging.maxLogs then
        table.remove(AdminServer.AdminLogs) -- Remove oldest
    end
    
    AdminServer.Debug('Action logged:', action, 'by', log.admin)
    
    -- Discord logging
    if Config.DiscordWebhook and Config.DiscordWebhook ~= '' then
        AdminServer.SendDiscordLog(log)
    end
    
    -- Database logging
    if Config.Logging.saveToDatabase then
        AdminServer.SaveLogToDatabase(log)
    end
end

-- Send discord webhook
function AdminServer.SendDiscordLog(log)
    local color = Config.DiscordColors[log.type] or Config.DiscordColors.info
    
    local embed = {
        {
            ['title'] = 'Admin Panel Log',
            ['description'] = log.action,
            ['color'] = color,
            ['fields'] = {
                { ['name'] = 'Admin', ['value'] = log.admin, ['inline'] = true },
                { ['name'] = 'Target', ['value'] = log.target or 'N/A', ['inline'] = true },
                { ['name'] = 'Details', ['value'] = log.details or 'N/A', ['inline'] = false },
            },
            ['footer'] = {
                ['text'] = 'Admin Panel | ' .. log.timestamp
            }
        }
    }
    
    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({ embeds = embed }), { ['Content-Type'] = 'application/json' })
end

-- Save log to database
function AdminServer.SaveLogToDatabase(log)
    MySQL.insert('INSERT INTO adminpanel_logs (timestamp, type, action, admin, target, details) VALUES (?, ?, ?, ?, ?, ?)', {
        log.timestamp,
        log.type,
        log.action,
        log.admin,
        log.target or '',
        log.details or ''
    })
end

-- Log Action (from client)
RegisterNetEvent('adminpanel:server:logAction', function(action, targetId, details)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    AdminServer.LogAction(src, action, targetId, details, 'info')
end)

-- Clear Logs
RegisterNetEvent('adminpanel:server:clearLogs', function()
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    local logCount = #AdminServer.AdminLogs
    AdminServer.AdminLogs = {}
    
    AdminServer.LogAction(src, 'Logs Cleared', nil, 'Cleared ' .. logCount .. ' logs', 'warning')
    TriggerClientEvent('adminpanel:client:notify', src, locale('logs_cleared'), 'success')
    AdminServer.Debug('Logs cleared by admin')
    
    -- Clear from database too
    if Config.Logging.saveToDatabase then
        MySQL.query('DELETE FROM adminpanel_logs')
    end
end)

-- Export Logs (save to file)
RegisterNetEvent('adminpanel:server:exportLogs', function(csv, filename)
    local src = source
    if not AdminServer.HasPermission(src) then return end
    
    if not csv or csv == '' then
        TriggerClientEvent('adminpanel:client:notify', src, locale('logs_no_export'), 'error')
        return
    end
    
    -- Create logs directory if it doesn't exist
    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local logsDir = resourcePath .. '/logs'
    
    -- Clean filename
    filename = filename or ('admin-logs-' .. os.time() .. '.csv')
    filename = filename:gsub('[^%w%-_%.%s]', '')
    
    local filePath = logsDir .. '/' .. filename
    
    -- Try to save the file
    local file = io.open(filePath, 'w')
    if file then
        file:write(csv)
        file:close()
        
        local adminName = GetPlayerName(src) or 'Unknown'
        AdminServer.LogAction(src, 'Logs Exported', nil, 'Exported logs to ' .. filename, 'info')
        TriggerClientEvent('adminpanel:client:notify', src, locale('logs_exported', filename), 'success')
        AdminServer.Debug('Logs exported by', adminName, 'to', filePath)
    else
        -- Try creating the logs directory first
        os.execute('mkdir "' .. logsDir .. '"')
        
        file = io.open(filePath, 'w')
        if file then
            file:write(csv)
            file:close()
            
            local adminName = GetPlayerName(src) or 'Unknown'
            AdminServer.LogAction(src, 'Logs Exported', nil, 'Exported logs to ' .. filename, 'info')
            TriggerClientEvent('adminpanel:client:notify', src, locale('logs_exported', filename), 'success')
            AdminServer.Debug('Logs exported by', adminName, 'to', filePath)
        else
            TriggerClientEvent('adminpanel:client:notify', src, locale('logs_export_failed'), 'error')
            AdminServer.Debug('Failed to save logs file:', filePath)
        end
    end
end)

-- Load logs from database on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if Config.Logging.saveToDatabase then
        -- Create table if not exists
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS adminpanel_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                timestamp VARCHAR(50),
                type VARCHAR(20),
                action VARCHAR(100),
                admin VARCHAR(100),
                target VARCHAR(100),
                details TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ]])
        
        -- Load existing logs
        MySQL.query('SELECT * FROM adminpanel_logs ORDER BY id DESC LIMIT ?', { Config.Logging.maxLogs }, function(result)
            if result then
                for _, log in ipairs(result) do
                    table.insert(AdminServer.AdminLogs, {
                        id = log.id,
                        timestamp = log.timestamp,
                        type = log.type,
                        action = log.action,
                        admin = log.admin,
                        target = log.target,
                        details = log.details
                    })
                end
                AdminServer.Debug('Loaded', #AdminServer.AdminLogs, 'logs from database')
            end
        end)
    end
    
    print('^2[AdminPanel]^0 Logs module loaded!')
end)

-- Export function
exports('LogAction', AdminServer.LogAction)
