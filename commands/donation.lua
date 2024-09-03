local products = {
    subs = {
        {
            tier = 1,
            type = "subscription",
            name = "Подписка: Тир 1",
            description = [[!!!Подписка покупается на 3 месяца!!!
500 токенов на ваш счет каждый месяц
7400 дополнительных токенов на месяц (расходуются первыми)

Огромное спасибо за вашу поддержку!]],
            rewards = {
                substokens = 7400,
                tokens = 500
            },
            price = 750,
            lenght = 3
        },
        {
            tier = 2,
            type = "subscription",
            name = "Подписка: Тир 2",
            description = [[!!!Подписка покупается на 3 месяца!!!
1750 токенов на ваш счет каждый месяц
38850 дополнительных токенов на месяц (расходуются первыми)
Доступ к закрытым тестам новых функций

Огромное спасибо за вашу поддержку!]],
            rewards = {
                substokens = 38850,
                tokens = 1750
            },
            price = 1500,
            lenght = 3
        },
        {
            tier = 3,
            type = "subscription",
            name = "Подписка: Тир 3",
            description = [[!!!Подписка покупается на 3 месяца!!!
3780 токенов на ваш счет каждый месяц
83160 дополнительных токенов на месяц (расходуются первыми)
Доступ к закрытым тестам новых функций
Вы становитесь огромным гигачадом и можете запросить что угодно (в рамках разумного конечно)

Огромное спасибо за вашу поддержку!]],
            rewards = {
                substokens = 83160,
                tokens = 3780
            },
            price = 2500,
            lenght = 3
        },
    },
    regular = {
        {
            type = "package",
            name = "Набор: 625 токенов",
            description = [[Для тех кто не готов тратиться]],
            rewards = {
                tokens = 625
            },
            price = 50
        },
        {
            type = "package",
            name = "Набор: 1720 токенов",
            description = [[Если вам понравились отдельные персонажи]],
            rewards = {
                tokens = 1720
            },
            price = 150
        },
        {
            type = "package",
            name = "Набор: 3750 токенов",
            description = [[Баланс между выгодой и ценой]],
            rewards = {
                tokens = 3750
            },
            price = 250
        },
        {
            type = "package",
            name = "Набор: 8125 токенов",
            description = [[Хватит надолго]],
            rewards = {
                tokens = 8125
            },
            price = 500
        },
        {
            type = "package",
            name = "Набор: 13125 токенов",
            description = [[Если персонажи стали вам реально близкими]],
            rewards = {
                tokens = 13125
            },
            price = 750
        },
        {
            type = "package",
            name = "Набор: 28125 токенов",
            description = [[Вау... Спасибо за вашу поддержку!]],
            rewards = {
                tokens = 8125
            },
            price = 1500
        },
    }
}

local productsid = {
    products.subs[1],
    products.subs[2],
    products.subs[3],
    products.regular[1],
    products.regular[2],
    products.regular[3],
    products.regular[4],
    products.regular[5],
    products.regular[6]
}

local __menu
local split = function(inputstr, sep)
    local t = {}
    for str in string.gmatch(inputstr, "([^"..(sep or "%s").."]+)") do
        table.insert(t, str)
    end
    return t
end


local success = client:NewInlineKeyboardButton()
success.text = LANG["ru"]["$DONATE_BACK"]
success.callback = function(self, query)
    client:EditMessageText(query.message.chat, query.message, LANG["ru"]["$INTRODUCTION"], __menu)
end
function client:onSuccessfulPayment(payload)
    local type, product_i, id = split(payload, "_")
    product_i = tonumber(product_i)
    id = tonumber(id)
    local product = products[type][product_i]
    if type == "subs" then
        master_client:SendToFather("MONEY BITCH YAY!!!\n SOMEBODY HAS BOUGHT "..(product.name).."\n"..tostring(id))
        UpdateUserToDB(id, "subscriptionlevel", product.tier)
        UpdateUserToDB(id, "tokens", GetUserFromDB(id).tokens + product.rewards.tokens)
        UpdateUserToDB(id, "subscriptiontokens", products.rewards.substokens)
    else
        master_client:SendToFather("MONEY BITCH YAY!!!\n SOMEBODY HAS BOUGHT "..(product.name).."\n"..tostring(id))
        UpdateUserToDB(id, "tokens", GetUserFromDB(id).tokens + product.rewards.tokens)
    end
    
    local ref = GetUserFromDB(id).referal
    if ref then
        local target = GetUserFromDB(tonumber(ref))
        if target then
            UpdateUserToDB(ref, "tokens", GetUserFromDB(ref).tokens + math.floor(product.rewards.tokens*0.3))
            client:SendMessage(target.chatid, "Хей, человек которого вы пригласили только что пополнил свой баланс! Вам было начислено "..tostring(math.floor(product.rewards.tokens*0.3)).." токенов")
        end
    end
    
    client.payments[id]:EditMessageText("Оплата прошла успешно! Спасибо огромное за вашу поддержку!", {inline_keyboard = {success}})
end

return function(langcode, menu, button)
    if langcode == "ru" then
        __menu = menu
    end
    local back = client:NewInlineKeyboardButton()
    back.text = LANG[langcode]["$DONATE_BACK"]
    back.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
    end
    local donation_ikm
    local donationback = client:NewInlineKeyboardButton()
    donationback.text = LANG[langcode]["$DONATE_BACK"]
    donationback.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_OPTIONS"], donation_ikm)
    end
    
    local subscriptions = client:NewInlineKeyboardButton()
    subscriptions.text = LANG[langcode]["$DONATE_SUBSCRIPTIONS"]
    local subscriptions_ikm = {}
    for i, var in ipairs(products.subs) do
        local btn = client:NewInlineKeyboardButton()
        btn.text = var.name
        btn.callback = function(self, query)
            client.payments[query.from.id] = query.message.chat:SendInvoice(var.name, var.description, "subs".."_"..tostring(i).."_"..tostring(query.from), var.price)
        end
        table.insert(subscriptions_ikm, {btn})
    end
    table.insert(subscriptions_ikm, {donationback})
    subscriptions.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_SUBSCRIPTIONS_TEXT"], {inline_keyboard = subscriptions_ikm})
    end
    
    local packages = client:NewInlineKeyboardButton()
    packages.text = LANG[langcode]["$DONATE_REGULAR"]
    local packages_ikm = {}
    for i, var in ipairs(products.regular) do
        local btn = client:NewInlineKeyboardButton()
        btn.text = var.name
        btn.callback = function(self, query)
            client.payments[query.from.id] = query.message.chat:SendInvoice(var.name, var.description, "regular".."_"..tostring(i).."_"..tostring(query.from), var.price)
        end
        table.insert(packages_ikm, {btn})
    end
    table.insert(packages_ikm, {donationback})
    packages.callback = function(self, query)
        client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$DONATE_REGULAR_TEXT"], {inline_keyboard = packages_ikm})
    end
    

    donation_ikm = {inline_keyboard = {{subscriptions}, {packages}, {back}}}
    
    button.text = LANG[langcode]["$DONATE"]
    button.callback = donationback.callback
end