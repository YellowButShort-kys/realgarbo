
local languaged_menu = {}

local function telegramformat(str)
    local __switch = true
    local newtext = ""
    for c in str:gmatch(".") do
        if c == "*" then
            if __switch then
                newtext = newtext .. "_"
            else
                newtext = newtext .. "_\n"
            end
            __switch = not __switch
        else
            newtext = newtext .. c
        end
    end
    if not __switch then
        newtext = newtext .. "_"
    end
    return newtext
end

function CreateLanguagedMenu(langcode)
    local menu = {}
    local new_chat, load_chat = client:NewInlineKeyboardButton(), client:NewInlineKeyboardButton()
    local donate, display_name = client:NewInlineKeyboardButton(), client:NewInlineKeyboardButton()
    local promocode, my_tokens = client:NewInlineKeyboardButton(), client:NewInlineKeyboardButton()
    local language = client:NewInlineKeyboardButton()
    menu.inline_keyboard = {
        {new_chat, load_chat},
        {donate, display_name},
        {promocode, my_tokens},
        {language}
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
            btn_select.text = LANG[langcode]["$NEW_CHAR_SELECT"]
            btn_select.char = var
            btn_select.callback = function(self, query)
                if not chats.GetUserChat(query.from, self.char).id then 
                    client.active_chats[query.from.id] = chats.NewChat(query.from, self.char)
                    client:EditMessageText(query.message.chat, query.message, telegramformat(translation.Translate(self.char:GetFirstMessage(query.from), "en", langcode)))
                else
                    client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$NEW_CHAR_REWRITE"], self.rewrite)
                end
            end
            
            local btn_rewrite_confirm = client:NewInlineKeyboardButton()
            btn_rewrite_confirm.text = LANG[langcode]["$NEW_CHAR_CONFIRM"]
            btn_rewrite_confirm.owner = btn_select
            btn_rewrite_confirm.callback = function(self, query)
                --chats.DeleteUserChat(query.from, self.owner.char)
                --client.active_chats[query.from.id] = chats.NewChat(query.from, self.owner.char)
                client.active_chats[query.from.id] = chats.GetUserChat(query.from, self.owner.char)
                client.active_chats[query.from.id]:SetContent(self.owner.char:GetGreeting(query.from))
                client:EditMessageText(query.message.chat, query.message, telegramformat(translation.Translate(self.owner.char:GetFirstMessage(query.from), "en", langcode)))
            end
            

            local btn_back = client:NewInlineKeyboardButton()
            btn_back.text = LANG[langcode]["$NEW_CHAR_BACK"]
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
        back.text = LANG[langcode]["$NEW_CHAR_BACK"]
        back.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
        end
        table.insert(ikm.inline_keyboard, {back})
        
        new_chat.text = LANG[langcode]["$NEW_CHAR"]
        new_chat.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$NEW_CHAR_MSG"], ikm)
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
                    client:EditMessageText(query.message.chat, query.message, telegramformat(translation.Translate(chat:GetLastResponse(), "en", langcode)))
                    client.active_chats[query.from.id] = chat
                end
            end
            
            table.insert(available_chats, button)
        end
        
        local back = client:NewInlineKeyboardButton()
        back.text = LANG[langcode]["$LOAD_CHAR_BACK"]
        back.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
        end
        

        load_chat.text = LANG[langcode]["$LOAD_CHAR"]
        load_chat.callback = function(self, query)
            local ikm = client:NewInlineKeyboardMarkup()
            ikm.inline_keyboard = {{}}
            
            local user_chats = chats.GetChats(query.from)
            local translated = {}
            for x = 1, #available_chats do
                translated[x] = 0
            end
            for _, var in ipairs(user_chats) do
                translated[var.id] = 1
            end
            
            for i, var in ipairs(translated) do
                if var == 1 then
                    if #ikm.inline_keyboard[#ikm.inline_keyboard] > 3 then
                        table.insert(ikm.inline_keyboard, {}) 
                    end
                    table.insert(ikm.inline_keyboard[#ikm.inline_keyboard], available_chats[i])
                end
            end
            table.insert(ikm.inline_keyboard, {back})
            
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$LOAD_CHAR_MSG"], ikm)
        end
    end
    
    
    -----------------------------------------------------------------------
    ------------------------------- TOKENS --------------------------------
    -----------------------------------------------------------------------

    do
        local back = client:NewInlineKeyboardButton()
        back.text = LANG[langcode]["$TOKENS_BACK"]
        back.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
            client.promocode_enter[query.from.id] = nil
        end
        
        my_tokens.text = LANG[langcode]["$TOKENS"]
        my_tokens.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$TOKENS_CURRENT_BALANCE"]:format(GetUserFromDB(query.from.id).tokens), {inline_keyboard = {{back}}})
        end
        
        donate.text = LANG[langcode]["$DONATE"]
        donate.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_TEXT"], {inline_keyboard = {{back}}})
        end
        
        promocode.text = LANG[langcode]["$PROMOCODE"]
        promocode.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$PROMOCODE_TEXT"], {inline_keyboard = {{back}}})
            client.promocode_enter[query.from.id] = query.message
        end
    end
    
    
    -----------------------------------------------------------------------
    ---------------------------- DISPLAY NAME -----------------------------
    -----------------------------------------------------------------------

    do
        local back = client:NewInlineKeyboardButton()
        back.text = LANG[langcode]["$TOKENS_BACK"]
        back.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
            client.display_name_change[query.from.id] = nil
        end
        
        display_name.text = LANG[langcode]["$DISPLAY_NAME"]
        display_name.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DISPLAY_NAME_TEXT"], {inline_keyboard = {{back}}})
            client.display_name_change[query.from.id] = query.message
        end
    end
    
    -----------------------------------------------------------------------
    -------------------------------- LANG ---------------------------------
    -----------------------------------------------------------------------

    do  
        language.text = LANG[langcode]["$SYMBOL"]
        
        local buttons = client:NewInlineKeyboardMarkup()
        table.insert(buttons.inline_keyboard, {})
        for i, var in pairs(LANG) do
            if #buttons.inline_keyboard[#buttons.inline_keyboard] == 3 then
                table.insert(buttons.inline_keyboard, {})
            end
            local lang_button = client:NewInlineKeyboardButton()
            lang_button.text = var["$SYMBOL"]
            lang_button.callback = function(self, query)
                UpdateUserToDB(query.from.id, "lang", i)
                client:EditMessageText(query.message.chat, query.message, LANG[self.text]["$INTRODUCTION"], languaged_menu[self.text])
            end
            table.insert(buttons.inline_keyboard[#buttons.inline_keyboard], lang_button)
        end
        
        
        language.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$LANG_CHANGE_TEXT"], buttons)
        end
    end
    
    ----------------------------------------------------------------------
    ---------------------------- ACTIVE CHAT -----------------------------
    ----------------------------------------------------------------------

    local ikm = client:NewInlineKeyboardMarkup()
    local function callback(task, text)
        local chat, another_chat, msg, user = task.extra[1], task.extra[2], task.extra[3], task.extra[4]
        local translated_text = telegramformat(translation.Translate(text, "en", langcode))
        msg:EditMessageText(translated_text, ikm)
        another_chat:AppendContent(text)
        
        UpdateUserToDB(user.id, "tokens", GetUserFromDB(user.id).tokens - task.kudos)
        
        another_chat.task = nil
    end
    local function errcallback(task, errmsg)
        local chat, another_chat, msg, user = task.extra[1], task.extra[2], task.extra[3], task.extra[4]
        if errmsg == "faulted" then
            msg:EditMessageText(LANG[langcode]["$CHAT_GENERATION_FAULT"], ikm)
        elseif errmsg == "impossible" then
            msg:EditMessageText(LANG[langcode]["$CHAT_GENERATION_IMPOSSIBLE"], ikm)
        end
        
        another_chat.task = nil
    end
    local instruction = [[
### Instruction:
%s: %s]]

    local back = client:NewInlineKeyboardButton()
    back.text = LANG[langcode]["$CHAT_BACK"]
    back.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
    end
    local regenerate = client:NewInlineKeyboardButton()
    regenerate.text = LANG[langcode]["$CHAT_REGENERATE"]
    regenerate.callback = function(self, query)
        if client.active_chats[query.from.id] and client.active_chats[query.from.id].lastmsg then
            client.active_chats[query.from.id].lastmsg:EditMessageText(LANG[langcode]["$AWAIT_FOR_MESSAGE"])
            client.active_chats[query.from.id]:RemoveLastResponse()
            client.active_chats[query.from.id]:GetResponse(query.message.chat, client.active_chats[query.from.id].lastmsg, query.from, callback, errcallback)
            query.message.chat:SendChatAction("typing")
        end
    end
    ikm.inline_keyboard = {{back, regenerate}}
    
    local function onMessage(self, msg)
        if client.promocode_enter[msg.from.id] then
            client:EditMessageText(client.promocode_enter[msg.from.id].chat, client.promocode_enter[msg.from.id], LANG[langcode]["$PROMOCODE_TEXT"])
            client.promocode_enter[msg.from.id] = nil
            local promo = client.promocodes[msg.text]
            if promo then
                if promo.referal then
                    if not UpdateUserReferal(msg.from, promo.referal) then
                        msg.chat:SendMessage(LANG[langcode]["$PROMOCODE_REFERAL_FAILURE"], {reply_markup = {inline_keyboard = {{back}}}})
                    else
                        msg.chat:SendMessage(LANG[langcode]["$PROMOCODE_REFERAL_SUCCESS"], {reply_markup = {inline_keyboard = {{back}}}})
                        UpdateUserToDB(msg.from.id, "tokens", GetUserFromDB(msg.from.id).tokens + promo.tokens)
                    end
                else
                    msg.chat:SendMessage(LANG[langcode]["$PROMOCODE_SUCCESS"], {reply_markup = {inline_keyboard = {{back}}}})
                    UpdateUserToDB(msg.from.id, "tokens", GetUserFromDB(msg.from.id).tokens + promo.tokens)
                end
            else
                msg.chat:SendMessage(LANG[langcode]["$PROMOCODE_NOTFOUND"], {reply_markup = {inline_keyboard = {{back}}}})
            end
            return
        end
        
        if client.display_name_change[msg.from.id] then
            UpdateUserToDB(msg.from.id, "display_name", msg.text)
            client:EditMessageText(client.display_name_change[msg.from.id].chat, client.display_name_change[msg.from.id], LANG[langcode]["$DISPLAY_NAME_TEXT"])
            msg.chat:SendMessage(LANG[langcode]["$DISPLAY_NAME_SUCCESS"], {reply_markup = {inline_keyboard = {{back}}}})
            client.display_name_change[msg.from.id] = nil
            return
        end
        
        
        if client.active_chats[msg.from.id] then
            if GetUserFromDB(msg.from.id).tokens <= 0 then
                msg.chat:SendMessage(LANG[langcode]["$CHAT_NOT_ENOUGH_TOKENS"], {inline_keyboard = {{back}}})
                return
            end 

            if client.active_chats[msg.from.id].task then
                msg.chat:SendMessage(LANG[langcode]["$UNFINISHED_GENERATION"])
                return
            end
            
            if client.active_chats[msg.from.id].lastmsg then
                client.active_chats[msg.from.id].lastmsg:EditMessageReplyMarkup()
            end
            
            msg.chat:SendChatAction("typing")
            client.active_chats[msg.from.id]:AppendContent(instruction:format(msg.from.username, translation.Translate(msg.text, langcode, "en")):gsub("♪", "*"))
            local new_msg = msg.chat:SendMessage(LANG[langcode]["$AWAIT_FOR_MESSAGE"])
            client.active_chats[msg.from.id].lastmsg = new_msg
            client.active_chats[msg.from.id]:GetResponse(msg.chat, new_msg, msg.from, callback, errcallback)
        end
    end
    
    return menu, onMessage
end











local onMessage = {}
for i, var in pairs(LANG) do
    languaged_menu[i], onMessage[i] = CreateLanguagedMenu(i)
end
local comms = {}

local command = {}
command.command = "start"
command.available_for_menu = false
table.insert(comms, client:NewCommand(command))
function command.callback(user, chat, ...)
    if not GetUserFromDB(user.id) then
        AddUserToDB(user)
    end
    chat:SendMessage(LANG[GetUserLang(user.id)]["$INTRODUCTION"], {reply_markup = languaged_menu[GetUserLang(user.id)]})
end

function client:onMessage(msg)
    if not GetUserFromDB(msg.from.id) then
        AddUserToDB(msg.from)
    end
    
    onMessage[GetUserLang(msg.from.id)](client, msg)
end

return comms