PATH_PROMOCODES = "promocodes.json"
print("", love.filesystem.getRealDirectory(PATH_PROMOCODES) .. "/" .. PATH_PROMOCODES)
PATH_DB_USERS = "/root/Carp/realgarbo/db/users.db"
PATH_DB_CHATS = "/root/Carp/realgarbo/db/chats.db"
PATH_DB_CUSTOMCHARS = "/root/Carp/realgarbo/db/customchars.db"
print("Users: ", PATH_DB_USERS)
print("Chats:", PATH_DB_CHATS)
print("Custom Characters", PATH_DB_CUSTOMCHARS)

AVG_KUDOS_PRICE = 0
AVG_KUDOS_PRICE_N = 0
DAILY_BONUS = 200
CONTEXT_LIMIT = 2000
AFK_NOTIFICATION_TIMEOUT = 1209600
CUSTOM_CHARACTERS_OFFSET = 326 -- to make it fancy lol

--PATH_DB = "~/code/realgarbo/db/chats.db"