local name, cwd, token = ...
local stopper = love.thread.getChannel(name .."/stopper")
local receiver = love.thread.getChannel(name .."/connectors/poster")
local telelove = require(cwd .."extern.Telelove")
require("https")

client = require(cwd)
client.__poster = true

------------------------------------------------------------------------------------------------------------------------------------------------------------------

--[[
client.shared = {}
local proxy = {}
local meta = {
    __index = function(t, k)
       return proxy[t][k] 
    end,
    __newindex = function(t, k, v)
        if type(v) == "table" then
            error("Unable to share a table!")
        end
        proxy[t][k] = v
    end
}
setmetatable(client.shared, meta)
]]

------------------------------------------------------------------------------------------------------------------------------------------------------------------

function client:Update()
    local var = receiver:demand()
    
    local code, body, headers = https.request(var.link, var.data)
    if code == 0 then
        love.timer.sleep(0.1)
        return telelove.__saferequest(var.link, var.data)
    elseif code == 200 then
        return body
    else
        telelove.__error("There was an error during a request! Error code: "..code.."\n"..telelove.json.decode(body).description)
        print(var.data)
    end
end

while true do
    client:Update()
end