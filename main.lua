
--[[
telelove = require("extern.Telelove")

client = telelove.NewThreadedClient():Start()
--SHA256:zLueqjsBInfi3nGjuBRA2N53ZV4vsC2/4cRC8vz4GWc
do
    return
end
]]
love.filesystem = require("extern.nativefs")
require("superdata")


https = require("https")
sql = require("extern.sqlite3")

horde = require("api.horde")
--translation = require("api.translation")
translation = require("api.yandex")

require("lang")


local opn = sqlite3.open
--KOBOLD = 3q7qnr2bMDMUo_5Yww4QHA
--ANOTHER = 0000000000



function prettyprint(table, key, indent)
    print( ("%s%s (%s): %s"):format(indent or "", key, type(table), tostring(table)) )
    if type(table) == "table" then
        for i, var in pairs(table) do
            prettyprint(var, i, (indent or "").."  ")
        end
    end
end


function sqlite3.open(...) --because fuck me
    local output = opn(...)
    if output then
        local db = getmetatable(output)
        local exe = db.exec
        function db:execute(str)
            local cringe
            local function wrapper(udata,cols,values,names)
                cringe = cringe or {}
                local t = {}
                for i=1,cols do
                    t[names[i]] = values[i]
                end
                if cringe then
                    table.insert(cringe, t)
                end
                return 0
            end
            ---@diagnostic disable-next-line: redundant-parameter
            local code = exe(self, str, wrapper)
            if code ~= 0 then
                print("SQL ERROR:")
                print(code)
                if type(code) == "table" then
                    prettyprint(code)
                end
                pcall(function()
                    print(output:errmsg())
                end)
            end
            return cringe
        end
    end
    return output
end
function sqlite3.open_memory(...) --because fuck me
    local output = opn(...)
    if output then
        local db = getmetatable(output)
        local exe = db.exec
        function db:execute(str)
            local cringe
            local function wrapper(udata,cols,values,names)
                cringe = cringe or {}
                local t = {}
                for i=1,cols do
                    t[names[i]] = values[i]
                end
                if cringe then
                    table.insert(cringe, t)
                end
                return 0
            end
            ---@diagnostic disable-next-line: redundant-parameter
            local code = exe(self, str, wrapper)
            if code ~= 0 then
                print("SQL ERROR:")
                print(code)
                if type(code) == "table" then
                    prettyprint(code)
                end
                pcall(function()
                    print(output:errmsg())
                end)
            end
            return cringe
        end
    end
    return output
end


local token = "6784923911:AAGYu58tW8UDIV7ZiRjQrEI_iRmjr-WcLDs"

telelove = require("extern.Telelove")
client = telelove.NewClient()
client.active_chats = {}
client.display_name_change = {}
client.promocode_enter = {}
client.promocodes = telelove.json.decode(love.filesystem.read(PATH_PROMOCODES))

chats = require("chat")
characters = require("characters")

require("db")
db_Init()
db_Load()

function client:onStart()
    commands = require("commands")
    client:RegisterMultipleCommands(commands.main_menu)
    --client:RegisterMultipleCommands(commands.chat_selection)
    --client:RegisterMultipleCommands(commands.new_chat)
end

client:Connect(token)
--[[
function client:onMessage(message)
    print(1, message.text, message.chat)
    if message.text:sub(1, 1) == "/" then
        local i = message.text:find("%s") or 0
        commands[message.text:sub(2, i-1)](message.from, message.chat, message.text:sub(i+1))
    end
    --client:SendMessage(message.chat, message.text)
end
]]

require("__master_client")
function love.update()
    --love.timer.sleep(3)
    --db_Update()
    client:Update()
    horde.Update()
    MasterUpdate()
end