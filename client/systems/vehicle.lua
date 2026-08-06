--========================================================--
-- drill_k9
-- File: client/systems/vehicle.lua
-- Description: K9 vehicle entry, seat selection, and exit
-- Version: 1.0.0-alpha.1
--========================================================--

DK9 = DK9 or {}
DK9.Vehicle = {}

local Vehicle = DK9.Vehicle

------------------------------------------------------------
-- Configuration
------------------------------------------------------------

Vehicle.Seats = {
    DRIVER = -1,
    PASSENGER = 0,
    REAR_LEFT = 1,
    REAR_RIGHT = 2
}

local DEFAULT_SEAT = Vehicle.Seats.REAR_RIGHT
local ENTER_SPEED = 3.5
local EXIT_FLAGS = 0
local MAX_ENTRY_VEHICLE_SPEED = 3.0
local ENTER_TIMEOUT = 15000
local EXIT_TIMEOUT = 8000
local NEARBY_VEHICLE_RADIUS = 8.0

local seatFallbackOrder = {
    Vehicle.Seats.REAR_RIGHT,
    Vehicle.Seats.REAR_LEFT,
    Vehicle.Seats.PASSENGER,
    Vehicle.Seats.DRIVER
}

------------------------------------------------------------
-- Internal state
------------------------------------------------------------

local operation = 'IDLE'
local activeVehicle = 0
local requestedSeat = DEFAULT_SEAT
local lastVehicle = 0
local lastSeat = -1

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function getDog()
    return DK9.Engine.GetEntity()
end

local function getHandler()
    return PlayerPedId()
end

local function dogExists()
    local dog = getDog()
    return dog ~= 0 and DoesEntityExist(dog)
end

local function vehicleExists(vehicle)
    return vehicle ~= nil
        and vehicle ~= 0
        and DoesEntityExist(vehicle)
        and IsEntityAVehicle(vehicle)
end

local function notify(message, notificationType)
    if DK9.Network and DK9.Network.Notify then
        DK9.Network.Notify(
            'K9',
            message,
            notificationType or 'info'
        )
    end
end

local function setOperation(newOperation)
    operation = newOperation
end

local function setVehicleData(inVehicle, seat)
    DK9.Engine.SetVehicle({
        InVehicle = inVehicle == true,
        Seat = tonumber(seat) or -1
    })
end

local function getHandlerVehicle()
    local handler = getHandler()

    if IsPedInAnyVehicle(handler, false) then
        return GetVehiclePedIsIn(handler, false)
    end

    local coords = GetEntityCoords(handler)
    local vehicle = GetClosestVehicle(
        coords.x,
        coords.y,
        coords.z,
        NEARBY_VEHICLE_RADIUS,
        0,
        70
    )

    if vehicleExists(vehicle) then
        return vehicle
    end

    return 0
end

local function isSeatValid(vehicle, seat)
    if not vehicleExists(vehicle) then
        return false
    end

    seat = tonumber(seat)

    if not seat then
        return false
    end

    local maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle)

    if seat == Vehicle.Seats.DRIVER then
        return true
    end

    return seat >= 0 and seat < maxPassengers
end

local function isSeatAvailable(vehicle, seat)
    return isSeatValid(vehicle, seat)
        and IsVehicleSeatFree(vehicle, seat, false)
end

local function findAvailableSeat(vehicle, preferredSeat)
    preferredSeat = tonumber(preferredSeat) or DEFAULT_SEAT

    if isSeatAvailable(vehicle, preferredSeat) then
        return preferredSeat
    end

    for _, seat in ipairs(seatFallbackOrder) do
        if seat ~= preferredSeat
            and isSeatAvailable(vehicle, seat) then

            return seat
        end
    end

    return nil
end

local function getDogSeat(vehicle)
    if not dogExists() or not vehicleExists(vehicle) then
        return -1
    end

    local dog = getDog()

    if GetPedInVehicleSeat(vehicle, -1) == dog then
        return -1
    end

    local maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle)

    for seat = 0, maxPassengers - 1 do
        if GetPedInVehicleSeat(vehicle, seat) == dog then
            return seat
        end
    end

    return -1
