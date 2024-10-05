require("TOKENS")
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
function prettyprint(table, key, indent)
    print( ("%s%s (%s): %s"):format(indent or "", key, type(table), tostring(table)) )
    if type(table) == "table" then
        for i, var in pairs(table) do
            prettyprint(var, i, (indent or "").."  ")
        end
    end
end
function prettyjson(t)
    local minified = master_client.__telelove.json.encode(t)
    
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
require("superdata")


https = require("https")
requests = require("extern.threaded_requests")
sql = require("extern.sqlite3")
json = require("extern.Telelove.json")
require("extern.timer")

require("sciencev2")

horde = require("api.horde")
openai = require("api.openai")
capybara = require("api.capybara_free")
dolphin = require("api.dolphin")
soliloque = require("api.soliloque")
--translation = require("api.translation")
--translation = require("api.yandex")
require("api.translatorv2")
OpenRouter = require("api.openrouter")

--llama8 = OpenRouter(nil, "meta-llama/llama-3-8b-instruct:free", {0, 0}, )

--[[
stheno8 = OpenRouter(nil, "deepseek/deepseek-chat", {100, 50}, {
    temperature = 1.5,
    max_tokens = 80,
    provider = {
        ignore = {
            "Hyperbolic"
        }
    },
})
]]
stheno8 = OpenRouter(nil, "gryphe/mythomax-l2-13b", {1, 1}, {
    temperature = 1.1,
    max_tokens = 150,
    provider = {
        order = {
            "Novita"
        },
        allow_fallbacks = false,
    },
})
--[[
stheno8 = OpenRouter(nil, "nousresearch/hermes-3-llama-3.1-405b:free", {100, 200}, {
    temperature = 0.85,
    max_tokens = 80
})
]]

--radom = require("__payment_processor")
--radom.SetToken("eyJhZGRyZXNzIjpudWxsLCJvcmdhbml6YXRpb25faWQiOiJlNjZjMTk5Zi1lYzgzLTRkNWUtYjhkOS0zZWI1NTI4MDI0YzQiLCJzZXNzaW9uX2lkIjoiNGNkNjEzYmMtMmZjMS00NDQ3LWE4NTEtOWIwMTkwN2Y2MjFiIiwiZXhwaXJlZF9hdCI6IjIwMjUtMDUtMDNUMDg6NTY6MjIuOTkyNTgxNDM2WiIsImlzX2FwaV90b2tlbiI6dHJ1ZX0=")
--radom.ListProducts()

require("lang")


local opn = sqlite3.open
--KOBOLD = 3q7qnr2bMDMUo_5Yww4QHA
--ANOTHER = 0000000000

local science = require("science")
ScienceCharUsage = science.New("log_charusage.csv", "%d; %t; %s")
ScienceTokenUsage = science.New("log_tokenusage.csv", "%d; %t; %s; %s")




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


telelove = require("extern.Telelove")
client = telelove.NewClient()
client.active_chats = {}
client.group_active_chats = {}
client.display_name_change = {}
client.promocode_enter = {}
client.promocodes = telelove.json.decode(love.filesystem.read(PATH_PROMOCODES))
client.payments = {}

--FALLBACK = {}

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
function client:onCallbackError(btn, query, msg)
    local bruh = ((debug.traceback("Error: " .. tostring(msg), 1+(1)):gsub("\n[^\n]+$", "")))
    query.message.chat:SendMessage("Произошла ошибка при обработке запроса! Попробуйте открыть меню заново с помощью /start")
    master_client:SendToFather(bruh)
    print(bruh)
end

client:Connect(TELEGRAM_TOKEN)
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

local nativefs = require("extern/nativefs")
local nextcheck = tonumber((nativefs.read("/root/Carp/realgarbo/subs_check.txt")))
local rewrite = false
if not nextcheck then
    rewrite = true
    nextcheck = os.time()
end
SUBBONUS = {
    {500, 11100},
    {1750, 38850},
    {3780, 83160}
}
local function checksubs()
    if os.time() >= nextcheck or rewrite then
        print("SUBS TIME LOL")
        master_client:SendToFather("SUBS TIME LOL")
        local d = os.date("*t", nextcheck)
        local month = d.month + 1
        local year = d.year
        if month > 12 then
            month = 1
            year = year+1
        end
        nextcheck = os.time({year=year, month=month, day=1})
        nativefs.write("/root/Carp/realgarbo/subs_check.txt", tostring(nextcheck))
        
        local count = 0
        for _, var in pairs(GetAllUsers()) do
            if var.subscriptionlevel > 0 then
                UpdateUserToDB(var.id, "tokens", var.tokens + SUBBONUS[var.subscriptionlevel][1])
                UpdateUserToDB(var.id, "subscriptiontokens", SUBBONUS[var.subscriptionlevel][2])
                count = count + 1
            end
        end
        print(count .. " subs are active")
        master_client:SendToFather(count .. " subs are active")
    end
end

local nextcheck2 = os.time()
local function notifications()
    if os.time() >= nextcheck2 then
        for _, var in pairs(GetAllUsers()) do
            if var.nextnotification <= os.time() then
                UpdateUserToDB(var.id, "nextnotification", os.time() + AFK_NOTIFICATION_TIMEOUT)
                client:SendMessage(var.chatid, "Привет! Вас давно не было видно, поэтому мы решили напомнить о себе. Если у вас что-то не работает или есть идеи, напишите об этом в поддержку: https://t.me/CarpAISupportBot")
            end
        end
        
        nextcheck2 = nextcheck2 + 300
    end
end

function love.update()
    --love.timer.sleep(3)
    --db_Update()
    client:Update()
    horde.Update()
    MasterUpdate()
    checksubs()
    --notifications()
    requests.Update()
    --radom.Update()
    timer.Update()
end