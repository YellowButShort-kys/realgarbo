--db_chats = sqlite3.open_memory(PATH_DB_CHATS)
--db_userlist = sqlite3.open_memory(PATH_DB_USERS)

local db_userlist_changes = {}
local db_userlist_additions = {}
local db_userlist_lang = {}
local db_userlist_refs = {}
local db_chats_changes = {}
local db_chats_additions = {}
local next


local query_init_userlist = [[
    create table if not exists Users (
        id INTEGER PRIMARY KEY, 
        first_name TEXT, 
        last_name TEXT, 
        username TEXT, 
        display_name TEXT DEFAULT "_NONAME_" NOT NULL,
        referal INTEGER DEFAULT 0 NOT NULL, 
        lang TEXT DEFAULT "ru" NOT NULL,
        tokens INTEGER,
        subscriptionlevel INTEGER DEFAULT 0 NOT NULL,
        subscriptiontokens INTEGER DEFAULT 0 NOT NULL,
        next_daily INTEGER DEFAULT 0 NOT NULL,
        chatid TEXT,
        model TEXT DEFAULT "horde" NOT NULL
    );
]]
local query_update_userlist = [[
    UPDATE Users 
    SET %s = "%s"
    WHERE id = %s;
]]
local query_lang_userlist = [[
    UPDATE Users 
    SET lang = %s
    WHERE id = %s;
]]
local query_referal_userlist = [[
    UPDATE Users 
    SET referal = %s
    WHERE id = %s;
]]
local query_add_userlist =  [[
    INSERT INTO "Users" (id, first_name, last_name, username, display_name, next_daily, tokens, chatid)
    VALUES (%s, '%s', '%s', '%s', '_NONAME_', 0, %s, '%s');
]]

local query_get_chat = [[
    CREATE TABLE IF NOT EXISTS "%s_%s" (
        id INTEGER,
        content TEXT,
        role TEXT
    );

    SELECT * FROM ("%s_%s");
]]
local query_get_all_chats = [[
    CREATE TABLE IF NOT EXISTS "%s" (
        id INTEGER PRIMARY KEY
    );

    SELECT * FROM ("%s");
]]

local query_check_if_exists = [[
    CREATE TABLE IF NOT EXISTS "%s" (
        id INTEGER PRIMARY KEY
    );
    INSERT INTO "%s" (
        id
    )
    VALUES (%s);
    
    CREATE TABLE IF NOT EXISTS "%s" (
        id INTEGER,
        role TEXT,
        content TEXT
    );
]]
local query_add_chat =  [[
    INSERT INTO "%s" (
        id,
        role,
        content
    )
    VALUES (?, ?, ?);
]]
local query_set_chat = [[
    UPDATE "%s" 
    SET content = "%s" 
    WHERE id = %s;
]]


print("Initializing the database")
local db = sqlite3.open(PATH_DB_USERS)
db:execute(query_init_userlist)
db:close()



