--========================================================--
-- drill_k9
-- File: client/systems/kennel.lua
-- Description: K9 Kennel Management
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.Kennel = {}

local Kennel = DK9.Kennel

------------------------------------------------------------
-- Active Profile
------------------------------------------------------------

local ActiveProfile = nil

------------------------------------------------------------
-- Default Profile
------------------------------------------------------------

local function DefaultProfile()

    return {

        id = nil,

        name = "Rex",

        breed = "German Shepherd",

        model = "a_c_shepherd",

        age = 2,

        weight = 72,

        collar = "",

        certifications = {

            patrol = true,

            narcotics = false,

            explosives = false,

            cadaver = false,

            tracking = true

        },

        equipment = {

            gps = true,

            vest = false,

            camera = false

        },

        stats = {

            health = 100,

            armor = 0,

            food = 100,

            water = 100,

            energy = 100

        }

    }

end

------------------------------------------------------------
-- Get Active
------------------------------------------------------------

function Kennel.Get()

    return ActiveProfile

end

------------------------------------------------------------
-- Set Active
------------------------------------------------------------

function Kennel.Set(profile)

    ActiveProfile = profile

    DK9.Engine.SetProfile({

        Name = profile.name,

        Breed = profile.breed,

        CollarId = profile.collar

    })

    DK9.Engine.SetStats({

        Health = profile.stats.health,

        Armor = profile.stats.armor,

        Food = profile.stats.food,

        Water = profile.stats.water,

        Energy = profile.stats.energy

    })

    DK9.Network.UpdateHUD()

end

------------------------------------------------------------
-- Create
------------------------------------------------------------

function Kennel.Create(data)

    local profile = DefaultProfile()

    for key,value in pairs(data or {}) do

        profile[key] = value

    end

    ActiveProfile = profile

    TriggerServerEvent(

        "drill_k9:server:createProfile",

        profile

    )

end

------------------------------------------------------------
-- Save
------------------------------------------------------------

function Kennel.Save()

    if not ActiveProfile then
        return
    end

    local stats = DK9.Engine.GetStats()

    ActiveProfile.stats = {

        health = stats.Health,

        armor = stats.Armor,

        food = stats.Food,

        water = stats.Water,

        energy = stats.Energy

    }

    TriggerServerEvent(

        "drill_k9:server:saveProfile",

        ActiveProfile

    )

end

------------------------------------------------------------
-- Load
------------------------------------------------------------

function Kennel.Load(profile)

    if not profile then
        return
    end

    Kennel.Set(profile)

end

------------------------------------------------------------
-- Delete
------------------------------------------------------------

function Kennel.Delete(id)

    TriggerServerEvent(

        "drill_k9:server:deleteProfile",

        id

    )

end

------------------------------------------------------------
-- Server Events
------------------------------------------------------------

RegisterNetEvent(

    "drill_k9:client:loadProfile",

    function(profile)

        Kennel.Load(profile)

    end

)

------------------------------------------------------------
-- Resource Start
------------------------------------------------------------

CreateThread(function()

    Wait(1000)

    TriggerServerEvent(

        "drill_k9:server:requestProfile"

    )

end)

------------------------------------------------------------
-- Auto Save
------------------------------------------------------------

CreateThread(function()

    while true do

        Wait(300000)

        Kennel.Save()

    end

end)

------------------------------------------------------------
-- Resource Stop
------------------------------------------------------------

AddEventHandler(

    "onResourceStop",

    function(resource)

        if resource ~= GetCurrentResourceName() then
            return
        end

        Kennel.Save()

    end

)