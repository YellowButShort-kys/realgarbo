local ansicolors = require("subs.ansicolors")
local p = print
function print(...)
    p(table.concat({ansicolors("%{bright blue}[SUPPORT]%{reset}:"), ...}))
end

requests = require("subs.threaded_requests")
telelove = require("subs.Telelove")

TG_LINK = "6296177395:AAFcN37QRXBPfZvtQ0WE8bszJErV4oWm86I"

client = telelove.NewClient()

client:Connect(TG_LINK)


TICKETS = {}


local TYPES = client:NewInlineKeyboardMarkup()
local technical_issues = client:NewInlineKeyboardButton()
technical_issues.text = "Ошибки в работе бота"
technical_issues.callback = function(self, query)
    TICKETS[query.from.id].type = "Technical Issue"
end
local purchase = client:NewInlineKeyboardButton()
purchase.text = "Покупка токенов или подписки"
purchase.callback = function(self, query)
    TICKETS[query.from.id].type = "Purchase"
end
TYPES.inline_keyboard = {{technical_issues}, {purchase}}


local start = client:NewCommand()
start.command = "start"
start.available_for_menu = false
start.callback = function(from, chat, text)
    chat:SendMessage("Привет! Оставьте свое сообщение здесь и мы ответим вам как можно скорее", TYPES)
    TICKETS[from.id] = {
        from = from,
        chat = chat,
        type = "Undefined"
    }
end

