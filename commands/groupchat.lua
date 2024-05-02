local sendmsg = client:NewCommand()
sendmsg.command = "sendmsg"
sendmsg.description = "Send a message to the currenly selected chat"
sendmsg.callback = function(user, chat, msg) 
    local langcode = GetUserLang(user.id)
    if chat.type == "private" then
        chat:SendMessage(LANG[langcode]["$ERROR_UNAVAILABLE_IN_PRIVATE"])
        return
    end
    local dbuser = GetUserFromDB(user.id)
    if not GetUserFromDB(user.id) then
        dbuser = AddUserToDB(user, tostring(chat.id))
    end
    
    if client.group_active_chats[chat.id] then
        if msg == "" then
            return
        end
        
        if dbuser.tokens <= 0 then
            chat:SendMessage(LANG[langcode]["$CHAT_NOT_ENOUGH_TOKENS"])
            return
        end 

        if client.group_active_chats[chat.id].task then
            chat:SendMessage(LANG[langcode]["$UNFINISHED_GENERATION"])
            return
        end
        
        if client.group_active_chats[chat.id].lastmsg then  
            client.group_active_chats[chat.id].lastmsg:EditMessageReplyMarkup()
        end
        
        client.active_chats[msg.from.id]:AppendContent((translation.Translate(msg.text, langcode, "en"):gsub("♪", "*")), "user")
        local new_msg = msg.chat:SendMessage(LANG[langcode]["$AWAIT_FOR_MESSAGE"])
        client.active_chats[msg.from.id].lastmsg = new_msg
        client.active_chats[msg.from.id]:GetResponse(msg.chat, new_msg, msg.from, callback, errcallback)
    end
    
    error("Intentional stoppage from the admin panel")
end
client:RegisterCommand(sendmsg)