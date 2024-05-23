return function(classes)
    return {
            message_id = 0,
            message_thread_id = 0,
            from = classes.__user(),
            sender_chat = classes.__chat(),
            date = 0,
            chat = classes.__chat(),
            text = "",
            --reply_markup = false,
            
            __init = function(self)
                if rawget(self, "from") then
                    self.from = classes.__user(self.from)
                end
                if rawget(self, "sender_chat") then
                    self.sender_chat = classes.__chat(self.sender_chat)
                end
                if rawget(self, "chat") then
                    self.chat = classes.__chat(self.chat)
                end
            end,
            
            __DeleteMessage = function(self)
                local code, body, headers = https.request(
                    "https://api.telegram.org/bot"..client.__token.."/deleteMessage", 
                    {method = "POST", headers = {["Content-Type"] = "application/json"}, data = client.__telelove.json.encode({chat_id = self.chat.id, message_id = self.message_id})}
                )
                
                if code == 0 then
                    return false
                elseif code ~= 200 then
                    client.__telelove.__error("Failed while deleting a message! Error code: "..code)
                    return true
                else
                    return true
                end
            end,
            DeleteMessage = function(self)
                return client.__telelove.__promise(nil, self.__DeleteMessage, self)
            end,
            
            EditMessageText = function(self, text, reply_markup)
                self.text = text
                --self.reply_markup = self.reply_markup
                return client:EditMessageText(self.chat, self, text, reply_markup)
            end,
            EditMessageReplyMarkup = function(self, reply_markup)
                return client:EditMessageReplyMarkup(self.chat, self, reply_markup)
            end
        }
end