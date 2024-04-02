menu = client:RegisterInlineKeyboardMarkup("main_menu")
local comms = {}

local command = {}
command.command = "start"
command.available_for_menu = false
table.insert(comms, client:NewCommand(command))
function command.callback(user, chat, ...)
    if not GetUserFromDB(user.id) then
        AddUserToDB(user)
    end
    chat:SendMessage(LANG["ru"]["$INTRODUCTION"], {reply_markup = menu})
    --[=[
    --TODO functionalize?
    
    local db = db_userlist
    if db then
        local sQuery = [[
        CREATE TABLE IF NOT EXISTS Users (
            id INTEGER,
            first_name TEXT,
            last_name TEXT,
            username TEXT,
            tokens INTEGER,
            PRIMARY KEY (id)
        )
        ]]
        db:execute(sQuery)
        
        sQuery = [[
            INSERT INTO Users (id, first_name, last_name, username, tokens)
            VALUES (%s, '%s', '%s', '%s', %s)
        ]]
        db:execute(sQuery:format(user.id, user.first_name, user.last_name, user.username, 50))
        
        --db:close()
        
    end
    ]=]
end
--client:NewCommand(command)



local new_chat, load_chat = client:NewInlineKeyboardButton(), client:NewInlineKeyboardButton()
local donate, display_name = client:NewInlineKeyboardButton(), client:NewInlineKeyboardButton()
local promocode, my_tokens = client:NewInlineKeyboardButton(), client:NewInlineKeyboardButton()
local language = client:NewInlineKeyboardButton()


menu.inline_keyboard = {
    {new_chat, load_chat},
    {donate, display_name},
    {promocode, my_tokens},
    --{language}
}


---------------------------------------------------------------------
----------------------------- NEW CHAT ------------------------------
---------------------------------------------------------------------

do
    local chars = {}
    for _, var in ipairs(characters.GetHub()) do
        local button_more = client:NewInlineKeyboardButton()
        button_more.text = var.name
        button_more.char = var
        button_more.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, self.char.name..":\n"..self.char.description, self.ikm)
        end
        
        
        button_more.ikm = client:NewInlineKeyboardMarkup()
        
        
        local btn_select = client:NewInlineKeyboardButton()
        btn_select.text = LANG["ru"]["$NEW_CHAR_SELECT"]
        btn_select.char = var
        btn_select.callback = function(self, query)
            if not chats.GetUserChat(query.from, self.char).id then 
                client.active_chats[query.from.id] = chats.NewChat(query.from, self.char)
                client:EditMessageText(query.message.chat, query.message, translation.ToRussian(self.char:GetFirstMessage(query.from)))
            else
                client:EditMessageText(query.message.chat, query.message, LANG["ru"]["$NEW_CHAR_REWRITE"], self.rewrite)
            end
        end
        
        local btn_rewrite_confirm = client:NewInlineKeyboardButton()
        btn_rewrite_confirm.text = LANG["ru"]["$NEW_CHAR_CONFIRM"]
        btn_rewrite_confirm.owner = btn_select
        btn_rewrite_confirm.callback = function(self, query)
            --chats.DeleteUserChat(query.from, self.owner.char)
            --client.active_chats[query.from.id] = chats.NewChat(query.from, self.owner.char)
            client.active_chats[query.from.id] = chats.GetUserChat(query.from, self.owner.char)
            client.active_chats[query.from.id]:SetContent(self.owner.char:GetGreeting(query.from))
            client:EditMessageText(query.message.chat, query.message, translation.ToRussian(self.owner.char:GetFirstMessage(query.from)))
        end
        

        local btn_back = client:NewInlineKeyboardButton()
        btn_back.text = LANG["ru"]["$NEW_CHAR_BACK"]
        btn_back.callback = function(self, query)
            new_chat:callback(query)
        end
        button_more.ikm.inline_keyboard = {{btn_back, btn_select}}
        
        btn_select.rewrite = client:NewInlineKeyboardMarkup()
        btn_select.rewrite.inline_keyboard = {{btn_back, btn_rewrite_confirm}}
        table.insert(chars, button_more)
    end
    
    local ikm = client:NewInlineKeyboardMarkup()
    local counter = 1
    while true do
        if not chars[counter] then break end
        table.insert(ikm.inline_keyboard, {
            chars[counter],
            chars[counter+1],
            chars[counter+2],
        })
        counter = counter + 3
    end
    local back = client:NewInlineKeyboardButton()
    back.text = LANG["ru"]["$NEW_CHAR_BACK"]
    back.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG["ru"]["$INTRODUCTION"], menu)
    end
    table.insert(ikm.inline_keyboard, {back})
    
    new_chat.text = LANG["ru"]["$NEW_CHAR"]
    new_chat.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG["ru"]["$NEW_CHAR_MSG"], ikm)
    end
