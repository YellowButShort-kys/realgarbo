master_client = telelove.NewClient({Timeout = 0})
--client = master_client

local token = "7021240836:AAFEztcG-PIwyFdyDBzVUrZtNyA5bt49xu0"

local split = function(inputstr, sep)
    local t = {}
    for str in string.gmatch(inputstr, "([^"..(sep or "%s").."]+)") do
        table.insert(t, str)
    end
    return t
end
local function GenerateRandomString(n)
    local str = ""
    for x = 1, n do
        if love.math.random(1, 2) == 1 then
            if love.math.random(1, 2) == 1 then
                str = str .. string.char(love.math.random(65, 65 + 25))
            else
                str = str .. string.char(love.math.random(65, 65 + 25)):lower()
            end
        else
            str = str .. tostring(love.math.random(0, 9))
        end
    end
    return str
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



--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local issue_promocode = master_client:NewCommand()
issue_promocode.command = "issue_promocode"
issue_promocode.description = "{target tokens}, {key=value} (name, oneperuser, singleuse)"
issue_promocode.__callback = function(user, chat, msg)
    local args = split(msg, " ")
    local target_tokens = args[1]
    
    local name
    local oneperuser, singleuse = false, false
    for x = 2, #args do
        local key, val = unpack(split(args[x], "="))
        
        if key == "name" then
            name = val
        elseif key == "oneperuser" then
            oneperuser = val == "true" and true or false
        elseif key == "singleuse" then
            singleuse = val == "true" and true or false
        end
    end
    if not name then
        while true do
            local s = GenerateRandomString(5)
            if not client.promocodes[s] then
                name = s
                break
            end
        end
    end
    
    client.promocodes[name] = {
        tokens = tonumber(target_tokens),
        singleuse = singleuse,
        oneperuser = oneperuser,
        users = {}
    }
    love.filesystem.write(PATH_PROMOCODES, prettyjson(client.promocodes))
    return name
end
issue_promocode.callback = function(user, chat, msg)
    if user.id ~= 386513759 then
        return
    end
    
    local r = {pcall(issue_promocode.__callback, user, chat, msg)}
    for i, var in pairs(r) do
        master_client:SendMessage(chat, i .. ": " .. tostring(var))
    end
end
master_client:RegisterCommand(issue_promocode)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local issue_referal = master_client:NewCommand()
issue_referal.command = "issue_referal"
issue_referal.description = "{target tokens}, {referal}, {key=value} (name, oneperuser, singleuse)"
issue_referal.__callback = function(user, chat, msg)
    local args = split(msg, " ")
    local target_tokens = args[1]
    local referal = args[2]
    local name
    local oneperuser, singleuse = false, false
    for x = 3, #args do
        local key, val = unpack(split(args[x], "="))
        
        if key == "name" then
            name = val
        elseif key == "oneperuser" then
            oneperuser = val == "true" and true or false
        elseif key == "singleuse" then
            singleuse = val == "true" and true or false
        end
    end
    if not name then
        while true do
            local s = GenerateRandomString(5)
            if not client.promocodes[s] then
                name = s
                break
            end
        end
    end
    
    client.promocodes[name] = {
        tokens = tonumber(target_tokens),
        referal = tonumber(referal),
        singleuse = singleuse,
        oneperuser = oneperuser,
        users = {}
    }
    love.filesystem.write(PATH_PROMOCODES, prettyjson(client.promocodes))
    return name
end
issue_referal.callback = function(user, chat, msg)
    if user.id ~= 386513759 then
        return
    end
    
    local r = {pcall(issue_referal.__callback, user, chat, msg)}
    for i, var in pairs(r) do
        master_client:SendMessage(chat, i .. ": " .. tostring(var))
    end
end
master_client:RegisterCommand(issue_referal)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local change_user = master_client:NewCommand()
change_user.command = "change_user"
change_user.description = "{user}, {key}, {value}"
change_user.__callback = function(user, chat, msg)
    local args = split(msg, " ")
    local id = tonumber(args[1])
    local key = args[2]
    local value = tonumber(args[3])
    UpdateUserToDB(id, key, value)
end
change_user.callback = function(user, chat, msg) 
    if user.id ~= 386513759 then
        return
    end
    
    local r = {pcall(change_user.__callback, user, chat, msg)}
    for i, var in pairs(r) do
        master_client:SendMessage(chat, i .. ": " .. tostring(var))
    end
end
master_client:RegisterCommand(change_user)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local get_users = master_client:NewCommand()
get_users.command = "get_users"
get_users.description = "{user | nil}"
get_users.__callback = function(user, chat, msg)
    local t = GetAllUsers()
    local sizes = {}
    
    for i, var in pairs(t) do
        sizes["id"] = math.max(sizes["id"] or 0, tostring(i):len())
        for key, val in pairs(var) do
            sizes[key] = math.max(sizes[key] or 0, tostring(val):len())
        end
    end
    
    local norm = {"first_name", "last_name", "username", "display_name", "tokens"}
    local str = table.concat(norm, "|") .. "\n"
    for _, var in pairs(t) do
        for _, value in ipairs(norm) do
            str = str .. tostring(var[value])
            str = str .. "|"
        end
        str = str .. "\n"
    end
    
    master_client:SendMessage(chat, str:sub(0, 4000))
    if str:len() > 4000 then
        master_client:SendMessage(chat, str:sub(4000, 8000))
    end
    if str:len() > 8000 then
        master_client:SendMessage(chat, str:sub(8000, 12000))
    end
    if str:len() > 12000 then
        master_client:SendMessage(chat, str:sub(12000, 16000))
    end
    if str:len() > 16000 then
        master_client:SendMessage(chat, str:sub(16000, 20000))
    end
