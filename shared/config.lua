Config = {}

-- Resource name (harus sama dengan nama folder resource)
Config.ResourceName = 'adminpanel'

-- Command untuk membuka admin panel
Config.OpenCommand = 'adminpanel'

-- Keybind untuk membuka admin panel (bisa di-disable dengan nil)
Config.OpenKey = 'F10'

-- Permission yang dibutuhkan untuk mengakses admin panel
-- Bisa: 'god', 'admin', 'mod' atau sesuai ace permission
Config.RequiredPermission = 'admin'

-- Permission Levels (dari terendah ke tertinggi)
-- 'mod' < 'admin' < 'god'
Config.PermissionLevels = {
    ['mod'] = 1,
    ['admin'] = 2,
    ['god'] = 3,
}

-- Feature Permissions
-- Setiap fitur memiliki permission level minimum yang dibutuhkan
Config.FeaturePermissions = {
    -- === SELF OPTIONS ===
    self = {
        healSelf = 'mod',
        reviveSelf = 'mod',
        tpToWaypoint = 'mod',
        toggleDuty = 'mod',
        openClothingMenu = 'mod',
        copyCoords = 'mod',
        -- Toggles
        godMode = 'admin',
        invisible = 'admin',
        noclip = 'admin',
        infiniteStamina = 'mod',
        noRagdoll = 'mod',
        fastRun = 'mod',
        superJump = 'mod',
        showBlips = 'mod',
        showPlayerNames = 'mod',
    },
    
    -- === PLAYER MANAGEMENT ===
    players = {
        viewPlayers = 'mod',
        giveMoney = 'admin',
        giveCar = 'admin',
        giveItem = 'admin',
        freezePlayer = 'mod',
        mutePlayer = 'mod',
        spectatePlayer = 'mod',
        kickPlayer = 'admin',
        banPlayer = 'god',
        makePlayerDrunk = 'admin',
        openPlayerInventory = 'admin',
        removeMoneyPlayer = 'god',
        removeStress = 'admin',
        reviveRadius = 'admin',
        setPlayerPed = 'god',
        setRoutingBucket = 'god',
        giveClothingMenu = 'admin',
        fixPlayerVehicle = 'mod',
        clearInventory = 'god',
    },
    
    -- === VEHICLE ===
    vehicle = {
        spawnVehicle = 'admin',
        deleteVehicle = 'admin',
        repairVehicle = 'mod',
        flipVehicle = 'mod',
        maxUpgrades = 'admin',
        setFuel = 'mod',
        engineToggle = 'mod',
        lockToggle = 'mod',
    },
    
    -- === WORLD ===
    world = {
        setWeather = 'admin',
        setTime = 'admin',
        freezeTime = 'admin',
        blackout = 'god',
    },
    
    -- === ITEMS ===
    items = {
        giveItemToSelf = 'admin',
        giveMoneyToSelf = 'admin',
        giveItemToAll = 'god',
        giveMoneyToAll = 'god',
        openStash = 'admin',
        openTrunk = 'admin',
    },
    
    -- === TELEPORT ===
    teleport = {
        teleportToLocation = 'mod',
        teleportToPlayer = 'mod',
        teleportPlayer = 'admin',
        bringPlayer = 'admin',
    },
    
    -- === LOGS ===
    logs = {
        viewLogs = 'mod',
        exportLogs = 'admin',
        clearLogs = 'god',
    },
}

-- Discord Webhook untuk logging (kosongkan jika tidak mau pakai)
Config.DiscordWebhook = ''

-- Warna embed discord
Config.DiscordColors = {
    info = 3447003,     -- Biru
    warning = 16776960, -- Kuning
    error = 15158332    -- Merah
}

-- Preset lokasi teleport
Config.TeleportLocations = {
    { id = 1, name = 'City Hall', coords = vector3(425.4, -979.8, 29.4) },
    { id = 2, name = 'Police Station', coords = vector3(425.1, -980.5, 29.3) },
    { id = 3, name = 'Hospital', coords = vector3(350.8, -588.5, 43.4) },
    { id = 4, name = 'Airport', coords = vector3(-1040.2, -2741.5, 21.5) },
    { id = 5, name = 'Beach', coords = vector3(-1546.6, -1055.9, 25.5) },
    { id = 6, name = 'Mount Chiliad', coords = vector3(450.7, 5566.1, 806.2) },
    { id = 7, name = 'Pier', coords = vector3(-1850.1, -1232.3, 13.0) },
    { id = 8, name = 'LS Customs', coords = vector3(-365.4, -131.8, 37.9) },
}

-- Items yang bisa diberikan (sample - akan di-override dari server)
Config.Items = {
    { name = 'lockpick', label = 'Lockpick', weight = 10 },
    { name = 'handcuffs', label = 'Handcuffs', weight = 20 },
    { name = 'medkit', label = 'Medkit', weight = 50 },
    { name = 'bandage', label = 'Bandage', weight = 5 },
    { name = 'water', label = 'Water Bottle', weight = 5 },
    { name = 'bread', label = 'Bread', weight = 3 },
    { name = 'phone', label = 'Phone', weight = 10 },
    { name = 'radio', label = 'Radio', weight = 20 },
}

-- Ban duration options (dalam menit, 0 = permanent)
Config.BanDurations = {
    { label = '1 Hour', duration = 60 },
    { label = '1 Day', duration = 1440 },
    { label = '1 Week', duration = 10080 },
    { label = '1 Month', duration = 43200 },
    { label = 'Permanent', duration = 0 },
}

-- Notifikasi settings
Config.Notifications = {
    kickMessage = 'Kamu telah di-kick oleh admin.',
    banMessage = 'Kamu telah di-ban dari server.',
    noPermission = 'Kamu tidak memiliki permission untuk melakukan ini.',
}

-- Logging options
Config.Logging = {
    enabled = true,
    saveToDatabase = true,  -- Simpan log ke database
    maxLogs = 1000,         -- Maksimal log yang disimpan
}

-- Debug mode
Config.Debug = false

-- Fuel Resource
Config.Fuel = 'cdn-fuel'

-- Inventory Resource
-- Options: 'auto', 'ox_inventory', 'qb-inventory', 'qs-inventory', 'codem-inventory', 'origen_inventory'
Config.Inventory = 'auto'

-- Clothing Resource
-- Options: 'auto', 'illenium-appearance', 'fivem-appearance', 'qb-clothing', 'esx_skin', 'skinchanger'
Config.Clothing = 'auto'
