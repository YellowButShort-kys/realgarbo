local str = (...).."."
local proxy = {}
local mt = {
    __call = function(self, target)
        local t = setmetatable(target or {}, self)
        if t.__init then 
            t:__init()
        end
        return t
    end,
    __newindex = function(self, key, value)
        if not proxy[self] then proxy[self] = {} end
        
        proxy[self][key] = value
    end,
    __index = function(self, key)
        return proxy[self] and proxy[self][key]
    end
}




return function(telelove)
    telelove.__class = {}
    telelove.__class.__user                   =   setmetatable({__index=require(str.."user")(telelove.__class)}, mt)
    telelove.__class.__chat                   =   setmetatable({__index=require(str.."chat")(telelove.__class),
    __eq = function(a, b)
        return a.id == b.id
    end,
    }, mt)
    telelove.__class.__message                =   setmetatable({__index=require(str.."message")(telelove.__class)}, mt)
    telelove.__class.__update                 =   setmetatable({__index=require(str.."update")(telelove.__class)}, mt)
    telelove.__class.__command                =   setmetatable({__index=require(str.."command")(telelove.__class)}, mt)
    telelove.__class.__callbackquery          =   setmetatable({__index=require(str.."callbackquery")(telelove.__class)}, mt)
    
    
    local function build(base, extra)
        local bmt = {
            __newindex = function(self, key, value)
                if base[key] then
                    rawset(self, key, value)
                else
                    if not proxy[self] then proxy[self] = {} end
                    proxy[self][key] = value
                end
            end,
            __index = function(self, key)
                return proxy[self] and proxy[self][key] or extra and extra[key] or base[key]
            end
        }
        return function(target)
            local t = setmetatable(target or {}, bmt)
            if t.__init then 
                t:__init()
            end
            return t
        end
    end
    
    local __replykeyboardbutton, __replykeyboardbutton_extra = require(str.."replykeyboardbutton")(telelove.__class)
    telelove.__class.__replykeyboardbutton    =   build(__replykeyboardbutton, __replykeyboardbutton_extra)
    local __replykeyboardmarkup, __replykeyboardmarkup_extra = require(str.."replykeyboardmarkup")(telelove.__class)
    telelove.__class.__replykeyboardmarkup    =   build(__replykeyboardmarkup, __replykeyboardmarkup_extra)
    local __inlinekeyboardbutton, __inlinekeyboardbutton_extra = require(str.."inlinekeyboardbutton")(telelove.__class)
    telelove.__class.__inlinekeyboardbutton   =   build(__inlinekeyboardbutton, __inlinekeyboardbutton_extra)
    local __inlinekeyboardmarkup, __inlinekeyboardmarkup_extra = require(str.."inlinekeyboardmarkup")(telelove.__class)
    telelove.__class.__inlinekeyboardmarkup   =   build(__inlinekeyboardmarkup, __inlinekeyboardmarkup_extra)
end