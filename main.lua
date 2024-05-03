
function love.run()
	if love.load then love.load(love.parsedGameArguments, love.rawGameArguments) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0, b
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		local dt = love.timer and love.timer.step() or 0

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		--if love.graphics and love.graphics.isActive() then
		--	love.graphics.origin()
		--	love.graphics.clear(love.graphics.getBackgroundColor())

		--	if love.draw then love.draw() end

		--	love.graphics.present()
		--end

		if love.timer then love.timer.sleep(0.001) end
	end
end
--love.filesystem = require("extern.nativefs")

--[[
telelove = require("extern.Telelove")

client = telelove.NewThreadedClient():Start()
--SHA256:zLueqjsBInfi3nGjuBRA2N53ZV4vsC2/4cRC8vz4GWc
do
    return
end
]]
require("superdata")


https = require("https")
requests = require("extern.threaded_requests")
sql = require("extern.sqlite3")

horde = require("api.horde")
openai = require("api.openai")
capybara = require("api.capybara_free")
dolphin = require("api.dolphin")
--translation = require("api.translation")
translation = require("api.yandex")

radom = require("__payment_processor")
radom.SetToken("eyJhZGRyZXNzIjpudWxsLCJvcmdhbml6YXRpb25faWQiOiJlNjZjMTk5Zi1lYzgzLTRkNWUtYjhkOS0zZWI1NTI4MDI0YzQiLCJzZXNzaW9uX2lkIjoiNGNkNjEzYmMtMmZjMS00NDQ3LWE4NTEtOWIwMTkwN2Y2MjFiIiwiZXhwaXJlZF9hdCI6IjIwMjUtMDUtMDNUMDg6NTY6MjIuOTkyNTgxNDM2WiIsImlzX2FwaV90b2tlbiI6dHJ1ZX0=")
radom.ListProducts()
love.timer.sleep(5) -- wait for that shit

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
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
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


local token = "7125567639:AAHbDOdYbO_3sCFdzxQ6djbqs4BvAcxQd3U"

telelove = require("extern.Telelove")
client = telelove.NewClient()
client.active_chats = {}
client.group_active_chats = {}
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

local nextcheck = tonumber((love.filesystem.read("subs_check.txt")))
SUBBONUS = {
    {500, 3700},
    {1750, 12950},
    {3780, 27720}
}
local function checksubs()
    if os.time() >= nextcheck then
        local d = os.date("*t", nextcheck)
        local month = d.month + 1
        local year = d.year
        if month > 12 then
            month = 1
            year = year+1
        end
        nextcheck = os.time({year=year, month=month, day=1})
        love.filesystem.write("subs_check.txt", tostring(nextcheck))
        
        for _, var in pairs(GetAllUsers()) do
            if var.subscriptionlevel > 0 then
                UpdateUserToDB(var.id, "tokens", var.tokens + SUBBONUS[var.subscriptionlevel][1])
                UpdateUserToDB(var.id, "subscriptiontokens", SUBBONUS[var.subscriptionlevel][2])
            end
        end
    end
end

function love.update()
    --love.timer.sleep(3)
    --db_Update()
    client:Update()
    horde.Update()
    MasterUpdate()
    checksubs()
    requests.Update()
    radom.Update()
end