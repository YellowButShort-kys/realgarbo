local str = (...):sub(0, -10) .. "."
return function(telelove)
    require(str.."extra")(telelove)
    require(str.."classes")(telelove)
    telelove.__clientbase = {__index = require(str.."client")}
    telelove.__clientbase.__index.__telelove = telelove
    
    telelove.__threadedclientbase = {__index = require(str.."client_threaded")}
    telelove.__threadedclientbase.__index.__telelove = telelove
end