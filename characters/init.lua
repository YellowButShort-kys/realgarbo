local characters = {}
local hub = {}
local hub_tags = {}
local tags = {}
local base = {}

function characters.LoadCharacters()
    
end

function characters.GetCharacter(id)
    return hub[id]
end

function characters.GetHub()
    return hub
end


local cwd = ...
local weekly
local function RegisterChar(path)
    local t = require(cwd .. "." .. path)
    setmetatable(t, {__index = base})
    t.id = #hub+1
    table.insert(hub, t)
    weekly = t
end

RegisterChar("person_mia")
RegisterChar("anime_megumin")
RegisterChar("anime_kazuma_sato")
RegisterChar("games_tf2heavy")
RegisterChar("games_tf2soldier")
RegisterChar("anime_morgan_le_fey")
RegisterChar("anime_aqua")
RegisterChar("games_alyx")
RegisterChar("anime_tamamo")
RegisterChar("helper_creativity")
RegisterChar("helper_elisa")
RegisterChar("games_dante")
RegisterChar("person_marie")
RegisterChar("rpg_zdrocharis")
RegisterChar("anime_fern")
RegisterChar("anime_suguru")
RegisterChar("anime_nami")
RegisterChar("games_tae_takemi")

local _tags = {}
for _, var in ipairs(hub) do
    for _, tag in ipairs(var.tags) do
        if not hub_tags[tag] then hub_tags[tag] = {} end
        if not _tags[tag] then _tags[tag] = true end
        table.insert(hub_tags[tag], var)
    end
end
for i, var in pairs(_tags) do
    table.insert(tags, i)
end
_tags = nil

function characters.GetTagged()
    return hub_tags
end
function characters.GetTags()
    return tags
end

function characters.GetWeekly()
    return weekly
end


local query_init_characters, query_new_character, query_load_characters
do
    query_init_characters = [[
        create table if not exists "custom_characters" (
            id INTEGER PRIMARY KEY, 
            name TEXT, 
            display_name TEXT, 
            description TEXT, 
            starter TEXT,
            greeting TEXT,
            creator INTEGER DEFAULT 0 NOT NULL, 
            tokens_generated INTEGER DEFAULT 0 NOT NULL,
            is_public INTEGER DEFAULT 0 NOT NULL,
            source_name TEXT,
            source_description TEXT,
            source_greeting TEXT
        );
    ]]
    query_new_character = [[
        INSERT INTO "custom_characters" (
            id,
            name, 
            display_name, 
            description,
            greeting, 
            creator,
            is_public,
            source_name,
            source_description,
            source_greeting
        )
        VALUES ( 
            ?,
            ?, 
            ?, 
            ?, 
            ?, 
            ?, 
            ?,
            ?,
            ?,
            ?
        );
    ]]
    query_load_characters = [[
        SELECT * FROM ("custom_characters");
    ]]
