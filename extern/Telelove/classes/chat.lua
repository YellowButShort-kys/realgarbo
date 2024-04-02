return function(classes)
    return {
        id = 0,
        type = "private",
        title = "chat",
        username = "chat",
        
        SendMessage = function(self, text, extra)
            return client:SendMessage(self, text, extra)
        end,
        

        __SendChatAction = function(self, action)
            local code, body, headers = client.__telelove.__verifyrequest(https.request(
                "https://api.telegram.org/bot"..client.__token.."/sendChatAction", 
                {method = "POST", headers = {["Content-Type"] = "application/json"}, data = client.__telelove.json.encode({chat_id = self.id, action = action})}
            ))
            return code == 200
        end,
        ---@param self any
        ---@param action action
        SendChatAction = function(self, action)
            return client.__telelove.__promise(nil, self.__SendChatAction, self, action)
        end
    }
end