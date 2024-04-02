local instance = {}
local str = (...).."."
local other_str = (...)
require(str.."update_callbacks")(instance)



function instance:Connect(token)
    assert(not self.__worker, "Attempted to connect from a worker thread!")
    while true do
        code, body, headers = https.request("https://api.telegram.org/bot"..token.."/getMe", {})
        if code ~= 200 then
            self.__telelove.__error("Failed while establishing connection! Waiting for a retry...")
            love.timer.sleep(1)
        else
            local body = self.__telelove.json.decode(body)
            self.__telelove.__print("Successfully connected to @"..body.result.username)
            return self:Start(self.__telelove.__class.__user(body.result), body, token)
        end
    end
end



function instance:__init(settings)
    self.__settings               =  settings
    
    --1: updates/handler
    --2: outputs
    --3-x: users
    
    if not self.__worker and not self.__updater then
        if self.__settings.Threads > 2 then
            self.__threads = {}
            self.__threads.Updater = love.thread.newThread(other_str:gsub("%.", "/").."/thread_updater.lua")
            self.__threads.Workers = {}
            for x = 1, self.__settings.Threads do
                table.insert(self.__threads.Workers, love.thread.newThread(other_str:gsub("%.", "/").."/thread_worker.lua"))
            end
        else
            error("Running a threaded client requires having at least 3 threads!")
        end
    end
    
    self.__commands               =  {}
    self.__commands_proxy         =  {}
    
    self.__replykeyboardmarkups   =  {}
    self.__inlinekeyboardmarkups  =  {}
    self.__inlinekeyboardbuttons  =  {}
    return self
end

function instance:Start(identity, identity_raw, token)
    self.__identity               =  identity
    self.__identity_raw           =  identity_raw
    self.__token                  =  token
    
    if not self.__worker and not self.__updater then
        self.__threads.Updater:start()
    end
    
    if self.onStart then
        self:onStart()
    end
    return self
end
function instance:GetMe()
    return self.__identity
end
function instance:Update()
    if self.__worker then
        while true do

        end
    elseif self.__updater then
        local skip
        if not offset then skip = true end
        
        local body = telelove.__saferequest(
            "https://api.telegram.org/bot"..self.__token.."/getUpdates", 
            {method = "POST", headers = {["Content-Type"] = "application/json"}, data = telelove.json.encode({offset = offset, timeout = 60})}
        )
        
        if body then
            local collection = (telelove.json.decode(body).result)
            for _, package in ipairs(collection) do
                local update = telelove.__class.__update(package)
                offset = math.max(offset or 0, update.update_id + 1)
                if not skip then
                    local target_thread = self.FindLeastBusyThread()
                    target_thread.connector:push(package)
                end
            end
        end
    end
end



------------------------------------------------------------------
--------------------------- PROCESSING ---------------------------
------------------------------------------------------------------

function instance:__ProcessCommands(message)
    if message.text:sub(1, 1) == "/" then
        local i = message.text:find("%s") or 0
        if self.__commands_proxy[message.text:sub(2, i-1)] then
            for _, var in ipairs(self.__commands_proxy[message.text:sub(2, i-1)]) do
                if var.active then
                    var.callback(message.from, message.chat, message.text:sub(i+1))
                    return true
                end
            end
        end
    end
end
function instance:__ProcessCallbackQuery(query)
    if query.data and self.__inlinekeyboardbuttons[query.data] then
        local text, show_alert = self.__inlinekeyboardbuttons[query.data]:callback(query)
        self:AnswerCallbackQuery(query.id, text, show_alert)
    end
end


------------------------------------------------------------------
---------------------------- COMMANDS ----------------------------
------------------------------------------------------------------

function instance:NewCommand(table)
    return self.__telelove.__class.__command(table)
end
function instance:RegisterCommand(command)
    table.insert(self.__commands, command)
    self.__commands_proxy[command.command] = self.__commands_proxy[command.command] or {}
    table.insert(self.__commands_proxy[command.command], command)
end
function instance:RegisterMultipleCommands(commands)
    for _, var in ipairs(commands) do
        table.insert(self.__commands, var)
        self.__commands_proxy[var.command] = self.__commands_proxy[var.command] or {}
        table.insert(self.__commands_proxy[var.command], var)
    end
end
function instance:GetAllCommands()
    return self.__commands
end


------------------------------------------------------------------
---------------------------- KEYBOARD ----------------------------
------------------------------------------------------------------

function instance:NewReplyKeyboardButton(table)
    return self.__telelove.__class.__replykeyboardbutton(table)
end
function instance:NewReplyKeyboardMarkup(table)
    return self.__telelove.__class.__replykeyboardmarkup(table)
end
function instance:RegisterReplyKeyboardMarkup(table, string)
    if table.__type and table.__type == "ReplyKeyboardMarkup" then
        self.__replykeyboardmarkups[string] = table
    else
        local rkbm = self.__telelove.__class.__replykeyboardmarkup(table)
        self.__replykeyboardmarkups[string] = rkbm
    end
    return self.__replykeyboardmarkups[string]
end


-----------------------------------------------------------------
------------------------ INLINE KEYBOARD ------------------------
-----------------------------------------------------------------

local hidden = 0
function instance:NewInlineKeyboardButton(table)
    local btn = self.__telelove.__class.__inlinekeyboardbutton(table)
    btn.callback_data = tostring(hidden)
    self.__inlinekeyboardbuttons[btn.callback_data] = btn
    hidden = hidden + 1
    return btn
