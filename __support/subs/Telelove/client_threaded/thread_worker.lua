local name, worker_id, cwd, token = ...
local stopper = love.thread.getChannel(name .."/stopper")
local receiver = love.thread.getChannel(name .."/connectors/worker_" .. worker_id)
local telelove = require(cwd .."extern.Telelove")

client = require(cwd)
client.__worker = true

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
    local package = self.__receiver:demand()
    if package then
        if package[1] == 1 then
            require(package[2])
        elseif package[2] == 2 then          
            local update = self.__telelove.__class.__update(self.__telelove.json.decode(package[2]))

            if update.message then
                if not self:__ProcessCommands(self.__telelove.__class.__message(update.message)) then
                    self:onMessage(self.__telelove.__class.__message(update.message))
                end
            elseif update.callback_query then
                self:__ProcessCallbackQuery(self.__telelove.__class.__callbackquery(update.callback_query))
            end
        end
    end
end


while true do
    client:Update()
end