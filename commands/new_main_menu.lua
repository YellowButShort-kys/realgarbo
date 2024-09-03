
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

local function htmlformat(str)
    local asterics = false
    local function match()
        asterics = not asterics
        return asterics and "<b><i>" or "</i></b>"
    end
    str = (str:gsub("%*", match))
    if asterics then
        str = str .. "</i></b>"
    end
    return str
end

local function isEmpty(str)
    return str:gsub("\n", ""):gsub(" ", ""):len() > 3
end


local encoding_table = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
}
local decoding_table = {}
for i, var in ipairs(encoding_table) do
    decoding_table[tostring(var)] = i
end
local function decode(string)
    local offset = 0
    return (string.gsub(string, ".", function(h)
        offset = offset + 1
        return (decoding_table[h]-offset)/2
    end))
end

function CreateLanguagedMenu(langcode)
    local menu = {}
    local char_creation = client:NewInlineKeyboardButton()
    local new_chat, load_chat, select_model = client:NewInlineKeyboardButton(), client:NewInlineKeyboardButton(), client:NewInlineKeyboardButton()
    local donate, profile = client:NewInlineKeyboardButton(), client:NewInlineKeyboardButton()
    local promocode, dailies, my_tokens = client:NewInlineKeyboardButton(), client:NewInlineKeyboardButton(), client:NewInlineKeyboardButton()
    local language = client:NewInlineKeyboardButton()
    menu.inline_keyboard = {
        {new_chat, load_chat},
        {donate, profile},
        {promocode, dailies},
        {language}
    }
    
    ---------------------------------------------------------------------
    ----------------------------- NEW CHAT ------------------------------
    ---------------------------------------------------------------------
    do
        local chars = {}
        local ikm = client:NewInlineKeyboardMarkup()
        for _, var in ipairs(characters.GetHub()) do
            local button_more = client:NewInlineKeyboardButton()
            button_more.text = var.display_name[langcode] or var.name
            button_more.char = var
            button_more.callback = function(self, query)
                client:EditMessageText(query.message.chat, query.message, (var.display_name[langcode] or var.name)..":\n"..var.description[langcode], self.ikm)
            end
            
            
            button_more.ikm = client:NewInlineKeyboardMarkup()  
            
            
            local btn_select = client:NewInlineKeyboardButton()
            btn_select.text = LANG[langcode]["$NEW_CHAR_SELECT"]
            btn_select.char = var
            btn_select.callback = function(self, query)
                if not chats.GetUserChat(query.from, self.char) then 
                    client.active_chats[query.from.id] = chats.NewChat(query.from, self.char)
                    client:EditMessageText(query.message.chat, query.message, htmlformat(translation.Translate(self.char:GetFirstMessage(query.from), "en", langcode)))
                    --ScienceCharUsage(self.char:GetName())
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
                --client.active_chats[query.from.id]:SetContent(self.owner.char:GetStarter(query.from))
                client.active_chats[query.from.id]:ResetChat()
                client:EditMessageText(query.message.chat, query.message, htmlformat(translation.Translate(self.owner.char:GetFirstMessage(query.from), "en", langcode)))
                --ScienceCharUsage(self.owner.char:GetName())
            end
            

            local btn_back = client:NewInlineKeyboardButton()
            btn_back.text = LANG[langcode]["$NEW_CHAR_BACK"]
            btn_back.callback = function(self, query)
                new_chat:callback(query)
            end
            button_more.ikm.inline_keyboard = {{btn_back, btn_select}}
            
            btn_select.rewrite = client:NewInlineKeyboardMarkup()
            btn_select.rewrite.inline_keyboard = {{btn_back, btn_rewrite_confirm}}
            for _, tag in ipairs(var.tags) do
                if not chars[tag] then
                    chars[tag] = {}
                end
                table.insert(chars[tag], button_more)
            end
            
            if var == characters.GetWeekly() then
                local btn = button_more
                btn.text = LANG[langcode]["$NEW_CHAR_WEEKLY"]:format(var:GetDisplayName(langcode))
                table.insert(ikm.inline_keyboard, {btn})
            end
        end
        
        
        local btns = {}
        for tag, var in pairs(chars) do
            local tagikm = client:NewInlineKeyboardMarkup()
            local counter = 1
            while true do
                if not var[counter] then break end
                table.insert(tagikm.inline_keyboard, {
                    var[counter],
                    var[counter+1],
                    var[counter+2],
                })
                counter = counter + 3
            end
            local back = client:NewInlineKeyboardButton()
            back.text = LANG[langcode]["$NEW_CHAR_BACK"]
            back.callback = function(self, query)
                client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$NEW_CHAR_MSG"], ikm)
            end
            table.insert(tagikm.inline_keyboard, {})
            table.insert(tagikm.inline_keyboard, {back})
            
            local button = client:NewInlineKeyboardButton()
            button.text = tag
            button.callback = function(self, query)
                client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$NEW_CHAR_MSG"], tagikm)
            end
            table.insert(btns, button)
        end
        local counter = 1
        
        while true do
            if not btns[counter] then break end
            table.insert(ikm.inline_keyboard, {
                btns[counter],
                btns[counter+1],
                btns[counter+2],
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
                    client:EditMessageText(query.message.chat, query.message, htmlformat(translation.Translate(chat:GetLastResponse(), "en", langcode)))
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
                translated[x] = user_chats[x] and 1 or 0
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
    
    ------------------------------------------------------------------------
    ------------------------------- PROFILE --------------------------------
    ------------------------------------------------------------------------

    do
        local back = client:NewInlineKeyboardButton()
        back.text = LANG[langcode]["$TOKENS_BACK"]
        back.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
            client.promocode_enter[query.from.id] = nil
        end
        
        my_tokens.text = LANG[langcode]["$TOKENS"]
        my_tokens.callback = function(self, query)
            local user = GetUserFromDB(query.from.id)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$TOKENS_CURRENT_BALANCE"]:format(user.tokens, user.subscriptiontokens), {inline_keyboard = {{back}}})
        end
        
        
        require("commands.donation")(langcode, menu, donate)
        --[[
        donate.text = LANG[langcode]["$DONATE"]
        donate.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_TEXT"], {inline_keyboard = {{back}}})
        end
        ]]
        
        promocode.text = LANG[langcode]["$PROMOCODE"]
        promocode.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$PROMOCODE_TEXT"], {inline_keyboard = {{back}}})
            client.promocode_enter[query.from.id] = query.message
        end
    end
    
    
    -----------------------------------------------------------------------
    ---------------------------- DISPLAY NAME -----------------------------
    -----------------------------------------------------------------------

    
    require("commands.profile")(langcode, menu, profile)
    --[[
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
    ]]
    
    -----------------------------------------------------------------------
    -------------------------------- LANG ---------------------------------
    -----------------------------------------------------------------------

    do  
        language.text = LANG[langcode]["$SYMBOL"]
        
        local buttons = client:NewInlineKeyboardMarkup()
        table.insert(buttons.inline_keyboard, {})
        for i, var in ipairs(LANG) do
            if #buttons.inline_keyboard[#buttons.inline_keyboard] == 3 then
                table.insert(buttons.inline_keyboard, {})
            end
            local lang_button = client:NewInlineKeyboardButton()
            lang_button.text = var["$SYMBOL"]
            lang_button.callback = function(self, query)
                UpdateUserToDB(query.from.id, "lang", i)
                client:EditMessageText(query.message.chat, query.message, LANG[i]["$INTRODUCTION"], languaged_menu[i])
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
    local errcallback
    local function callback(task, text)
        local chat, another_chat, msg, user = task.extra[1], task.extra[2], task.extra[3], task.extra[4]
        local legit = isEmpty(text)
        local translated_text
        if legit then
            translated_text = htmlformat(translation.Translate(text, "en", langcode))
        else
            translated_text = LANG[langcode]["$CHAT_GENERATION_EMPTY"]
        end
        another_chat.task = nil
        
        --FALLBACK[msg.id] = nil
        msg:DeleteMessage()
        chat:SendMessage(another_chat.char:FormatOutput(another_chat, translated_text), {reply_markup = {inline_keyboard = ikm.inline_keyboard}})
        
        --msg:EditMessageText(another_chat.char:FormatOutput(another_chat, translated_text), ikm)
        if legit then
            another_chat:AppendContent(text, "assistant")
            
            local dbuser = GetUserFromDB(user.id)
            if dbuser.subscriptiontokens - task.kudos >= 0 then
                UpdateUserToDB(user.id, "subscriptiontokens", math.max(dbuser.subscriptiontokens - task.kudos, 0))
            else
                UpdateUserToDB(user.id, "tokens", math.max(dbuser.tokens - task.kudos, 0))
            end
            ScienceTokenUsage(user.id, task.kudos)
            AVG_KUDOS_PRICE = AVG_KUDOS_PRICE + task.kudos
            AVG_KUDOS_PRICE_N = AVG_KUDOS_PRICE_N + 1
        end
    end
    function errcallback(task, errmsg)
        local chat, another_chat, msg, user = task.extra[1], task.extra[2], task.extra[3], task.extra[4]
        --FALLBACK[msg.id] = nil
        if errmsg == "faulted" then
            msg:EditMessageText(LANG[langcode]["$CHAT_GENERATION_FAULT"], ikm)
        elseif errmsg == "impossible" then
            msg:EditMessageText(LANG[langcode]["$CHAT_GENERATION_IMPOSSIBLE"], ikm)
        elseif errmsg == "Timedout" then
            msg:EditMessageText(LANG[langcode]["$CHAT_GENERATION_TIMEOUT"], ikm) 
        else
            msg:EditMessageText(LANG[langcode]["$CHAT_GENERATION_FAULT"], ikm) 
        end
        
        another_chat.task = nil
    end
    
    

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
            --FALLBACK[client.active_chats[query.from.id].lastmsg.id] = client.active_chats[query.from.id].lastmsg
            client.active_chats[query.from.id]:RemoveLastResponse()
            client.active_chats[query.from.id]:GetResponse(query.message.chat, client.active_chats[query.from.id].lastmsg, query.from, callback, errcallback)
            query.message.chat:SendChatAction("typing")
        end
    end
    ikm.inline_keyboard = {{back, regenerate}}
    
    ----------------------------------------------------------------------
    ------------------------------ DAILIES -------------------------------
    ----------------------------------------------------------------------
    
    do
        dailies.text = LANG[langcode]["$DAILIES"]
        dailies.callback = function(self, query)
            local user = GetUserFromDB(query.from.id)
            if user.next_daily <= os.time() then
                if user.tokens <= DAILY_BONUS/2 then
                    client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DAILIES_SUCCESS"], {inline_keyboard = {{back}}})
                    UpdateUserToDB(query.from.id, "tokens", user.tokens + DAILY_BONUS)
                    UpdateUserToDB(query.from.id, "next_daily", os.time() + 86400)
                else
                    client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DAILIES_BALANCE_FAILURE"], {inline_keyboard = {{back}}})
                end
            else
                client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DAILIES_TIME_FAILURE"], {inline_keyboard = {{back}}})
            end
        end
    end
    
    ----------------------------------------------------------------------
    --------------------------- Char Creation ----------------------------
    ----------------------------------------------------------------------
    
    do
        char_creation.text = LANG[langcode]["$CREATE_CHAR"]
        char_creation.callback = function(self, query)
            
        end
    end
    
    
    -----------------------------------------------------------------------
    ---------------------------- SELECT MODEL -----------------------------
    -----------------------------------------------------------------------

    do
        --[=[
        local back = client:NewInlineKeyboardButton()
        back.text = LANG[langcode]["$TOKENS_BACK"]
        back.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
        end
        
        local openai = client:NewInlineKeyboardButton()
        openai.text = LANG[langcode]["$MODEL_OPENAI"]
        openai.callback = function(self, query)
            UpdateUserToDB(query.from.id, "model", "openai")
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$SELECT_MODEL_SUCCESS"], {inline_keyboard = {{back}}})
        end
        
        --[[
        local horde = client:NewInlineKeyboardButton()
        horde.text = LANG[langcode]["$MODEL_HORDE"]
        horde.callback = function(self, query)
            UpdateUserToDB(query.from.id, "model", "horde")
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$SELECT_MODEL_SUCCESS"], {inline_keyboard = {{back}}})
        end
        ]]
        
        local capybara = client:NewInlineKeyboardButton()
        capybara.text = LANG[langcode]["$MODEL_CAPYBARA"]
        capybara.callback = function(self, query)
            UpdateUserToDB(query.from.id, "model", "capybara")
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$SELECT_MODEL_SUCCESS"], {inline_keyboard = {{back}}})
        end
        
        local dolphin = client:NewInlineKeyboardButton()
        dolphin.text = LANG[langcode]["$MODEL_DOLPHIN"]
        dolphin.callback = function(self, query)
            UpdateUserToDB(query.from.id, "model", "dolphin")
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$SELECT_MODEL_SUCCESS"], {inline_keyboard = {{back}}})
        end
        
        local soliloque = client:NewInlineKeyboardButton()
        soliloque.text = LANG[langcode]["$MODEL_SOLILOQUE"]
        soliloque.callback = function(self, query)
            UpdateUserToDB(query.from.id, "model", "soliloque")
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$SELECT_MODEL_SUCCESS"], {inline_keyboard = {{back}}})
        end
        
        local llama8 = client:NewInlineKeyboardButton()
        llama8.text = LANG[langcode]["$MODEL_LLAMA8"]
        llama8.callback = function(self, query)
            UpdateUserToDB(query.from.id, "model", "llama8")
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$SELECT_MODEL_SUCCESS"], {inline_keyboard = {{back}}})
        end
        
        select_model.text = LANG[langcode]["$SELECT_MODEL"]
        select_model.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$SELECT_MODEL_TEXT"], {inline_keyboard = {
                {
                    openai, 
                    capybara,
                    dolphin
                },
                {
                    soliloque,
                    llama8
                },
                {back}}})
        end
        ]=]
    end
    
    ----------------------------------------------------------------------
    ----------------------------- onMessage ------------------------------
    ----------------------------------------------------------------------
    
    local function onMessage(self, msg)
        if msg.text == "" then
            return
        end
        
        if client.promocode_enter[msg.from.id] then
            client:EditMessageText(client.promocode_enter[msg.from.id].chat, client.promocode_enter[msg.from.id], LANG[langcode]["$PROMOCODE_TEXT"])
            client.promocode_enter[msg.from.id] = nil
            local promo = client.promocodes[msg.text]
            if promo then
                if not (promo.oneperuser and promo.users[msg.from.id]) then
                    if promo.referal then
                        if not UpdateUserReferal(msg.from, promo.referal) then
                            msg.chat:SendMessage(LANG[langcode]["$PROMOCODE_REFERAL_FAILURE"], {reply_markup = {inline_keyboard = {{back}}}})
                        else
                            msg.chat:SendMessage(LANG[langcode]["$PROMOCODE_REFERAL_SUCCESS"], {reply_markup = {inline_keyboard = {{back}}}})
                            UpdateUserToDB(msg.from.id, "tokens", GetUserFromDB(msg.from.id).tokens + promo.tokens)
                            table.insert(promo.users, msg.from.id)
                            if promo.singleuse then
                                client.promocodes[msg.text] = nil
                            end
                            love.filesystem.write(PATH_PROMOCODES, prettyjson(client.promocodes))
                        end
                    else
                        msg.chat:SendMessage(LANG[langcode]["$PROMOCODE_SUCCESS"], {reply_markup = {inline_keyboard = {{back}}}})
                        UpdateUserToDB(msg.from.id, "tokens", GetUserFromDB(msg.from.id).tokens + promo.tokens)
                        if not promo.users then promo.users = {} end
                        table.insert(promo.users, msg.from.id)
                        if promo.singleuse then
                            client.promocodes[msg.text] = nil
                        end
                        love.filesystem.write(PATH_PROMOCODES, prettyjson(client.promocodes))
                    end
                else
                    msg.chat:SendMessage(LANG[langcode]["$PROMOCODE_ALREADYUSED"], {reply_markup = {inline_keyboard = {{back}}}})
                end
            elseif GetAllUsers()[decode(msg.text)] or GetAllUsers()[tonumber(decode(msg.text))] then
                if not UpdateUserReferal(msg.from, (GetAllUsers()[decode(msg.text)] or GetAllUsers()[tonumber(decode(msg.text))])) then
                    msg.chat:SendMessage(LANG[langcode]["$PROMOCODE_REFERAL_FAILURE"], {reply_markup = {inline_keyboard = {{back}}}})
                else
                    msg.chat:SendMessage(LANG[langcode]["$PROMOCODE_REFERAL_SUCCESS"], {reply_markup = {inline_keyboard = {{back}}}})
                    UpdateUserToDB(msg.from.id, "tokens", GetUserFromDB(msg.from.id).tokens + 3000)
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
            client.active_chats[msg.from.id]:AppendContent((translation.Translate(client.active_chats[msg.from.id].char:FormatMessage(client.active_chats[msg.from.id], msg.text), langcode, "en"):gsub("♪", "*")), "user")
            local new_msg = msg.chat:SendMessage(LANG[langcode]["$AWAIT_FOR_MESSAGE"])
            ----FALLBACK[new_msg.id] = new_msg
            client.active_chats[msg.from.id].lastmsg = new_msg
            client.active_chats[msg.from.id]:GetResponse(msg.chat, new_msg, msg.from, callback, errcallback)
        end
    end
    
    return menu, onMessage
