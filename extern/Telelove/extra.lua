local str = (...):sub(0, -6)
return function(telelove)
    function telelove.__error(str)
        print(string.format("[%s][ERROR]: %s", os.date("%X", os.time()), str))
    end
    function telelove.__warning(str)
        if telelove.Verbosity then
            print(string.format("[%s][WARNING]: %s", os.date("%X", os.time()), str))
        end
    end
    function telelove.__print(str)
        if telelove.Verbosity then
            print(string.format("[%s]: %s", os.date("%X", os.time()), str))
        end
    end
    telelove.json = require(str.."json") -- shoutout to rxi
    
    function telelove.__promise(retryafter, f, ...)
        retryafter = retryafter or 0.1
        local r = f(...)
        if not r then
            love.timer.sleep(retryafter)
            r = telelove.__promise(nil, f, ...)
        end
        return r
    end
    function telelove.__verifyrequest(code, body, headers)
        if code ~= 200 then
            telelove.__error("There was an error during a request! Error code: "..code)
            if code == 400 then
                print(body)
            end
        end
        return code, body, headers
    end
    
    function telelove.__counttokens(s)
        local _, n = s:gsub("%S+","")
        return math.ceil(n * 0.75)
    end
    
    function telelove.__saferequest(link, table, counter)
        if not counter then counter = 1 end
        if counter == 24 then telelove.__error("Request failed after 24 attempts!") return false end
        local code, body, headers = https.request(link, table)
        if code == 0 then
            love.timer.sleep(0.05)
            return telelove.__saferequest(link, table, counter + 1)
        elseif code == 200 then
            return body
        else
            telelove.__error("There was an error during a request! Error code: "..code.."\n"..telelove.json.decode(body).description)
            print(table.data)
        end
    end
    
    
    do
        local replacement = {}
        replacement["%_"] = "\\_"
        replacement["%["] = "\\["
        replacement["%]"] = "\\]"
        replacement["%("] = "\\("
        replacement["%)"] = "\\)"
        replacement["%~"] = "\\~"
        replacement["%`"] = "\\`"
        replacement["%>"] = "\\>"
        replacement["%#"] = "\\#"
        replacement["%+"] = "\\+"
        replacement["%-"] = "\\-"
        replacement["%="] = "\\="
        replacement["%|"] = "\\|"
        replacement["%{"] = "\\{"
        replacement["%}"] = "\\}"
        replacement["%."] = "\\."
        replacement["%!"] = "\\!"
        replacement["%'"] = "\\'"
        replacement['%"'] = '\\"'
        replacement["%."] = "\\."
        function telelove.__httpfy(str)
            --str = str or ""
            --str = str:gsub("%\\", "\\\\")
            --for i, var in pairs(replacement) do
            --    str = str:gsub(i, var)
            --end
            return str
        end
    end
    
    do
        local replacement = {}
        replacement["%;"] = "\\;"
        replacement["%'"] = "\\'"
        replacement['%"'] = '\\"'
        function telelove.__sqlfy(str)
            str = str:gsub("%\\", "\\\\")
            for i, var in pairs(replacement) do
                str = str:gsub(i, var)
            end
            return str
        end
    end
end