end


----------------------------------------------------------------------
----------------------------- LOAD CHAT ------------------------------
----------------------------------------------------------------------


do
    local available_chats = {}
    for _, var in ipairs(characters.GetHub()) do
        local button = client:NewInlineKeyboardButton()
        button.text = var.name
        button.char = var
        button.callback = function(self, query)
            
            local chat = chats.GetUserChat(query.from, self.char)
            if chat then
                client:EditMessageText(query.message.chat, query.message, translation.ToRussian(chat:GetLastResponse()))
                print(query.from.id, type(query.from.id))
                client.active_chats[query.from.id] = chat
            end
        end
        
        table.insert(available_chats, button)
    end
    
    local back = client:NewInlineKeyboardButton()
    back.text = LANG["ru"]["$LOAD_CHAR_BACK"]
    back.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG["ru"]["$INTRODUCTION"], menu)
    end
    

    load_chat.text = LANG["ru"]["$LOAD_CHAR"]
    load_chat.callback = function(self, query)
        local ikm = client:NewInlineKeyboardMarkup()
        ikm.inline_keyboard = {{}}
        
        local user_chats = chats.GetChats(query.from)
        local translated = {}
        for x = 1, #available_chats do
            translated[x] = false
        end
        for _, var in ipairs(user_chats) do
            translated[var.id] = true
        end
        
        for i, var in ipairs(translated) do
            if var then
                if #ikm.inline_keyboard[#ikm.inline_keyboard] > 3 then
                    table.insert(ikm.inline_keyboard, {}) 
                end
                table.insert(ikm.inline_keyboard[#ikm.inline_keyboard], available_chats[i])
            end
        end
        table.insert(ikm.inline_keyboard, {back})
        
        client:EditMessageText(query.message.chat, query.message, LANG["ru"]["$LOAD_CHAR_MSG"], ikm)
    end
end

-----------------------------------------------------------------------
------------------------------- TOKENS --------------------------------
-----------------------------------------------------------------------

do
    local back = client:NewInlineKeyboardButton()
    back.text = LANG["ru"]["$TOKENS_BACK"]
    back.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG["ru"]["$INTRODUCTION"], menu)
        client.promocode_enter[query.from.id] = nil
    end
    
    my_tokens.text = LANG["ru"]["$TOKENS"]
    my_tokens.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG["ru"]["$TOKENS_CURRENT_BALANCE"]:format(GetUserFromDB(query.from.id).tokens), {inline_keyboard = {{back}}})
    end
    
    donate.text = LANG["ru"]["$DONATE"]
    donate.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG["ru"]["$DONATE_TEXT"], {inline_keyboard = {{back}}})
    end
    
    promocode.text = LANG["ru"]["$PROMOCODE"]
    promocode.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG["ru"]["$PROMOCODE_TEXT"], {inline_keyboard = {{back}}})
        client.promocode_enter[query.from.id] = query.message
    end
end

-----------------------------------------------------------------------
---------------------------- DISPLAY NAME -----------------------------
-----------------------------------------------------------------------

do
    local back = client:NewInlineKeyboardButton()
    back.text = LANG["ru"]["$TOKENS_BACK"]
    back.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG["ru"]["$INTRODUCTION"], menu)
        client.display_name_change[query.from.id] = nil
    end
    
    display_name.text = LANG["ru"]["$DISPLAY_NAME"]
    display_name.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG["ru"]["$DISPLAY_NAME_TEXT"], {inline_keyboard = {{back}}})
        client.display_name_change[query.from.id] = query.message
    end
end


-----------------------------------------------------------------------
-------------------------------- LANG ---------------------------------
-----------------------------------------------------------------------

--[[
do  
    language.text = LANG["ru"]["$SYMBOL"]
    
    local buttons = client:NewInlineKeyboardMarkup()
    table.insert(buttons.inline_keyboard, {})
    for i, var in pairs(LANG) do
        if #buttons.inline_keyboard[#buttons] == 3 then
            table.insert(buttons.inline_keyboard, {})
        end
        local lang_button = client:NewInlineKeyboardButton()
        lang_button.text = var["$SYMBOL"]
        lang_button.callback = function(self, query)
            UpdateUserToDB(query.from.id, "lang", i)
            client:EditMessageText(query.message.chat, query.message, LANG[GetUserLang(query.from.id)]["$INTRODUCTION"], menu)
        end
    end
    
    
    language.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[GetUserLang(query.from.id)]["$DISPLAY_NAME_TEXT"], buttons)
    end
end
]]