end











local onMessage = {}
for i, var in ipairs(LANG) do
    languaged_menu[var], onMessage[var] = CreateLanguagedMenu(var)
end
local comms = {}

local command = {}
command.command = "start"
command.available_for_menu = true
table.insert(comms, client:NewCommand(command))
function command.callback(user, chat, ...)
    if not GetUserFromDB(user.id) then
        AddUserToDB(user, tostring(chat.id))
        local check, ref = pcall(tonumber, ...)
        if check then
            local dcde = pcall(decode, ...)
            UpdateUserReferal(user, (GetAllUsers()[dcde] or GetAllUsers()[tonumber(dcde)]))
        end
    end
    if GetUserFromDB(user.id).chatid == "EMPTY" then
        UpdateUserToDB(user.id, "chatid", tostring(chat.id))
    end
    
    chat:SendMessage(LANG[GetUserLang(user.id)]["$INTRODUCTION"], {reply_markup = languaged_menu[GetUserLang(user.id)]})
end

function client:onMessage(msg)
    if not GetUserFromDB(msg.from.id) then
        AddUserToDB(msg.from, tostring(msg.chat.id))
    end
    local user = GetUserFromDB(msg.from.id)
    if user.chatid == "EMPTY" then
        UpdateUserToDB(msg.from.id, "chatid", tostring(msg.chat.id))
    end
    UpdateUserToDB(user.id, "nextnotification", os.time() + AFK_NOTIFICATION_TIMEOUT)
    
    love.filesystem.append("usage_message.csv", tostring(os.date("%x")) .. "," .. tostring(os.date("%X")) .. "," .. tostring(msg.from.id) .. "\n")
    
    onMessage[GetUserLang(msg.from.id)](client, msg)
end

return comms