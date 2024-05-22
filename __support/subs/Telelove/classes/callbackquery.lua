return function(classes)
    return {
        id                  =   "",
        from                =   classes.__user(),
        message             =   classes.__message(),
        inline_message_id   =   "0",
        chat_instance       =   "0",
        data                =   "",
        game_short_name     =   "",
        
        __init = function(self)
            if rawget(self, "from") then
                self.from = classes.__user(self.from)
            end
            if rawget(self, "message") then
                self.message = classes.__message(self.message)
            end
        end
    }
end