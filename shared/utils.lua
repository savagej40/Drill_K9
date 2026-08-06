Utils = {}

function Utils.Debug(message, ...)
    if not Config.Debug then return end
    local output = tostring(message)
    if select('#', ...) > 0 then
        local success, formatted = pcall(string.format, output, ...)
        if success then output = formatted end
    end
    print(('^3[drill_k9]^7 %s'):format(output))
end

function Utils.Clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

function Utils.Round(value, decimals)
    value = tonumber(value) or 0
    decimals = tonumber(decimals) or 0
    local multiplier = 10 ^ decimals
    return math.floor(value * multiplier + 0.5) / multiplier
end

function Utils.Trim(value)
    if type(value) ~= 'string' then return '' end
    return value:match('^%s*(.-)%s*$')
end

function Utils.CopyTable(source)
    if type(source) ~= 'table' then return source end
    local copy = {}
    for key, value in pairs(source) do
        copy[Utils.CopyTable(key)] = Utils.CopyTable(value)
    end
    return copy
end

function Utils.GenerateCollarId(length)
    length = tonumber(length) or 8
    local characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local result = {}
    for index = 1, length do
        local position = math.random(1, #characters)
        result[index] = characters:sub(position, position)
    end
    return table.concat(result)
end
