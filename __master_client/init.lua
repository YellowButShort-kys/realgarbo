local master_client = telelove.NewClient()
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
local function prettyjson(t)
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
issue_promocode.description = "{target tokens}, {name}"
issue_promocode.__callback = function(user, chat, msg)
    local args = split(msg, " ")
    local target_tokens = args[1]
    local name = args[2]
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
        tokens = tonumber(target_tokens)
    }
    love.filesystem.write(PATH_PROMOCODES, prettyjson(client.promocodes))
end
issue_promocode.callback = function(user, chat, msg)
    if user.id ~= 386513759 then
        return
    end
    
    local r = {pcall(issue_promocode.__callback, user, chat, msg)}
    for i, var in pairs(r) do
        chat:SendMessage(i .. ": " .. tostring(var))
    end
end
master_client:RegisterCommand(issue_promocode)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local issue_referal = master_client:NewCommand()
issue_referal.command = "issue_referal"
issue_referal.description = "{target tokens}, {referal}, {name}"
issue_referal.__callback = function(user, chat, msg)
    local args = split(msg, " ")
    local target_tokens = args[1]
    local referal = args[2]
    local name = args[3]
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
        referal = tonumber(referal)
    }
    love.filesystem.write(PATH_PROMOCODES, prettyjson(client.promocodes))
end
issue_referal.callback = function(user, chat, msg)
    if user.id ~= 386513759 then
        return
    end
    
    local r = {pcall(issue_referal.__callback, user, chat, msg)}
    for i, var in pairs(r) do
        chat:SendMessage(i .. ": " .. tostring(var))
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
    local id = args[1]
    local key = args[2]
    local value = args[3]
    UpdateUserToDB(id, key, value)
end
change_user.callback = function(user, chat, msg) 
    if user.id ~= 386513759 then
        return
    end
    
    local r = {pcall(change_user.__callback, user, chat, msg)}
    for i, var in pairs(r) do
        chat:SendMessage(i .. ": " .. tostring(var))
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
    
    local norm = {"id", "first_name", "last_name", "username", "display_name", "tokens"}
    local str = table.concat(norm, "|")
    for _, var in pairs(t) do
        for _, value in ipairs(norm) do
            str = str .. tostring(var[value])
            str = str .. "|"
        end
        str = str .. "\n"
    end
    
    chat:SendMessage(str:sub(0, 4000))
    if str:len() > 4000 then
        chat:SendMessage(str:sub(4000, 8000))
    end
    if str:len() > 8000 then
        chat:SendMessage(str:sub(8000, 12000))
    end
    if str:len() > 12000 then
        chat:SendMessage(str:sub(12000, 16000))
    end
    if str:len() > 16000 then
        chat:SendMessage(str:sub(16000, 20000))
    end
end
get_users.callback = function(user, chat, msg) 
    if user.id ~= 386513759 then
        return
    end
    
    local r = {pcall(get_users.__callback, user, chat, msg)}
    for i, var in pairs(r) do
        chat:SendMessage(i .. ": " .. tostring(var))
    end
end
master_client:RegisterCommand(get_users)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
local god_have_mercy = master_client:NewCommand()
god_have_mercy.command = "god_have_mercy"
god_have_mercy.description = "{nil}"
god_have_mercy.__callback = function(user, chat, msg)
    chat:SendMessage("for I have sinned...")
    error("Intentional stoppage from the admin panel")
end
god_have_mercy.callback = function(user, chat, msg) 
    if user.id ~= 386513759 then
        return
    end
    
    local r = {pcall(god_have_mercy.__callback, user, chat, msg)}
    for i, var in pairs(r) do
        chat:SendMessage(i .. ": " .. tostring(var))
    end
end
master_client:RegisterCommand(god_have_mercy)
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==

master_client:Connect(token)

function MasterUpdate()
    master_client:Update()
end
