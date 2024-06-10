function love.run()
	if love.load then love.load(love.parsedGameArguments, love.rawGameArguments) end
	if love.timer then love.timer.step() end
	return function()
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0, b
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
		local dt = love.timer and love.timer.step() or 0
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
		if love.timer then love.timer.sleep(0.001) end
	end
end



local ansicolors = require("subs.ansicolors")
local p = print
function print(...)
    p(table.concat({ansicolors("%{bright blue}[SUPPORT]%{reset}:"), ...}))
end
local split = function(inputstr, sep)
    local t = {}
    for str in string.gmatch(inputstr, "([^"..(sep or "%s").."]+)") do
        table.insert(t, str)
    end
    return t
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
        type = "Undefined",
        active = true
    }
end

local reply = client:NewCommand()
reply.command = "reply"
reply.available_for_menu = false
reply.callback = function(from, chat, text)
    if from.id == 386513759 then
        args = split(text, "; ")
        
        client:SendMessage(tostring(args[1]), args[2])
    end
end

function client:onMessage(message)
    if TICKETS[message.from] then
        if TICKETS[message.from].active then
            message.chat:SendMessage("Спасибо за ваше обращение! Мы свяжемся с вами как можно скорее. Чат все еще активный и вы можете дополнять свой тикет.")
        end
        local msg = message:ForwardMessage(386513759)
        client:SendMessage(386513759, tostring(message.from), {reply_parameters = {message_id=msg.id}})
    end
end

function love.update()
    client:Update()
end