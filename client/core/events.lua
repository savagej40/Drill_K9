--========================================================--
-- drill_k9
-- File: client/core/events.lua
-- Description: DK9 Event System
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.Events = {}

local Events = DK9.Events

------------------------------------------------------------
-- Registered Events
------------------------------------------------------------

local listeners = {}

------------------------------------------------------------
-- Register Listener
------------------------------------------------------------

function Events.On(eventName, callback)

    if type(eventName) ~= "string" then
        return
    end

    if type(callback) ~= "function" then
        return
    end

    listeners[eventName] = listeners[eventName] or {}

    table.insert(listeners[eventName], callback)

end

------------------------------------------------------------
-- Remove Listener
------------------------------------------------------------

function Events.Off(eventName)

    listeners[eventName] = nil

end

------------------------------------------------------------
-- Emit Event
------------------------------------------------------------

function Events.Emit(eventName, data)

    local eventListeners = listeners[eventName]

    if not eventListeners then
        return
    end

    for _, callback in ipairs(eventListeners) do

        local success, err = pcall(callback, data)

        if not success then

            print(("[drill_k9] Event Error (%s): %s")
                :format(eventName, err))

        end

    end

end

------------------------------------------------------------
-- Debug
------------------------------------------------------------

function Events.Count(eventName)

    local eventListeners = listeners[eventName]

    if not eventListeners then
        return 0
    end

    return #eventListeners

end

------------------------------------------------------------
-- Cleanup
------------------------------------------------------------

function Events.Clear()

    listeners = {}

end