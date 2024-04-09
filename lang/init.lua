LANG = {}
local default = {__index = LANG["en"]}
require("lang.en")
setmetatable(require("lang.ru"), default)
setmetatable(require("lang.ua"), default)