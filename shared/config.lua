Config = {}

Config.Version = '0.2.0'
Config.Debug = true

Config.Keys = {
    Menu = 'F5',
    Attack = 'E',
    Recall = 'R',
    Camera = 'F6'
}

Config.Permissions = {
    Use = 'drill_k9.use',
    Attack = 'drill_k9.attack',
    Vet = 'drill_k9.vet',
    Admin = 'drill_k9.admin'
}

Config.K9 = {
    DefaultName = 'Rex',
    DefaultBreed = 'German Shepherd',
    SpawnOffset = 2.0,
    FollowDistance = 2.5,
    TeleportDistance = 35.0
}

Config.Vitals = {
    MaxHealth = 100,
    MaxArmor = 100,
    MaxFood = 100,
    MaxWater = 100,
    MaxEnergy = 100
}

Config.Decay = {
    Enabled = true,
    TickMilliseconds = 60000,
    FoodPerTick = 0.35,
    WaterPerTick = 0.60,
    EnergyPerTick = 0.20
}

Config.GPS = {
    Enabled = true,
    UpdateMilliseconds = 1000,
    ShowBlip = true,
    BlipSprite = 442,
    BlipColor = 3,
    BlipScale = 0.75,
    ShortRange = false
}

Config.HUD = {
    Enabled = true,
    UpdateMilliseconds = 250,
    ShowDistance = true,
    ShowState = true,
    ShowVitals = true
}

Config.Theme = {
    Primary = '#2EA3FF',
    Success = '#46D67B',
    Warning = '#FFC145',
    Danger = '#FF5A5A',
    Text = '#FFFFFF',
    Shadow = 'rgba(0, 0, 0, 0.35)'
}

Config.Breeds = {
    { label = 'Belgian Malinois', model = 'a_c_shepherd' },
    { label = 'German Shepherd', model = 'a_c_shepherd' },
    { label = 'Rottweiler', model = 'a_c_rottweiler' },
    { label = 'Retriever', model = 'a_c_retriever' },
    { label = 'Husky', model = 'a_c_husky' }
}
