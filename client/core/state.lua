--========================================================--
-- drill_k9
-- File: client/core/state.lua
-- Description: K9 State Manager
-- Version: 0.3.0
--========================================================--

DK9 = DK9 or {}
DK9.State = {}

local State = DK9.State

------------------------------------------------------------
-- Valid States
------------------------------------------------------------

local ValidStates = {
    IDLE = true,
    FOLLOW = true,
    STAY = true,
    SIT = true,
    DOWN = true,

    RETURN = true,

    ENTER_VEHICLE = true,
    IN_VEHICLE = true,
    EXIT_VEHICLE = true,

    SEARCH_PLAYER = true,
    SEARCH_VEHICLE = true,
    SEARCH_AREA = true,
    TRACK = true,

    APPREHEND = true,
    BARK = true,
    GUARD = true,

    EATING = true,
    DRINKING = true,
    RESTING = true,

    INJURED = true,
    INCAPACITATED = true,
    DEAD = true
}

------------------------------------------------------------
-- State Validation
------------------------------------------------------------

function State.IsValid(state)
    return ValidStates[state] == true
end

------------------------------------------------------------
-- Get Current State
------------------------------------------------------------

function State.Get()

    return DK9.Engine.GetState()

end

------------------------------------------------------------
-- Change State
------------------------------------------------------------

function State.Change(newState)

    if not State.IsValid(newState) then

        print(("[drill_k9] Invalid state '%s'"):format(tostring(newState)))

        return false

    end

    local currentState = DK9.Engine.GetState()

    if currentState == newState then
        return false
    end

    DK9.Engine.SetState(newState)

    DK9.Events.Emit("K9:STATE_CHANGED", {
        previous = currentState,
        current = newState
    })

    return true

end

------------------------------------------------------------
-- Convenience Functions
------------------------------------------------------------

function State.Is(state)

    return DK9.Engine.GetState() == state

end

function State.Reset()

    State.Change("IDLE")

end

------------------------------------------------------------
-- Debug
------------------------------------------------------------

function State.Print()

    print(("[drill_k9] Current State: %s"):format(DK9.Engine.GetState()))

end