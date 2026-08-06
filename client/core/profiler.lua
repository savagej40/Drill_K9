DK9 = DK9 or {}
DK9.Profiler = {}

local Profiler = DK9.Profiler

Profiler.Enabled = Config.Performance.EnableProfiler

Profiler.Data = {}

function Profiler.Begin(name)

    if not Profiler.Enabled then
        return
    end

    Profiler.Data[name] = GetGameTimer()

end

function Profiler.End(name)

    if not Profiler.Enabled then
        return
    end

    if not Profiler.Data[name] then
        return
    end

    local elapsed = GetGameTimer() - Profiler.Data[name]

    print(("[Profiler] %s : %sms"):format(name, elapsed))

end