local science = {}

function science.New(filename, pattern)
    local t = {}
    if not love.filesystem.getInfo(filename, "file") then
        love.filesystem.write(filename, "")
    end
    
    return function(...)
        local str = pattern:gsub("%d", os.date("%x")):gsub("%t", os.date("%X")):format(...)
        love.filesystem.append(filename, str)
    end
end

return science