end
get_users.callback = function(user, chat, msg) 
    if user.id ~= 386513759 then
        return
    end
    
    local r = {pcall(get_users.__callback, user, chat, msg)}
    for i, var in pairs(r) do
        master_client:SendMessage(chat, i .. ": " .. tostring(var))
    end
end
master_client:RegisterCommand(get_users)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local god_have_mercy = master_client:NewCommand()
god_have_mercy.command = "god_have_mercy"
god_have_mercy.description = "{nil}"
god_have_mercy.callback = function(user, chat, msg) 
    if user.id ~= 386513759 then
        return
    end

    master_client:SendMessage(chat, "for I have sinned...")
    error("Intentional stoppage from the admin panel")
end
master_client:RegisterCommand(god_have_mercy)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local get_user_chat = master_client:NewCommand()
get_user_chat.command = "get_user_chat"
get_user_chat.description = "{user}"
get_user_chat.__callback = function(user, chat, msg)
    local args = split(msg, " ")
    local id = tonumber(args[1])
    local chats = GetUserChat(GetUserFromDB(id))
    for _, var in pairs(chats) do
        master_client:SendMessage(chat, var.char.name .. " | " .. var.content:sub(0, 4000))
    end
end
get_user_chat.callback = function(user, chat, msg) 
    if user.id ~= 386513759 then
        return
    end
    
    local r = {pcall(get_user_chat.__callback, user, chat, msg)}
    for i, var in pairs(r) do
        master_client:SendMessage(chat, i .. ": " .. tostring(var))
    end
end
master_client:RegisterCommand(get_user_chat)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local replacement = {}
replacement["%_"] = "\\_"
replacement["%["] = "\\["
replacement["%]"] = "\\]"
replacement["%("] = "\\("
replacement["%)"] = "\\)"
replacement["%~"] = "\\~"
replacement["%`"] = "\\`"
replacement["%>"] = "\\>"
replacement["%#"] = "\\#"
replacement["%+"] = "\\+"
replacement["%-"] = "\\-"
replacement["%="] = "\\="
replacement["%|"] = "\\|"
replacement["%{"] = "\\{"
replacement["%}"] = "\\}"
replacement["%."] = "\\."
replacement["%!"] = "\\!"
replacement["%'"] = "\\'"
replacement['%"'] = '\\"'
replacement["%."] = "\\."

function master_client:SendToFather(msg)
    msg = msg:gsub("%\\", "\\\\")
    for i, var in pairs(replacement) do
        msg = msg:gsub(i, var)
    end
    master_client:SendMessage(386513759, msg, {["parse_mode"] = "MarkdownV2"}) 
end

--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local me_chat = master_client:NewCommand()
me_chat.command = "me_chat"
me_chat.description = "{nil}"
me_chat.__callback = function(user, chat, msg)
    local chats = GetUserChat(user)
    for _, var in pairs(chats) do
        master_client:SendMessage(chat, var.char.name .. " | " .. var.content:sub(0, 4000))
    end
end
me_chat.callback = function(user, chat, msg) 
    if user.id ~= 386513759 then
        return
    end
    
    local r = {pcall(me_chat.__callback, user, chat, msg)}
    for i, var in pairs(r) do
        master_client:SendMessage(chat, i .. ": " .. tostring(var))
    end
end
master_client:RegisterCommand(me_chat)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local announcement = master_client:NewCommand()
announcement.command = "announcement"
announcement.description = "{string}"
announcement.callback = function(user, chat, msg) 
    if user.id ~= 386513759 then
        return
    end
    
    local successes = 0
    local failures = 0
    for _, var in pairs(GetAllUsers()) do
        if var.chatid then
            local res = pcall(client.SendMessage, client, var.chatid, msg)
            if res then
                successes = successes + 1
            else
                failures = failures + 1
            end
        end
    end
    for i, var in pairs({successes=successes, failures=failures}) do
        master_client:SendMessage(chat, i .. ": " .. tostring(var))
    end
end
master_client:RegisterCommand(announcement)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local avgkudos = master_client:NewCommand()
avgkudos.command = "avgkudos"
avgkudos.description = "{}"
avgkudos.__callback = function(user, chat, msg)
    master_client:SendMessage(chat, "Average: "..tostring(AVG_KUDOS_PRICE/AVG_KUDOS_PRICE_N).."\nTotal: "..AVG_KUDOS_PRICE)
end
avgkudos.callback = function(user, chat, msg) 
    if user.id ~= 386513759 then
        return
    end
    
    local r = {pcall(avgkudos.__callback, user, chat, msg)}
    for i, var in pairs(r) do
        master_client:SendMessage(chat, i .. ": " .. tostring(var))
    end
end
master_client:RegisterCommand(avgkudos)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local runstring = master_client:NewCommand()
runstring.command = "runstring"
avgkudos.description = "{string}"
runstring.__callback = function(user, chat, msg)
    loadstring(msg)()
end
runstring.callback = function(user, chat, msg) 
    if user.id ~= 386513759 then
        return
    end
    
    local op = print
    function print(...)
        op(...)
        master_client:SendMessage(chat, table.concat({...}, "\n"))
    end
    local r = {pcall(runstring.__callback, user, chat, msg)}
    print = op
    for i, var in pairs(r) do
        master_client:SendMessage(chat, i .. ": " .. tostring(var))
    end
end
master_client:RegisterCommand(runstring)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==


master_client:Connect(token)
master_client:SetMyCommands()

function MasterUpdate()
    master_client:Update()
end
