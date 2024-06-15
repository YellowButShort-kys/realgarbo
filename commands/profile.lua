local encoding_table = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
}
local function encode(number)
    local str = string.format("%.f", number)
    local offset = 0
    return (string.gsub(str, ".", function(h)
        offset = offset + 1
        return encoding_table[tonumber(h)*2+offset]
    end))
end

return function(langcode, menu, button)
    local profile_ikm = {inline_keyboard = {}}
    local profileback = client:NewInlineKeyboardButton()
    profileback.text = LANG[langcode]["$PROFILE_BACK"]
    profileback.callback = function(self, query)
        local user = GetUserFromDB(query.from.id)
            local display_name = GetUserName(user)
            local balance = user.tokens
            local sublevel = user.subscriptionlevel
            local subtokens = user.subscriptiontokens
            local refcode = encode(user.id)
            local reflink = "https://t.me/CarpAI_bot?start="..refcode
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$PROFILE_TEXT"]:format(display_name, balance, sublevel, subtokens, refcode, reflink), profile_ikm)
    end
    
    local display_name = client:NewInlineKeyboardButton()
    display_name.text = LANG[langcode]["$DISPLAY_NAME"]
    display_name.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DISPLAY_NAME_TEXT"], {inline_keyboard = {{profileback}}})
        client.display_name_change[query.from.id] = query.message
    end
    
    
    local back = client:NewInlineKeyboardButton()
    back.text = LANG[langcode]["$PROFILE_BACK"]
    back.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
        client.display_name_change[query.from.id] = nil
    end
    table.insert(profile_ikm.inline_keyboard, {back})
    
    
    button.text = LANG[langcode]["$PROFILE"]
    button.callback = profileback.callback
end