end

local function waitForEntry(vehicle, seat)
    local startedAt = GetGameTimer()

    while operation == 'ENTERING' do
        Wait(100)

        if not dogExists() or not vehicleExists(vehicle) then
            return false
        end

        if IsPedInVehicle(getDog(), vehicle, false) then
            return true
        end

        if GetGameTimer() - startedAt >= ENTER_TIMEOUT then
            return false
        end

        if not IsVehicleSeatFree(vehicle, seat, false) then
            local occupant = GetPedInVehicleSeat(vehicle, seat)

            if occupant ~= getDog() then
                return false
            end
        end
    end

    return false
end

local function waitForExit(vehicle)
    local startedAt = GetGameTimer()

    while operation == 'EXITING' do
        Wait(100)

        if not dogExists() then
            return false
        end

        if not IsPedInVehicle(getDog(), vehicle, false) then
            return true
        end

        if GetGameTimer() - startedAt >= EXIT_TIMEOUT then
            return false
        end
    end

    return false
end

------------------------------------------------------------
-- Status
------------------------------------------------------------

function Vehicle.GetOperation()
    return operation
end

function Vehicle.GetActiveVehicle()
    return activeVehicle
end

function Vehicle.GetLastVehicle()
    return lastVehicle
end

function Vehicle.GetLastSeat()
    return lastSeat
end

function Vehicle.IsBusy()
    return operation ~= 'IDLE'
end

------------------------------------------------------------
-- Enter
------------------------------------------------------------

function Vehicle.Enter(preferredSeat)
    if not dogExists() then
        notify('Spawn your K9 first.', 'error')
        return false
    end

    if Vehicle.IsBusy() then
        notify('The K9 is already completing a vehicle action.', 'error')
        return false
    end

    if IsPedInAnyVehicle(getDog(), false) then
        notify('The K9 is already in a vehicle.', 'error')
        return false
    end

    local vehicle = getHandlerVehicle()

    if not vehicleExists(vehicle) then
        notify('No usable vehicle is nearby.', 'error')
        return false
    end

    if GetEntitySpeed(vehicle) > MAX_ENTRY_VEHICLE_SPEED then
        notify('Stop the vehicle before loading the K9.', 'error')
        return false
    end

    local seat = findAvailableSeat(vehicle, preferredSeat)

    if seat == nil then
        notify('No available vehicle seat was found.', 'error')
        return false
    end

    activeVehicle = vehicle
    requestedSeat = seat
    setOperation('ENTERING')

    if DK9.Navigation then
        DK9.Navigation.Stop()
    end

    DK9.State.Change('ENTER_VEHICLE')

    ClearPedTasksImmediately(getDog())
    SetPedKeepTask(getDog(), true)

    TaskEnterVehicle(
        getDog(),
        vehicle,
        ENTER_TIMEOUT,
        seat,
        ENTER_SPEED,
        1,
        0
    )

    CreateThread(function()
        local entered = waitForEntry(vehicle, seat)

        if entered then
            local actualSeat = getDogSeat(vehicle)

            lastVehicle = vehicle
            lastSeat = actualSeat

            setVehicleData(true, actualSeat)
            setOperation('IDLE')

            DK9.State.Change('IN_VEHICLE')
            DK9.Events.Emit('K9:VEHICLE_ENTER', {
                vehicle = vehicle,
                seat = actualSeat
            })

            return
        end

        ClearPedTasks(getDog())
        setVehicleData(false, -1)
        setOperation('IDLE')
        activeVehicle = 0

        DK9.State.Change('FOLLOW')
        notify('The K9 could not enter the vehicle.', 'error')
    end)

    return true
end

------------------------------------------------------------
-- Exit
------------------------------------------------------------

