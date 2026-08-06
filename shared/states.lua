K9States = {
    IDLE = 'IDLE',
    FOLLOW = 'FOLLOW',
    STAY = 'STAY',
    SIT = 'SIT',
    DOWN = 'DOWN',
    RETURN = 'RETURN',
    ENTER_VEHICLE = 'ENTER_VEHICLE',
    IN_VEHICLE = 'IN_VEHICLE',
    EXIT_VEHICLE = 'EXIT_VEHICLE',
    SEARCH_PLAYER = 'SEARCH_PLAYER',
    SEARCH_VEHICLE = 'SEARCH_VEHICLE',
    SEARCH_AREA = 'SEARCH_AREA',
    TRACK = 'TRACK',
    APPREHEND = 'APPREHEND',
    BARK = 'BARK',
    GUARD = 'GUARD',
    EATING = 'EATING',
    DRINKING = 'DRINKING',
    RESTING = 'RESTING',
    INJURED = 'INJURED',
    INCAPACITATED = 'INCAPACITATED',
    DEAD = 'DEAD'
}

local validStates = {}
for _, state in pairs(K9States) do
    validStates[state] = true
end

function K9States.IsValid(state)
    return type(state) == 'string' and validStates[state] == true
end

function K9States.GetAll()
    local states = {}
    for state in pairs(validStates) do
        states[#states + 1] = state
    end
    table.sort(states)
    return states
end
