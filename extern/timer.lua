timer = {}
local hub = {}

local function reversedipairsiter(t, i)
    i = i - 1
    if i ~= 0 then
        return i, t[i]
    end
end
local function rpairs(t)
    return reversedipairsiter, t, #t + 1
end



function timer.Simple(t, f, ...)
    table.insert(hub, {love.timer.getTime() + t, f, {...}})
end

function timer.Update()
    for i, var in rpairs(hub) do
        if love.timer.getTime() >= var[1] then 
            var[2](unpack(var[3]))
            table.remove(hub, i)
        end
    end
end