function Vehicle.Exit()
    if not dogExists() then
        return false
    end

    if Vehicle.IsBusy() then
        return false
    end

    if not IsPedInAnyVehicle(getDog(), false) then
        notify('The K9 is not in a vehicle.', 'error')
        return false
    end

    local vehicle = GetVehiclePedIsIn(getDog(), false)

    if not vehicleExists(vehicle) then
        return false
    end

    if GetEntitySpeed(vehicle) > MAX_ENTRY_VEHICLE_SPEED then
        notify('Stop the vehicle before unloading the K9.', 'error')
        return false
    end

    activeVehicle = vehicle
    setOperation('EXITING')

    DK9.State.Change('EXIT_VEHICLE')

    TaskLeaveVehicle(
        getDog(),
        vehicle,
        EXIT_FLAGS
    )

    CreateThread(function()
        local exited = waitForExit(vehicle)

        if not exited and dogExists() then
            ClearPedTasks(getDog())
        end

        setVehicleData(false, -1)
        setOperation('IDLE')
        activeVehicle = 0

        DK9.Events.Emit('K9:VEHICLE_EXIT', {
            vehicle = vehicle,
            success = exited
        })

        DK9.State.Change('FOLLOW')
    end)

    return true
end

------------------------------------------------------------
-- Radial commands
------------------------------------------------------------

DK9.Events.On('K9:COMMAND', function(data)
    if not data or not data.command then
        return
    end

    local command = data.command

    if command == 'vehicle_driver' then
        Vehicle.Enter(Vehicle.Seats.DRIVER)
    elseif command == 'vehicle_passenger' then
        Vehicle.Enter(Vehicle.Seats.PASSENGER)
    elseif command == 'vehicle_rear_left' then
        Vehicle.Enter(Vehicle.Seats.REAR_LEFT)
    elseif command == 'vehicle_rear_right' then
        Vehicle.Enter(Vehicle.Seats.REAR_RIGHT)
    elseif command == 'vehicle_exit' then
        Vehicle.Exit()
    end
end)

------------------------------------------------------------
-- State reconciliation monitor
------------------------------------------------------------

CreateThread(function()
    while true do
        Wait(750)

        if DK9.Engine.IsSpawned() and dogExists() then
            local dogInVehicle = IsPedInAnyVehicle(getDog(), false)
            local vehicleData = DK9.Engine.GetVehicle()

            if operation == 'IDLE' then
                if dogInVehicle and not vehicleData.InVehicle then
                    local vehicle = GetVehiclePedIsIn(getDog(), false)
                    local seat = getDogSeat(vehicle)

                    lastVehicle = vehicle
                    lastSeat = seat

                    setVehicleData(true, seat)
                    DK9.State.Change('IN_VEHICLE')
                elseif not dogInVehicle and vehicleData.InVehicle then
                    setVehicleData(false, -1)

                    if DK9.State.Is('IN_VEHICLE') then
                        DK9.State.Change('FOLLOW')
                    end
                end
            end
        end
    end
end)

------------------------------------------------------------
-- Cleanup
------------------------------------------------------------

DK9.Events.On('K9:DISMISSED', function()
    operation = 'IDLE'
    activeVehicle = 0
    requestedSeat = DEFAULT_SEAT
    lastVehicle = 0
    lastSeat = -1
end)

------------------------------------------------------------
-- Console testing
------------------------------------------------------------

RegisterCommand('k9vehicle', function(_, args)
    local option = string.lower(tostring(args[1] or 'right'))

    if option == 'driver' then
        Vehicle.Enter(Vehicle.Seats.DRIVER)
    elseif option == 'passenger' then
        Vehicle.Enter(Vehicle.Seats.PASSENGER)
    elseif option == 'left' then
        Vehicle.Enter(Vehicle.Seats.REAR_LEFT)
    elseif option == 'right' then
        Vehicle.Enter(Vehicle.Seats.REAR_RIGHT)
    elseif option == 'exit' then
        Vehicle.Exit()
    end
end, false)
