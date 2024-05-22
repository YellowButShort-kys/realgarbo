local name, cwd, n_threads, token = ...
local stopper = love.thread.getChannel(name .."/stopper")
local telelove = require(cwd .."extern.Telelove")

------------------------------------------------------------------------------------------------------------------------------------------------------------------

--[[
local userlist = {}
---@class user
local user_base = {
    id            = 0,
    next_discard  = 0,
    target_thread = 1
}
]]
local threadlist = {}
---@class thread
local thread_base = {
    id = 0,
    users = {},
    ---@type love.Channel
    connector = nil
}
for x = 1, n_threads do
    local t = setmetatable({}, {__index = thread_base})
    t.id = x
    t.users = {}
    t.connector = love.thread.getChannel(name .."/connectors/worker_" .. t.id)
    table.insert(threadlist, t)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function reversedipairsiter(t, i)
    i = i - 1
    if i ~= 0 then
        return i, t[i]
    end
end
function rpairs(t)
    return reversedipairsiter, t, #t + 1
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------

local offset
function RetrieveUpdate()
    local skip
    if not offset then skip = true end
    
    local body = telelove.__saferequest(
        "https://api.telegram.org/bot"..token.."/getUpdates", 
        {method = "POST", headers = {["Content-Type"] = "application/json"}, data = telelove.json.encode({offset = offset, timeout = 60})}
    )
    
    if body then
        local collection = (telelove.json.decode(body).result)
        for _, package in ipairs(collection) do
            local update = telelove.__class.__update(package)
            offset = math.max(offset or 0, update.update_id + 1)
            if not skip then
                local target_thread = FindLeastBusyThread()
                target_thread.connector:push(package)
            end
        end
    end
end

---@return thread
function FindLeastBusyThread()
    local n, t
    for _, var in ipairs(threadlist) do
        local c = var.connector:getCount()
        if not n then
            n = c
            t = var
        else
            if n > c then
                n = c
                t = var
            end
        end
    end
    return t
end

--[[
local next_clear = love.timer.getTime() + 30
function ClearUserlist()
    local t = love.timer.getTime()
    if next_clear < love.timer.getTime() then
        for i, var in rpairs(userlist) do
            if var.next_discard < t then
                table.remove(userlist, i)
            end
        end
    end
end
]]

------------------------------------------------------------------------------------------------------------------------------------------------------------------

while true do
    if stopper:peek() then
        return
    end
    
    RetrieveUpdate()
    love.timer.sleep(0.05)
    --ClearUserlist()
end