----------------------------------------------------------------------
---------------------------- ACTIVE CHAT -----------------------------
----------------------------------------------------------------------

local ikm = client:NewInlineKeyboardMarkup()
local function callback(task, text)
    local chat, another_chat, msg, user = task.extra[1], task.extra[2], task.extra[3], task.extra[4]
    msg:EditMessageText(translation.ToRussian(text), ikm)
    another_chat:AppendContent(text)
    
    UpdateUserToDB(user.id, "tokens", GetUserFromDB(user.id).tokens - task.kudos)
    
    another_chat.task = nil
end
local instruction = [[
### Instruction:
%s: %s
]]

local back = client:NewInlineKeyboardButton()
back.text = LANG["ru"]["$CHAT_BACK"]
back.callback = function(self, query)
    client:EditMessageText(query.message.chat, query.message, LANG[GetUserLang(query.from.id)]["$INTRODUCTION"], menu)
end
local regenerate = client:NewInlineKeyboardButton()
regenerate.text = LANG["ru"]["$CHAT_REGENERATE"]
regenerate.callback = function(self, query)
    if client.active_chats[query.from.id] and client.active_chats[query.from.id].lastmsg then
        client.active_chats[query.from.id].lastmsg:EditMessageText(LANG[GetUserLang(query.from.id)]["$AWAIT_FOR_MESSAGE"])
        client.active_chats[query.from.id]:RemoveLastResponse()
        client.active_chats[query.from.id]:GetResponse(query.message.chat, client.active_chats[query.from.id].lastmsg, query.from, callback)
        query.message.chat:SendChatAction("typing")
    end
end
ikm.inline_keyboard = {{back, regenerate}}


function client:onMessage(msg)
    if client.promocode_enter[msg.from.id] then
        client:EditMessageText(client.promocode_enter[msg.from.id].chat, client.promocode_enter[msg.from.id], LANG["ru"]["$PROMOCODE_TEXT"])
        client.promocode_enter[msg.from.id] = nil
        local promo = client.promocodes[msg.text]
        if promo then
            if promo.referal then
                if not UpdateUserReferal(msg.from, promo.referal) then
                    msg.chat:SendMessage(LANG["ru"]["$PROMOCODE_REFERAL_FAILURE"], {reply_markup = {inline_keyboard = {{back}}}})
                else
                    msg.chat:SendMessage(LANG["ru"]["$PROMOCODE_REFERAL_SUCCESS"], {reply_markup = {inline_keyboard = {{back}}}})
                    UpdateUserToDB(msg.from.id, "tokens", GetUserFromDB(msg.from.id).tokens + promo.tokens)
                end
            else
                msg.chat:SendMessage(LANG["ru"]["$PROMOCODE_SUCCESS"], {reply_markup = {inline_keyboard = {{back}}}})
                UpdateUserToDB(msg.from.id, "tokens", GetUserFromDB(msg.from.id).tokens + promo.tokens)
            end
        else
            msg.chat:SendMessage(LANG["ru"]["$PROMOCODE_NOTFOUND"], {reply_markup = {inline_keyboard = {{back}}}})
        end
        return
    end
    
    if client.display_name_change[msg.from.id] then
        UpdateUserToDB(msg.from.id, "display_name", msg.text)
        client:EditMessageText(client.display_name_change[msg.from.id].chat, client.display_name_change[msg.from.id], LANG["ru"]["$DISPLAY_NAME_TEXT"])
        msg.chat:SendMessage(LANG["ru"]["$DISPLAY_NAME_SUCCESS"], {reply_markup = {inline_keyboard = {{back}}}})
        client.display_name_change[msg.from.id] = nil
        return
    end
    
    
    if client.active_chats[msg.from.id] then
        if GetUserFromDB(msg.from.id).tokens <= 0 then
            msg.chat:SendMessage(LANG["ru"]["$CHAT_NOT_ENOUGH_TOKENS"], {inline_keyboard = {{back}}})
            return
        end 

        if client.active_chats[msg.from.id].task then
            msg.chat:SendMessage(LANG["ru"]["$UNFINISHED_GENERATION"])
            return
        end
        
        if client.active_chats[msg.from.id].lastmsg then
            client.active_chats[msg.from.id].lastmsg:EditMessageReplyMarkup()
        end
        
        msg.chat:SendChatAction("typing")
        client.active_chats[msg.from.id]:AppendContent(instruction:format(msg.from.username, translation.ToEnglish(msg.text)):gsub("♪", "*"))
        local new_msg = msg.chat:SendMessage(LANG["ru"]["$AWAIT_FOR_MESSAGE"])
        client.active_chats[msg.from.id].lastmsg = new_msg
        client.active_chats[msg.from.id]:GetResponse(msg.chat, new_msg, msg.from, callback)
    end
