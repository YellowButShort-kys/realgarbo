local function onSuccessfulPayment(id)
    master_client:SendToFather("MONEY BITCH YAY!!!\n SOMEBODY HAS BOUGHT A "..(client.payments[id][2]:GetName():sub(-2, -1)) .. " LEVEL SUB")
    UpdateUserToDB(client.payments[id][1].id, "subscriptionlevel", tonumber(client.payments[id][2]:GetName():sub(-2, -1)))
    UpdateUserToDB(client.payments[id][1].id, "tokens", GetUserFromDB(client.payments[id][1].id) + SUBBONUS[tonumber(client.payments[id][2]:GetName():sub(-2, -1))][1])
    UpdateUserToDB(client.payments[id][1].id, "subscriptiontokens", SUBBONUS[tonumber(client.payments[id][2]:GetName():sub(-2, -1))][2])
end

return function(langcode, menu, button)
    local products = radom.GetProducts()
    local back = client:NewInlineKeyboardButton()
    back.text = LANG[langcode]["$DONATE_BACK"]
    back.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
    end
    
    
    local donationback = client:NewInlineKeyboardButton()

    
    
    local subsikm = {}
    local regikm = {}
    for i, product in ipairs(products) do
        local options = client:NewInlineKeyboardButton()    
        local crypto = client:NewInlineKeyboardButton()
        local crypto_agree = client:NewInlineKeyboardButton()
        crypto.text = LANG[langcode]["$DONATE_CRYPTO"]
        crypto.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_CRYPTO_GUIDE"], {inline_keyboard = {{options, crypto_agree}}})
        end
        crypto_agree.text = LANG[langcode]["$DONATE_CRYPTO_PROCEED"]
        crypto_agree.callback = function(self, query)
            radom.CreateCheckoutSession(product, 
                function(url, id)
                    client.payments[id] = {query.from, product}
                    client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_CRYPTO_PAYMENT"]:format(url), {inline_keyboard = {{back}}})
                end,
                onSuccessfulPayment,
                "https://t.me/CarpAI_bot"
            )
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_CRYPTO_AWAIT"])
        end
        
        
        local cash = client:NewInlineKeyboardButton()
        local cash_agree = client:NewInlineKeyboardButton()
        cash.text = LANG[langcode]["$DONATE_CASH"]
        cash.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_CASH_GUIDE"], {inline_keyboard = {{options, crypto_agree}}})
        end
        cash_agree.text = LANG[langcode]["$DONATE_CASH_PROCEED"]
        cash_agree.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_CASH_PAYMENT"], {inline_keyboard = {{back}}})
        end
        
        
        options.text = LANG[langcode]["$DONATE_BACK"]
        options.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, "<b><i>" .. product:GetName() .. "</i></b>" .. "\n\n" .. product:GetDescription(), {inline_keyboard = {{crypto}, {cash}, {back}}})
        end
        
        
        local btn = client:NewInlineKeyboardButton()
        btn.text = product:GetName()
        btn.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, "<b><i>" .. product:GetName() .. "</i></b>" .. "\n\n" .. product:GetDescription(), {inline_keyboard = {{crypto}, {cash}, {back}}})
        end
        
        print("GetChargingInterval")
        print(product.GetChargingInterval)
        print(product:GetChargingInterval())
        if product:GetChargingInterval() > 0 then
            subsikm[tonumber(btn.text:sub(-2, -1))] = {btn}
        else
            regikm[tonumber(btn.text:sub(-2, -1))] = {btn}
        end
        print("GetChargingInterval Done")
    end
    table.insert(subsikm, {donationback})
    table.insert(regikm, {donationback})
    local subscriptions = client:NewInlineKeyboardButton()
    subscriptions.text = LANG[langcode]["$DONATE_SUBSCRIPTIONS"]
    subscriptions.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_SUBSCRIPTIONS_TEXT"], {inline_keyboard = subsikm})
    end
    local regular = client:NewInlineKeyboardButton()
    regular.text = LANG[langcode]["$DONATE_REGULAR"]
    regular.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_REGULAR_TEXT"], {inline_keyboard = regikm})
    end
    
    
    donationback.text = LANG[langcode]["$DONATE_BACK"]
    donationback.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_OPTIONS"], {inline_keyboard = {{subscriptions}, {regular}, {back}}})
    end
    
    button.text = LANG[langcode]["$DONATE"]
    button.callback = donationback.callback
end