function db_Load()
    do
        local db = sqlite3.open(PATH_DB_USERS)
        local db_ram_userlist = db:execute([[
            SELECT * FROM (Users);
        ]]) or {}
        local db_userlist_id = {}
        for _, var in pairs(db_ram_userlist) do
            db_userlist_id[tonumber(var.id)] = var
            db_userlist_id[tonumber(var.id)].id = tonumber(db_userlist_id[tonumber(var.id)].id)
            db_userlist_id[tonumber(var.id)].tokens = tonumber(db_userlist_id[tonumber(var.id)].tokens)
            db_userlist_id[tonumber(var.id)].subscriptiontokens = tonumber(db_userlist_id[tonumber(var.id)].subscriptiontokens)
            db_userlist_id[tonumber(var.id)].subscriptionlevel = tonumber(db_userlist_id[tonumber(var.id)].subscriptionlevel)
            db_userlist_id[tonumber(var.id)].referal = tonumber(db_userlist_id[tonumber(var.id)].referal)
            db_userlist_id[tonumber(var.id)].next_daily = tonumber(db_userlist_id[tonumber(var.id)].next_daily)
        end
        function AddUserColumn(value)
            local commit = sqlite3.open(PATH_DB_USERS)
            commit:execute(([[
                ALTER TABLE Users 
                ADD COLUMN %s;
            ]]):format(value))
            commit:close()
        end
        function GetUserFromDB(id)
            return db_userlist_id[id]
        end
        function GetAllUsers()
            return db_userlist_id
        end
        function GetAllUsersI()
            return db_ram_userlist
        end
        function GetUserLang(id)
            return db_userlist_id[id].lang
        end
        function UpdateUserReferal(user, target)
            if db_userlist_id[user.id].referal == 0 then
                db_userlist_id[user.id].referal = target
                --table.insert(db_userlist_refs, db_userlist_id[user.id])
                local commit = sqlite3.open(PATH_DB_USERS)
                commit:execute(query_referal_userlist:format(target, user.id))
                commit:close()
                return true
            else
                return false
            end
        end
        function UpdateUserToDB(id, key, value)
            db_userlist_id[id][key] = value
            --table.insert(db_userlist_changes, db_userlist_id[id])
            local commit = sqlite3.open(PATH_DB_USERS)
            --commit:execute(query_update_userlist:format(db_userlist_id[id].display_name, db_userlist_id[id].lang, db_userlist_id[id].tokens, id, ))
            commit:execute(query_update_userlist:format(key, value, id))
            commit:close()
        end
        function AddUserToDB(user, chatid)
            db_userlist_id[user.id] = {id = user.id, first_name = user.first_name, last_name = user.last_name, username = user.username, lang = "ru", tokens = 200, subscriptionlevel = 0, subscriptiontokens = 0, next_daily = 0, chatid = chatid}
            
            
            local commit = sqlite3.open(PATH_DB_USERS)
            commit:execute(query_add_userlist:format(db_userlist_id[user.id].id, db_userlist_id[user.id].first_name or "", db_userlist_id[user.id].last_name or "", db_userlist_id[user.id].username or db_userlist_id[user.id].first_name, 100, chatid))
            commit:close()
            return db_userlist_id[user.id]
            --table.insert(db_userlist_additions, db_userlist_id[user.id])
        end
        function GetUserName(user)
            return db_userlist_id[user.id].display_name ~= "_NONAME_" and db_userlist_id[user.id].display_name or db_userlist_id[user.id].first_name
        end
        print("CLOSE")
        db:close()
        print("  DONE")
    end

    print("CHATS")
    do
        local db = sqlite3.open(PATH_DB_CHATS)
        local db_ram_chats = {}
        for _, var in ipairs(GetAllUsersI()) do
            local t = db:execute(query_get_all_chats:format(var.id, var.id)) or {}
            db_ram_chats[tonumber(var.id)] = {}
            for i, chat in pairs(t) do
                local contents = db:execute(query_get_chat:format(chat.id, var.id, chat.id, var.id)) or {}
                chat.id = tonumber(chat.id)
                db_ram_chats[tonumber(var.id)][chat.id] = {
                    id = chat.id,
                    char = characters.GetCharacter(chat.id),
                    owner = var,
                    content = contents
                }
                chats.SetMetatable(db_ram_chats[tonumber(var.id)][chat.id])
            end
        end
        function GetUserChat(owner, char)
            if not db_ram_chats[owner.id] then
                db_ram_chats[owner.id] = {}
            end
            if char then
                return db_ram_chats[owner.id][char.id]
            else
                return db_ram_chats[owner.id]
            end
        end
        function NewUserChat(chat)
            db_ram_chats[chat.owner.id][chat.id] = chat
            chat.content = {}
            --table.insert(db_chats_additions, chat)
            local commit = sqlite3.open(PATH_DB_CHATS)
            commit:execute(query_check_if_exists:format(chat.owner.id, chat.owner.id, chat.id, chat.id .. "_" .. chat.owner.id))
            do 
                local stmt = commit:prepare(query_add_chat:format(chat.id .. "_" .. chat.owner.id))
                stmt:bind_values(1, "system", chat.char:GetSystem(chat.owner))
                stmt:step()
                stmt:finalize()
                table.insert(chat.content, {id = 1, role = "system", content = chat.char:GetSystem(chat.owner)})
            end
            do 
                local stmt = commit:prepare(query_add_chat:format(chat.id .. "_" .. chat.owner.id))
                stmt:bind_values(2, "system", chat.char:GetStarter(chat.owner))
                stmt:step()
                stmt:finalize()
                table.insert(chat.content, {id = 2, role = "system", content = chat.char:GetStarter(chat.owner)})
            end
            for _, var in ipairs(chat.char.history) do
                chat:AppendContent(var.content, var.role)
            end
            
            commit:close()
            return chat
        end
        function AppendUserChat(chat, role, str)
            table.insert(chat.content, {id = #chat.content+1, role = role, content = str})
            local commit = sqlite3.open(PATH_DB_CHATS)
            local stmt = commit:prepare(([[
                INSERT INTO "%s" 
                (id, role, content)
                VALUES
                (?, ?, ?);
            ]]):format(chat.id .. "_" .. chat.owner.id))
            stmt:bind_values(#chat.content, role, str)
            stmt:step()
            stmt:finalize()
        end
        db:close()
    end
    print("DB success")
end





function AppendUserChat(char_id, owner_id, role, str)
    local commit = sqlite3.open(PATH_DB_CHATS)
    local stmt = commit:prepare(([[
        INSERT INTO "%s" 
        (id, role, content)
        VALUES
        ((SELECT MAX(id) FROM "%s")+1, ?, ?);
    ]]):format(char_id .. "_" .. owner_id, char_id .. "_" .. owner_id))
    stmt:bind_values(role, str)
    stmt:step()
    stmt:finalize()
end
function ClearChat(char_id, owner_id)   
    local commit = sqlite3.open(PATH_DB_CHATS)
    commit:execute(([[
        DROP TABLE "%s";
        
        CREATE TABLE "%s" (
            id INTEGER,
            role TEXT,
            content TEXT
        );
    ]]):format(char_id .. "_" .. owner_id, char_id .. "_" .. owner_id))
    commit:close()
end
function RemoveLastResponse(char_id, owner_id)
    local commit = sqlite3.open(PATH_DB_CHATS)
    commit:execute(([[
        DELETE FROM "%s" WHERE id = (SELECT MAX(id) FROM "%s");
    ]]):format(char_id .. "_" .. owner_id, char_id .. "_" .. owner_id))
    
    commit:close() 
end





local function split(inputstr, sep)
    local t={}
    for str in string.gmatch(inputstr, "([^"..(sep or "%s").."]+)") do
        table.insert(t, str)
    end
    return unpack(t)
end
local enet = require "enet"
local host = enet.host_create()
local server = host:connect("localhost:6750")
while true do
    local event = host:service(100)
    while event do
        if event.type == "receive" then
            res = commands[event.channel](split(event.data, "<MEGAHIDDENSEPARATOR>"))
            if res then
                event.peer:send(table.concat(res, "<MEGAHIDDENSEPARATOR>"))
            end
        elseif event.type == "connect" then
            event.peer:send("RegisterService", 0)
        elseif event.type == "disconnect" then
            error()
        end
        event = host:service()
    end
end