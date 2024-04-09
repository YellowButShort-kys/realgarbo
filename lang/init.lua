LANG = {}
local default = {__index = LANG["en"]}
require("lang.en")
require("lang.ru")
require("lang.ua")
setmetatable(LANG["ru"], default)
setmetatable(LANG["en"], default)