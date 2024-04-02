local chats = {}
local base = {}

function chats.NewChat(owner, char)
    local chat = setmetatable({}, {__index = base}):__new(owner, char)
    return NewUserChat(chat)
end
function chats.SetMetatable(t)
    return setmetatable(t, {__index = base})
end
function chats.GetChats(owner)
    return GetUserChat(owner)
    
    
    --[=[
    local db = db_chats
    local collection = db:execute(([[
        SELECT id FROM "%s"
    ]]):format(owner.id))
    local r = {}
    if collection then
        for _, var in ipairs(collection) do
            table.insert(r, setmetatable({}, {__index = base}):__load(owner, var.id, characters.GetCharacter(tonumber(var.id))))
        end
    end
    --db:close()
    return r
    ]=]
end
function chats.DeleteUserChat(owner, char)
    --[=[
    local db = db_chats
    db:execute(([[
        DELETE FROM "%s"
        WHERE id = %s
    ]]):format(owner.id, char.id))
    ]=]
    --db:close()
end
function chats.GetUserChat(owner, char)
    return GetUserChat(owner, char)
    
    --[=[
    local db = db_chats
    local collection = db:execute(([[
        SELECT id FROM "%s" WHERE id = %s
    ]]):format(owner.id, char.id))
    --db:close()
    if collection then
        local r = setmetatable({}, {__index = base}):__load(owner, collection[1].id, characters.GetCharacter(tonumber(collection[1].id)))
        return r
    end
    ]=]
end





-------------------------------------------------------------
--------------------------- base ----------------------------
-------------------------------------------------------------

base.owner = telelove.__class.__user()
function base:__new(owner, char)
    self.owner = owner
    self.id = char.id
    self.char = char
    self.content = char:GetGreeting(owner)
    return self
end
function base:__load(owner, id, char, content)
    self.owner = owner
    self.id = char.id
    self.char = char
    self.content = content
    return self
end

function base:GetContents()
    return self.content
end

function base:AppendContent(str)
    self.content = self.content .. str
    ChangeUserChat(self)
end
function base:SetContent(str)
    self.content = str
    ChangeUserChat(self)
end
function base:RemoveLastResponse()
    local str = self:GetContents()
    --FIX: that shit is brokey
    str = str:sub(0, str:len() - (str:reverse():find(("###"):reverse()) or -1)-1)
    self:SetContent(str)
end
function base:GetLastResponse()
    local str = self:GetContents()
    local first_e, lastdotpos_e = (str:reverse()):find(("Instruction"):reverse())
    local first_n, lastdotpos_n = (str:reverse()):find(("Response"):reverse())
    
    if first_e and first_n then
        return str:sub(2 - math.min(first_e or 0, first_n or 0))
    else
        return characters.GetCharacter(self.id):GetFirstMessage(self.owner)
    end
end

function base:GetResponse(chat, msg, user, callback)
    self:AppendContent(([[
### Response:
%s:]]):format(self.char.name))
    self.task = horde.Generate(self:GetContents(), callback, {chat, self, msg, user}, {self.char.name..":", GetUserName(self.owner)})
end

return chats