end
local custom_characters = {}
local custom_characters_id = {}
CUSTOM_CHARACTERS_LAST_ID = CUSTOM_CHARACTERS_OFFSET
function characters.LoadCustomCharacters()
    print("Loading custom characters...")
    local db = sqlite3.open(PATH_DB_CUSTOMCHARS)
    db:execute(query_init_characters)
    local chars = db:execute(query_load_characters) or {}
    for _, var in pairs(chars) do
        local char = setmetatable(var, {__index = base})
        char.starter = string.format([[
Name: %s
%s
]], char.name, char.description)
        char.history = {
            {
                role = "assistant",
                content = char.greeting
            }
        }
        char.is_public = char.is_public == 1
        table.insert(custom_characters, char)
        custom_characters_id[char.id] = char

        CUSTOM_CHARACTERS_LAST_ID = math.max(CUSTOM_CHARACTERS_LAST_ID, char.id)
    end
    print("Finished loading custom characters. Loaded: " .. tostring(#custom_characters) .. " characters")
    db:close()
end
function characters.SaveCustomCharacter(id, name, display_name, description, greeting, creator, is_public, source_name, source_description, source_greeting)
    local commit = sqlite3.open(PATH_DB_CUSTOMCHARS)
    
    local stmt = commit:prepare(query_new_character)
    stmt:bind_values(
        id,
        name,
        display_name,
        description,
        greeting,
        creator,
        is_public and 1 or 0,
        source_name,
        source_description,
        source_greeting
    )
    stmt:step()
    stmt:finalize()

    commit:close()


    local char = {
        id = id,
        name = name,
        display_name = display_name,
        description = description,
        greeting = greeting,
        creator = creator,
        is_public = is_public == 1,
        source_name = source_name,
        source_description = source_description,
        source_greeting = source_greeting
    }
    setmetatable(char, {__index = base})
    char.starter = string.format([[
Name: %s
%s
]], char.name, char.description)
    char.history = {
        {
            role = "assistant",
            content = char.greeting
        }
    }
    table.insert(custom_characters, char)
    custom_characters_id[char.id] = char

    return char
end
function characters.GetCustomCharacters()
    return custom_characters
end
function characters.GetCustomCharacter(id)
    return custom_characters_id[id]
end
function characters.NameSearch(name)
    local res = {}
    for _, var in ipairs(custom_characters) do
        if var.is_public and (var.source_name:find(name) or var.name:find(name)) then
            table.insert(res, var)
        end
    end
    return res
end
function characters.DescriptionSearch(description)
    local res = {}
    for _, var in ipairs(custom_characters) do
        if var.is_public and (var.source_description:find(description) or var.source_description:find(description)) then
            table.insert(res, var)
        end
    end
    return res
end

-------------------------------------------------------------
--------------------------- base ----------------------------
-------------------------------------------------------------

base.starter = [[
Below is an instruction that describes a task. Write a response that appropriately completes the request.

Write {{char}}'s next reply in a fictional roleplay chat between {{char}} and {{user}}.

{{char}}'s Persona: 
%s

The scenario of the conversation: 
%s

This is how {{char}} should talk: 
%s

***  

### Response:
{{char}}: %s
]]

base.name = "Robot"
base.description = "Test"
base.persona = [[
Name: Robot
species: robot
mind: kind, compassionate, caring, tender, forgiving, enthusiastic
personality: kind, compassionate, caring, tender, forgiving, enthusiastic
]]
base.system = [[
Below is an instruction that describes a task. Write a response that appropriately completes the request.

Write {{char}}'s next reply in a fictional roleplay chat between {{char}} and {{user}}. Do not act for {{user}}. Do not say anything for {{user}}. You are allowed only to speak and act as {{char}}
]]
base.example = [[
{{user}}: I have some big and important news to share!
{{char}}: *{{user}} appears genuinely excited* What is the exciting news?
]]
base.scenario = [[
{{char}} is sitting at a table in a busy cafe. You approach {{char}}'s table and wave at them. {{user}} sits down at the table in the chair opposite {{char}}.
]]
base.greeting = [[
*A soft smile appears on {{char}}'s face as {{user}} enters the cafe and takes a seat* *Beep! Boop!* Hello, {{user}}! It's good to see you again. What would you like to chat about?
]]

function base:GetStarter(user)
    return (self.starter:gsub("{{user}}", GetUserName(user)):gsub("{{char}}", self.name))
end

function base:GetFirstMessage(user)
    return (self.greeting:gsub("{{user}}", GetUserName(user)):gsub("{{char}}", self.name))
end

function base:GetSystem(user)
    return (self.system:gsub("{{user}}", GetUserName(user)):gsub("{{char}}", self.name))
end

function base:GetHistory()
    return self.history
end

function base:GetName()
    return self.name
end
function base:GetDisplayName(lang)
    return self.display_name[lang]
end

function base:FormatMessage(chat, str)
    return str
end
function base:FormatOutput(chat, str)
    return str
end

function base:AssemblePrompt()
    local newtext = ""
    local counter = 1
    while true do
        
    end
end

characters.LoadCustomCharacters()

return characters