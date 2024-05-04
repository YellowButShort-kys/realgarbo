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


function db_Init()
    print("Initializing the database")
    local db = sqlite3.open(PATH_DB_USERS)
    db:execute(query_init_userlist)
    db:close()
end


function db_Update(ignore)
    if not next then next = love.timer.getTime() + 3600 end -- 1 hour
    
    if ignore or (next < love.timer.getTime()) then
        next = love.timer.getTime() + 3600
        if #db_userlist_additions > 0 then
            local db = sqlite3.open(PATH_DB_USERS)
            local commit = {}
            for _, var in ipairs(db_userlist_additions) do
                --id, first_name, last_name, username, display_name, tokens
                table.insert(commit, query_add_userlist:format(var.id, var.first_name or "", var.last_name or "", var.username or "", 50))
            end
            db:execute(table.concat(commit, "\n\n"))
            db:close()
        end
        db_userlist_additions = {}
        if #db_userlist_changes > 0 then
            local db = sqlite3.open(PATH_DB_USERS)
            local commit = {}
            for _, var in ipairs(db_userlist_changes) do
                
                table.insert(commit, query_update_userlist:format(var.tokens, var.display_name, var.id))
            end
            db:execute(table.concat(commit, "\n\n"))
            db:close()
        end
        db_userlist_changes = {}
        if #db_userlist_refs > 0 then
            local db = sqlite3.open(PATH_DB_USERS)
            local commit = {}
            for _, var in ipairs(db_userlist_refs) do
                table.insert(commit, query_referal_userlist:format(var.referal, var.id))
            end
            db:execute(table.concat(commit, "\n\n"))
            db:close()
        end
        db_userlist_refs = {}
        if #db_userlist_lang > 0 then
            local db = sqlite3.open(PATH_DB_USERS)
            local commit = {}
            for _, var in ipairs(db_userlist_lang) do
                table.insert(commit, query_lang_userlist:format(var.lang, var.id))
            end
            db:execute(table.concat(commit, "\n\n"))
            db:close()
        end
        db_userlist_lang = {}
        
        if #db_chats_additions > 1 then
            local db = sqlite3.open(PATH_DB_CHATS)
            local commit = {}
            for _, var in ipairs(db_chats_additions) do
                table.insert(commit, query_add_chat:format(var.owner.id, var.owner.id, var.id, var.char:GetStarter(var.owner)))
            end
            db:execute(table.concat(commit, "\n\n"))
            db:close()
        end
        db_chats_additions = {}
        if #db_chats_changes > 1 then
            local db = sqlite3.open(PATH_DB_CHATS)
            local commit = {}
            for _, var in ipairs(db_chats_changes) do
                table.insert(commit, query_set_chat:format(var.owner.id, var.content, var.id))
            end
            db:execute(table.concat(commit, "\n\n"))
            db:close()
        end
        db_chats_changes = {}
        --[[
        db_chats:close()
        db_userlist:close()
        db_chats = sqlite3.open_memory(PATH_DB_CHATS)
        db_userlist = sqlite3.open_memory(PATH_DB_USERS)
        ]]
    end
end

function love.quit()
    db_Update(true)
end

local function ClearMessage(msg)
    msg:EditMessageText(LANG["ru"]["$CRASH"], {inline_keyboard = {}})
end
local function error_printer(msg, layer)
    --for _, var in pairs(FALLBACK) do
    --    pcall(ClearMessage, var)
    --end
    
	local bruh = ((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
    master_client:SendToFather(bruh)
    print(bruh)
end


local utf8 = require("utf8")
function love.errorhandler(msg)
    --db_Update(true)
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()
	local font = love.graphics.setNewFont(14)

	love.graphics.setColor(1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

	local function draw()
		if not love.graphics.isActive() then return end
		local pos = 70
		love.graphics.clear(89/255, 157/255, 220/255)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end

	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
	end

	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end




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
        function ClearChat(chat)
            chat.content = {}
            
            local commit = sqlite3.open(PATH_DB_CHATS)
            commit:execute(([[
                DROP TABLE "%s";
                
                CREATE TABLE "%s" (
                    id INTEGER,
                    role TEXT,
                    content TEXT
                );
            ]]):format(chat.char.id .. "_" .. chat.owner.id, chat.char.id .. "_" .. chat.owner.id))
            commit:close()
        end
        function RemoveResponseChat(chat, i)
            local size = #chat.content or 0
            if i == 0 then
                chat.content = {}
            else
                if i then
                    for x = size, i do
                        table.remove(chat.content, x)
                    end
                else
                    table.remove(chat.content)
                end
            end
            local commit = sqlite3.open(PATH_DB_CHATS)
            commit:execute(([[
                DELETE FROM "%s" 
                WHERE id >= %s;
            ]]):format(chat.id .. "_" .. chat.owner.id, i or size))
            
            commit:close() 
        end
        db:close()
    end
    print("DB success")
end
