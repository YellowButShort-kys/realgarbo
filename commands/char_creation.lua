client.CharCreation = {}
client.CharCreationLoad = {}
local order = {
    {"name", "CHAR_CREATION_KEY_NAME"},
    {"display_name", "CHAR_CREATION_KEY_DISPLAYNAME"},
    {"description", "CHAR_CREATION_KEY_DESCRIPTION"},
    {"greeting", "CHAR_CREATION_KEY_GREETING"},
}

ProcessCharCreation = {}
return function(langcode, menu)
    local char_creation                   = client:NewInlineKeyboardButton()
    local Public                          = client:NewInlineKeyboardButton()
    local Private                         = client:NewInlineKeyboardButton()
    local back                            = client:NewInlineKeyboardButton()
    local load_custom_character           = client:NewInlineKeyboardButton()
    char_creation.text = LANG[langcode]["$CREATE_CHAR"]
    char_creation.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["CHAR_CREATION_INTRODUCTION"], {inline_keyboard = {{back}}})
        client.CharCreation[query.from.id] = {}
    end

    back.text = LANG[langcode]["CHAR_CREATION_BACK"]
    back.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
        client.CharCreation[query.from.id] = nil
        client.CharCreationLoad[query.from.id] = nil
    end

    Public.text = LANG[langcode]["CHAR_CREATION_PUBLIC"]
    Public.callback = function(self, query)
        client.CharCreation[query.from.id].public = true
        local char = characters.SaveCustomCharacter(
            client.CharCreation[query.from.id].id,                                                         --id
            translation.Translate(client.CharCreation[query.from.id].name, langcode, "en"),                --name
            client.CharCreation[query.from.id].display_name,                                               --display_name
            translation.Translate(client.CharCreation[query.from.id].description, langcode, "en"),         --description
            translation.Translate(client.CharCreation[query.from.id].greeting, langcode, "en"),            --greeting
            query.from.id,                                                                                 --creator
            client.CharCreation[query.from.id].is_public,                                                  --is_public
            client.CharCreation[query.from.id].name,                                                       --source_name
            client.CharCreation[query.from.id].description,                                                --source_description
            client.CharCreation[query.from.id].greeting                                                    --source_greeting
        )
        client.active_chats[query.from.id] = chats.NewCustomChat(query.from, char.id)
        client:EditMessageText(query.message.chat, query.message, htmlformat(translation.Translate(char:GetFirstMessage(query.from), "en", langcode)))
        client.CharCreation[query.from.id] = nil
    end
    Private.text = LANG[langcode]["CHAR_CREATION_PRIVATE"]
    Private.callback = function(self, query)
        client.CharCreation[query.from.id].public = false
        local char = characters.SaveCustomCharacter(
            client.CharCreation[query.from.id].id,                                                         --id
            translation.Translate(client.CharCreation[query.from.id].name, langcode, "en"),                --name
            client.CharCreation[query.from.id].display_name,                                               --display_name
            translation.Translate(client.CharCreation[query.from.id].description, langcode, "en"),         --description
            translation.Translate(client.CharCreation[query.from.id].greeting, langcode, "en"),            --greeting
            query.from.id,                                                                                 --creator
            client.CharCreation[query.from.id].is_public,                                                  --is_public
            client.CharCreation[query.from.id].name,                                                       --source_name
            client.CharCreation[query.from.id].description,                                                --source_description
            client.CharCreation[query.from.id].greeting                                                    --source_greeting
        )
        client.active_chats[query.from.id] = chats.NewCustomChat(query.from, char.id)
        client:EditMessageText(query.message.chat, query.message, htmlformat(client.CharCreation[query.from.id].greeting))
        client.CharCreation[query.from.id] = nil
    end

    ProcessCharCreation[langcode] = function(chat, user_id, text)
        if not client.CharCreation[user_id].id then
            CUSTOM_CHARACTERS_LAST_ID = CUSTOM_CHARACTERS_LAST_ID + 1
            client.CharCreation[user_id].id = CUSTOM_CHARACTERS_LAST_ID
        end
        for i, var in ipairs(order) do
            if not client.CharCreation[user_id][var[1]] then
                client.CharCreation[user_id][var[1]] = text
                if order[i + 1] then
                    chat:SendMessage(LANG[langcode][order[i + 1][2]], {inline_keyboard = {{back}}})
                else
                    chat:SendMessage(LANG[langcode]["CHAR_CREATION_FINISH"]:format(client.CharCreation[user_id].id), {inline_keyboard = {{Private, Public}}})
                end
            end
        end
    end


    load_custom_character.text = LANG[langcode]["CHAR_CREATION_LOAD"]
    load_custom_character.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["CHAR_CREATION_LOAD_DESC"], {inline_keyboard = {{back}}})
        client.CharCreationLoad[query.from.id] = true
    end

    return char_creation, load_custom_character
end