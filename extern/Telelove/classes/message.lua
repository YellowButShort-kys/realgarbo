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
            
            DeleteMessage = function(self)
                print(client.__telelove.json.encode({chat_id = self.chat.id, message_id = self.message_id}))
                print()
                print(body)
                return client:DeleteMessage(self)
            end,
            
            EditMessageText = function(self, text, reply_markup)
                local newmsg = client:EditMessageText(self.chat, self, text, reply_markup)
                
                self.text = text or self.text
                self.reply_markup = reply_markup or self.reply_markup
                --self.message_id = newmsg.message_id
                return self
            end,
            EditMessageReplyMarkup = function(self, reply_markup)
                return client:EditMessageReplyMarkup(self.chat, self, reply_markup)
            end
        }
end