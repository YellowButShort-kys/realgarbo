local characters = {}
local hub = {}
local hub_tags = {}
local base = {}

function characters.LoadCharacters()
    
end

function characters.GetCharacter(id)
    return hub[id]
end

function characters.GetHub()
    return hub
end

hub[1] = setmetatable(require(... .. ".person_mia"), {__index = base})
hub[2] = setmetatable(require(... .. ".anime_megumin"), {__index = base})
hub[3] = setmetatable(require(... .. ".anime_kazuma_sato"), {__index = base})
hub[4] = setmetatable(require(... .. ".games_tf2heavy"), {__index = base})
hub[5] = setmetatable(require(... .. ".games_tf2soldier"), {__index = base})
hub[6] = setmetatable(require(... .. ".anime_morgan_le_fey"), {__index = base})
hub[7] = setmetatable(require(... .. ".anime_aqua"), {__index = base})
hub[8] = setmetatable(require(... .. ".games_alyx"), {__index = base})
hub[9] = setmetatable(require(... .. ".anime_tamamo"), {__index = base})

for _, var in ipairs(hub) do
    for _, tag in ipairs(var.tags) do
        if not hub_tags[tag] then hub_tags[tag] = {} end
        table.insert(hub_tags[tag], var)
    end
end

function characters.GetTagged()
    return hub_tags
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

Write {{char}}'s next reply in a fictional roleplay chat between {{char}} and {{user}}.
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

function base:GetGreeting(user)
    return (self.starter:gsub("{{user}}", GetUserName(user)):gsub("{{char}}", self.name))
end

function base:GetFirstMessage(user)
    return (self.greeting:gsub("{{user}}", GetUserName(user)):gsub("{{char}}", self.name))
end

function base:GetSystem(user)
    return (self.system:gsub("{{user}}", GetUserName(user)):gsub("{{char}}", self.name))
end

return characters