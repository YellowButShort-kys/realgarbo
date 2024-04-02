return function(classes)
    return {
    },
    {
        __client = false,
        __type                      =   "InlineKeyboardMarkup",
        __init = function(self)
            if rawget(self, "inline_keyboard") then
                for i, var in ipairs(self.inline_keyboard) do
                    if type(var) == "string" then
                        self.inline_keyboard[i] = classes.__inlinekeyboardbutton({text = var})
                    else
                        self.inline_keyboard[i] = classes.__inlinekeyboardbutton(var)
                    end
                end
            else
                rawset(self, "inline_keyboard", {})
            end
        end
    }
end
