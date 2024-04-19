local id, cwd, def_retryafter, def_attempts = ...
local https = require("https")
local json = require(cwd .. ".json")
local receiver = love.thread.getChannel("threaded_requests_" .. id .. "_in")
local transmiter = love.thread.getChannel("threaded_requests_" .. id .. "_out")

local function decode(t, key)
    local val = json.decode(t)
    if key then
        val = val[key]
    end
    return key
end

while true do
    local counter = 1
    local task = receiver:demand()
    print("","New task!")
    local retryafter = task.retryafter or def_retryafter
    local attempts = task.attempts or def_attempts
    local link = task.link
    --local data = json.encode(task.data)
    while true do
        if counter == attempts then 
            transmiter:push({success = false, errcode = 0, result = "Request failed after 24 attempts!"})
        end
        
        local code, body, headers = https.request(link, task.data)
        if code == 0 then
            love.timer.sleep(retryafter)
        elseif code == 200 then
            transmiter:push({success = true, errcode = code, result = pcall(decode, body) or body})
            break
        else
            transmiter:push({success = false, errcode = code, result = pcall(decode, body, "description") or body})
            break
        end
        counter = counter + 1
        print("",counter)
    end
end



