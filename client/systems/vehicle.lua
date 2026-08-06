--========================================================--
-- drill_k9
-- File: client/systems/vehicle.lua
-- Description: K9 Vehicle System
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.Vehicle = {}

local Vehicle = DK9.Vehicle

------------------------------------------------------------
-- Seat Definitions
------------------------------------------------------------

Vehicle.Seats = {
    DRIVER = -1,
    PASSENGER = 0,
    REAR_LEFT = 1,
    REAR_RIGHT = 2
}

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function Dog()
    return DK9.Engine.GetEntity()
end

local function Exists()
    local entity = Dog()

    return entity ~= 0 and DoesEntityExist(entity)
end

local function PlayerVehicle()

    local ped = PlayerPedId()

    if not IsPedInAnyVehicle(ped, false) then
        return nil
    end

    return GetVehiclePedIsIn(ped, false)

end

------------------------------------------------------------
-- Enter Vehicle
------------------------------------------------------------

function Vehicle.Enter(seat)

    if not Exists() then
        return false
    end

    local vehicle = PlayerVehicle()

    if not vehicle then
        return false
    end

    seat = tonumber(seat) or Vehicle.Seats.REAR_RIGHT

    if not IsVehicleSeatFree(vehicle, seat) then

        DK9.Network.Notify(
            "K9",
            "That seat is occupied.",
            "error"
        )

        return false

    end

    ClearPedTasksImmediately(Dog())

    TaskEnterVehicle(
        Dog(),
        vehicle,
        -1,
        seat,
        2.0,
        1,
        0
    )

    DK9.Engine.SetVehicle({
        InVehicle = true,
        Seat = seat
    })

    DK9.State.Change("ENTER_VEHICLE")

    DK9.Events.Emit("K9:VEHICLE_ENTER", {
        vehicle = vehicle,
        seat = seat
    })

    return true

end

------------------------------------------------------------
-- Exit Vehicle
------------------------------------------------------------

function Vehicle.Exit()

    if not Exists() then
        return false
    end

    if not IsPedInAnyVehicle(Dog(), false) then
        return false
    end

    TaskLeaveVehicle(
        Dog(),
        GetVehiclePedIsIn(Dog(), false),
        0
    )

    DK9.Engine.SetVehicle({
        InVehicle = false,
        Seat = -1
    })

    DK9.State.Change("FOLLOW")

    DK9.Events.Emit("K9:VEHICLE_EXIT")

    return true

end

------------------------------------------------------------
-- Monitor
------------------------------------------------------------

CreateThread(function()

    while true do

        Wait(500)

        if DK9.Engine.IsSpawned() and Exists() then

            local inVehicle = IsPedInAnyVehicle(Dog(), false)

            local vehicleData = DK9.Engine.GetVehicle()

            if inVehicle and not vehicleData.InVehicle then

                DK9.Engine.SetVehicle({
                    InVehicle = true
                })

                DK9.State.Change("IN_VEHICLE")

            elseif (not inVehicle) and vehicleData.InVehicle then

                DK9.Engine.SetVehicle({
                    InVehicle = false,
                    Seat = -1
                })

                DK9.State.Change("FOLLOW")

            end

        end

    end

end)

------------------------------------------------------------
-- Radial Commands
------------------------------------------------------------

DK9.Events.On("K9:COMMAND", function(data)

    if not data then
        return
    end

    if data.command == "vehicle_driver" then

        Vehicle.Enter(Vehicle.Seats.DRIVER)

    elseif data.command == "vehicle_passenger" then

        Vehicle.Enter(Vehicle.Seats.PASSENGER)

    elseif data.command == "vehicle_rear_left" then

        Vehicle.Enter(Vehicle.Seats.REAR_LEFT)

    elseif data.command == "vehicle_rear_right" then

        Vehicle.Enter(Vehicle.Seats.REAR_RIGHT)

    elseif data.command == "vehicle_exit" then

        Vehicle.Exit()

    end

end)

------------------------------------------------------------
-- Console Commands
------------------------------------------------------------

RegisterCommand("k9vehicle", function(_, args)

    if not args[1] then

        Vehicle.Enter(Vehicle.Seats.REAR_RIGHT)
        return

    end

    local seat = string.lower(args[1])

    if seat == "driver" then

        Vehicle.Enter(Vehicle.Seats.DRIVER)

    elseif seat == "passenger" then

        Vehicle.Enter(Vehicle.Seats.PASSENGER)

    elseif seat == "left" then

        Vehicle.Enter(Vehicle.Seats.REAR_LEFT)

    elseif seat == "right" then

        Vehicle.Enter(Vehicle.Seats.REAR_RIGHT)

    elseif seat == "exit" then

        Vehicle.Exit()

    end

end)