end





--[=[
            local str = "Here are the available characters:\n\n"
        for _, var in ipairs(characters.GetHub()) do
            str = str..([[
```
ID: %s
Name: %s
```
]]):format(var.id, var.name)
end
        
chat:SendMessage(str)
client:SetMyCommands(commands.new_chat)
end
]=]

--[==[

local command = {}
command.command = "master"
command.available_for_menu = false
--table.insert(comms, client:NewCommand(command))
function command.callback(user, chat, ...)
   client.master = chat 
end


local command = {}
command.command = "chat_selection"
command.description = "Opens your active chats"
--table.insert(comms, client:NewCommand(command))
function command.callback(user, chat)
    local str = "Here are your active chats:\n\n"
    for _, var in ipairs(chats.GetChats(user)) do
        str = str..([[
```
ID: %s
Name: %s
```
        ]]):format(var.id, var.char.name)
    end
    
    chat:SendMessage(str)
    client:SetMyCommands(commands.chat_selection)
end


local command = {}
command.command = "new_chat"
command.description = "Create a new chat"
--table.insert(comms, client:NewCommand(command))
function command.callback(user, chat)
    local str = "Here are the available characters:\n\n"
    for _, var in ipairs(characters.GetHub()) do
        str = str..([[
```
ID: %s
Name: %s
```
]]):format(var.id, var.name)
    end
    
    chat:SendMessage(str)
    client:SetMyCommands(commands.new_chat)
end


local command = {}
command.command = "my_tokens"
command.description = "See your current balance"
--table.insert(comms, client:NewCommand(command))
function command.callback(user, chat)
    local db = db_userlist
    
    if db then
        local sQuery = ([[
            SELECT tokens FROM Users
            WHERE id = "%s";
        ]]):format(user.id)
        local res = db:execute(sQuery)
        if res and res[1] then
            print(chat.SendMessage)
            print(getmetatable(chat).SendMessage)
            chat:SendMessage(("You currently have %s tokens"):format(res[1].tokens))
        end
    end
end


local command = {}
command.command = "promocode"
command.description = "Free goodies!"
--table.insert(comms, client:NewCommand(command))
function command.callback(user, chat, ...)
    local db = sqlite3.open("C:/Trash/_MONEY/_adventure/db/promocodes.db")
    
    if db then
        local sQuery = [[
        CREATE TABLE IF NOT EXISTS Promocodes (
            name TEXT,
            reward INTEGER,
            once_per_user INTEGER,
            uses INTEGER,
            users TEXT,
            PRIMARY KEY (name)
        )   
        ]]
        db:execute(sQuery) 
    end
    
    
    --[=[
        sQuery = [[ 
            INSERT INTO Promocodes
            VALUES ("gay2", 1000, 0, 0, "");
            
            INSERT INTO Promocodes
            VALUES ("gay", 1000, 1, 0, "");
        ]]
        db:execute(sQuery:format(user.id, user.first_name, user.last_name, user.username, 0))
    ]=]
    
    if db then
        local name = ...
        local sQuery = ([[
            SELECT * FROM Promocodes
            WHERE name = "%s";
        ]]):format(name)
        local huh = (db:execute(sQuery))
        if huh and huh[1] then
            if huh[1].once_per_user == "0" or huh[1].once_per_user == "1" and not huh[1].users:find(user.id) then
                sQuery = ([[
                    UPDATE Promocodes
                    SET uses = %s, users = "%s"
                    WHERE name = "%s";
                ]]):format(huh[1].uses+1, huh[1].users..(huh[1].users ~= "" and "; " or "")..user.id, name)
                db:execute(sQuery)
                
                local ndb = sqlite3.open(PATH_DB_USERS)
                local res
                if ndb then
                    local sQuery = ([[
                        UPDATE Users
                        SET tokens = tokens + %s
                        WHERE id = "%s";
                        
                        SELECT tokens FROM Users
                        WHERE id = "%s";
                    ]]):format(huh[1].reward, user.id, user.id)
                    res = ndb:execute(sQuery)
                end
                --db:close()
                
                
                chat:SendMessage(("You've successfully used a promocode for %s tokens. You now have %s tokens. Congrats!"):format(huh[1].reward, res[1].tokens))
            else
                chat:SendMessage("You've already used this promocode!")
            end
        else
            chat:SendMessage("No such promocode was found")
        end
    end
    
    --db:close()
end

]==]

    

return comms