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

function prettyjson(t)
    local minified = json.encode(t)
    
    local newtext = ""
    local tabulation = 0
    for c in minified:gmatch(".") do
        if c == "{" then
            newtext = newtext .. c
            tabulation = tabulation + 1
            newtext = newtext .. "\n"
            for x = 1, tabulation do
                newtext = newtext .. "    "
            end
        elseif c == "}" then
            tabulation = tabulation - 1
            newtext = newtext .. "\n"
            for x = 1, tabulation do
                newtext = newtext .. "    "
            end
            newtext = newtext .. c
        elseif c == "," then
            newtext = newtext .. c
            newtext = newtext .. "\n"
            for x = 1, tabulation do
                newtext = newtext .. "    "
            end
        else
            newtext = newtext .. c
        end
    end
    return newtext
end

while true do
    local counter = 1
    local task = receiver:demand()
    print("","New task!")
    local retryafter = task.retryafter or def_retryafter
    local attempts = task.attempts or def_attempts
    local link = task.link
    --local data = json.encode(task.data)
    print(prettyjson(task.data))
    if task.data.data then
        print("", "converted")
        task.data.data = json.encode(task.data.data)
    end
    while true do
        print("",counter)
        if counter == attempts then 
            transmiter:push({success = false, errcode = 0, result = "Request failed after " .. tostring(attempts) .. " attempts!"})
        end
        

        local code, body, headers = https.request(link, task.data)
        print("", "success")
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
    end
end



