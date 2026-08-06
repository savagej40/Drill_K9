--========================================================--
-- drill_k9
-- File: client/core/engine.lua
-- Description: Core K9 Engine
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.Engine = {}

local Engine = DK9.Engine

------------------------------------------------------------
-- Internal Data
------------------------------------------------------------

local Data = {

    Ready = false,

    Spawned = false,

    Handler = 0,

    Entity = 0,

    Target = 0,

    State = "IDLE",

    Profile = {

        Name = "Rex",

        Breed = "German Shepherd",

        CollarId = ""

    },

    Stats = {

        Health = 100,

        Armor = 0,

        Food = 100,

        Water = 100,

        Energy = 100

    },

    GPS = {

        Enabled = true,

        Connected = false,

        Distance = 0.0,

        Blip = nil

    },

    Vehicle = {

        InVehicle = false,

        Seat = -1

    }

}

------------------------------------------------------------
-- Initialize
------------------------------------------------------------

function Engine.Initialize(handler)

    if Data.Ready then
        return
    end

    Data.Handler = handler

    Data.Ready = true

    print("^2[drill_k9]^7 Engine Initialized")

end

------------------------------------------------------------
-- Ready
------------------------------------------------------------

function Engine.IsReady()

    return Data.Ready

end

------------------------------------------------------------
-- Handler
------------------------------------------------------------

function Engine.GetHandler()

    return Data.Handler

end

function Engine.SetHandler(handler)

    Data.Handler = handler

end

------------------------------------------------------------
-- Entity
------------------------------------------------------------

function Engine.GetEntity()

    return Data.Entity

end

function Engine.SetEntity(entity)

    Data.Entity = entity

end

------------------------------------------------------------
-- Spawn
------------------------------------------------------------

function Engine.IsSpawned()

    return Data.Spawned

end

function Engine.SetSpawned(value)

    Data.Spawned = value

end

------------------------------------------------------------
-- State
------------------------------------------------------------

function Engine.GetState()

    return Data.State

end

function Engine.SetState(state)

    Data.State = state

end

------------------------------------------------------------
-- Profile
------------------------------------------------------------

function Engine.GetProfile()

    return Data.Profile

end

function Engine.SetProfile(profile)

    for k,v in pairs(profile) do

        Data.Profile[k] = v

    end

end

------------------------------------------------------------
-- Stats
------------------------------------------------------------

function Engine.GetStats()

    return Data.Stats

end

function Engine.SetStats(stats)

    for k,v in pairs(stats) do

        Data.Stats[k] = v

    end

end

------------------------------------------------------------
-- GPS
------------------------------------------------------------

function Engine.GetGPS()

    return Data.GPS

end

function Engine.SetGPS(gps)

    for k,v in pairs(gps) do

        Data.GPS[k] = v

    end

end

------------------------------------------------------------
-- Vehicle
------------------------------------------------------------

function Engine.GetVehicle()

    return Data.Vehicle

end

function Engine.SetVehicle(vehicle)

    for k,v in pairs(vehicle) do

        Data.Vehicle[k] = v

    end

end

------------------------------------------------------------
-- Reset
------------------------------------------------------------

function Engine.Reset()

    Data.Spawned = false

    Data.Entity = 0

    Data.Target = 0

    Data.State = "IDLE"

end

------------------------------------------------------------
-- Cleanup
------------------------------------------------------------

function Engine.Cleanup()

    Engine.Reset()

    Data.Ready = false

    print("^3[drill_k9]^7 Engine Shutdown")

end