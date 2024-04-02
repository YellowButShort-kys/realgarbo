local telelove = {}
require(... ..".includes")(telelove)
telelove.Verbosity = true

local defaults = {
    threads = 1,
    reconnect = false,
    max_messages = 1000
}
local defaults_mt = {
    Threads = 4,
    reconnect = false,
    max_messages = 1000
}

---Establish connection to the bot
---@param token string
---@param settings table|nil
---@return table

function telelove.NewClient(settings)
    settings = setmetatable(settings or {}, {__index=defaults})
    return setmetatable({}, telelove.__clientbase):__init(settings)
end
function telelove.NewThreadedClient(settings)
    settings = setmetatable(settings or {}, {__index=defaults_mt})
    return setmetatable({}, telelove.__threadedclientbase):__init(settings)
end
function telelove.Connect(token, settings)
    settings = setmetatable(settings or {}, {__index=defaults})
    while true do
        code, body, headers = https.request("https://api.telegram.org/bot"..token.."/getMe", {})
        if code ~= 200 then
            telelove.__error("Failed while establishing connection! Waiting for a retry...")
            love.timer.sleep(1)
        else
            local body = telelove.json.decode(body)
            telelove.__print("Successfully connected to @"..body.result.username)
            return setmetatable({}, telelove.__clientbase):Start(telelove.__class.__user(body.result), token, settings)
        end
    end
end

---@param toggle boolean
---Toggles the console prints (errors will still be printed)
function telelove.Verbose(toggle)
    assert(type(toggle) == "boolean", "Unexpected variable type!")
    telelove.Verbosity = toggle
end

return telelove