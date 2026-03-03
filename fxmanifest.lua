fx_version 'cerulean'
game 'gta5'

author 'Admin Panel'
description 'QBCore/ESX Admin Panel - Player Management, Server Controls, Items, Teleport, Logs'
version '1.0.0'

lua54 'yes'

-- ox_lib for locales
ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'bridge/shared.lua',    -- Framework detection (must load first)
    'shared/*.lua'
}

client_scripts {
    'bridge/client/*.lua',  -- Client bridge (ESX/QBCore)
    'client/core.lua',      -- Core/State (must load first)
    'client/self.lua',      -- Self options (godmode, invisible, noclip, etc)
    'client/vehicle.lua',   -- Vehicle management
    'client/teleport.lua',  -- Teleport functions
    'client/world.lua',     -- Weather & Time controls
    'client/players.lua',   -- Player management & NUI callbacks
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server/*.lua',  -- Server bridge (ESX/QBCore)
    'server/core.lua',      -- Core/State (must load first)
    'server/logs.lua',      -- Logging system
    'server/players.lua',   -- Player management events
    'server/vehicle.lua',   -- Vehicle events
    'server/world.lua',     -- Weather & Time events
    'server/inventory.lua', -- Inventory management
}

ui_page 'web/public/index.html'

files {
    'web/public/index.html',
    'web/public/**/*',
    'locales/*.json'
}