end
function instance:NewInlineKeyboardMarkup(table)
    local markup = self.__telelove.__class.__inlinekeyboardmarkup(table)
    if markup.inline_keyboard then
        for i, var in ipairs(markup.inline_keyboard) do
            if type(var) == "string" then
                markup.inline_keyboard[i] = self:NewInlineKeyboardButton({text = var})
            else
                markup.inline_keyboard[i] = self:NewInlineKeyboardButton(var)
            end
        end
    else
        markup.inline_keyboard = {}
    end
    return markup
end
function instance:RegisterInlineKeyboardMarkup(string, table)
    if table and table.__type and table.__type == "InlineKeyboardMarkup" then
        self.__inlinekeyboardmarkups[string] = table
    else
        local rkbm = self.__telelove.__class.__inlinekeyboardmarkup(table)
        self.__inlinekeyboardmarkups[string] = rkbm
    end
    return self.__inlinekeyboardmarkups[string]
end

-----------------------------------------------------------------
---------------------------- METHODS ----------------------------
-----------------------------------------------------------------

do
    function instance:SendMessage(chat, text, extra)
        local data = {chat_id = type(chat) == "table" and chat.id or chat, text = self.__telelove.__httpfy(text), parse_mode = "MarkdownV2"}
        if extra then
            for i, var in pairs(extra) do
                if i == "reply_markup" and type(var) == "string" then
                    var = self.__replykeyboardmarkups[var] or self.__inlinekeyboardmarkups[var]
                end
                data[i] = var
            end
        end
        
        local r = self.__telelove.__saferequest(
            "https://api.telegram.org/bot"..self.__token.."/sendMessage", 
            {method = "POST", headers = {["Content-Type"] = "application/json"}, data = self.__telelove.json.encode(data)}
        )
        return self.__telelove.__class.__message(client.__telelove.json.decode(r).result)
    end
end

do
    local memsave = {}
    function instance:__AnswerCallbackQuery(callback_query_id, text, show_alert)
        memsave.text = text or nil
        memsave.callback_query_id = callback_query_id
        memsave.show_alert = show_alert or false
        local code, body, headers = self.__telelove.__verifyrequest(https.request(
            "https://api.telegram.org/bot"..self.__token.."/answerCallbackQuery", 
            {method = "POST", headers = {["Content-Type"] = "application/json"}, data = self.__telelove.json.encode(memsave)}
        ))
        return code == 200
    end
    function instance:AnswerCallbackQuery(callback_query_id, text, show_alert)
        return self.__telelove.__promise(nil, self.__AnswerCallbackQuery, self, callback_query_id, text, show_alert)
    end
end

do
    local memsave = {}
    function instance:EditMessageReplyMarkup(chat, message, reply_markup)
        assert(chat and message)
        memsave.chat_id = chat.id
        memsave.message_id = message.message_id
        if reply_markup then
            memsave.reply_markup = reply_markup
        else
            memsave.reply_markup = nil
        end
        return self.__telelove.__saferequest(
            "https://api.telegram.org/bot"..self.__token.."/editMessageReplyMarkup",
            {method = "POST", headers = {["Content-Type"] = "application/json"}, data = self.__telelove.json.encode(memsave)}
        )
    end
end

do
    local memsave = {}
    function instance:EditMessageText(chat, message, text, reply_markup)
        assert(chat and message and text)
        memsave.chat_id = chat.id
        memsave.message_id = message.message_id
        --memsave.parse_mode = parse_mode
        memsave.text = text
        if reply_markup then
            memsave.reply_markup = reply_markup
        else
            memsave.reply_markup = nil
        end
        local res = self.__telelove.__saferequest("https://api.telegram.org/bot"..self.__token.."/editMessageText", {method = "POST", headers = {["Content-Type"] = "application/json"}, data = self.__telelove.json.encode(memsave)})
        message.text = text
        --memsave.parse_mode = nil
        return res
    end
end




---@alias action
---| "typing" 
---| "upload_photo"
---| "record_video"
---| "upload_video"
---| "record_voice"
---| "upload_voice"
---| "upload_document"
---| "choose_sticker"
---| "find_location"
---| "record_video_note"
---| "upload_video_note"
---@param chat any
---@param action action
function instance:__SendChatAction(chat, action)
    local code, body, headers = self.__telelove.__verifyrequest(https.request(
        "https://api.telegram.org/bot"..self.__token.."/sendChatAction", 
        {method = "POST", headers = {["Content-Type"] = "application/json"}, data = self.__telelove.json.encode({chat_id = chat.id, action = action})}
    ))
    return code == 200
end
function instance:SendChatAction(chat, action)
    return self.__telelove.__promise(nil, self.__SendChatAction, self, chat, action)
end



function instance:__SetMyCommands(commands, scope)
    local coms = {}
    for _, var in ipairs(commands) do
        if var.available_for_menu and var.active then
            table.insert(coms, {command = var.command, description = var.description})
        end
    end
    local code, body, headers = self.__telelove.__verifyrequest(https.request(
        "https://api.telegram.org/bot"..self.__token.."/setMyCommands", 
        {method = "POST", headers = {["Content-Type"] = "application/json"}, data = self.__telelove.json.encode({commands = coms, scope = scope})}
    ))
    return code == 200
end
function instance:SetMyCommands(commands, scope)
    return self.__telelove.__promise(nil, self.__SetMyCommands, self, commands, scope)
end

return instance