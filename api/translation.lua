local translator = {}

local from_body = {
    impressionId = "da26b419-206d-4520-8c9e-957b5c08b68a",
    sourceLanguage = "en",
    targetLanguage = "ru",
    text = ""
}
local to_body = {
    impressionId = "da26b419-206d-4520-8c9e-957b5c08b68a",
    sourceLanguage = "ru",
    targetLanguage = "en",
    text = ""
}

local headers = {
    ["accept"] = "*/*",
    ["accept-language"] = "en-US,en;q=0.9,ru;q=0.8,de;q=0.7,de-DE;q=0.6",
    ["content-type"] = "application/json",
    ["sec-ch-ua"] = '"Chromium";v="122", "Not(A:Brand";v="24", "Microsoft Edge";v="122"',
    ["sec-ch-ua-mobile"] = "?0",
    ["sec-ch-ua-platform"] = '"Windows"',
    ["sec-fetch-dest"] = "empty",
    ["sec-fetch-mode"] = "cors",
    ["sec-fetch-site"] = "same-site",
    ["Referer"] = "https://ru.pons.com/",
    ["Referrer-Policy"] = "strict-origin-when-cross-origin"
}

local function __promise(retryafter, f, ...)
    retryafter = retryafter or 0.1
    local r = f(...)
    if not r then
        love.timer.sleep(retryafter)
        __promise(nil, f, ...)
    end
    return r
end
local function __saferequest(link, table, data)
    local code, body, headers = https.request(link, table, data)
    if code == 0 then
        love.timer.sleep(0.05)
        return __saferequest(link, table, data)
    elseif code == 200 then
        return body
    else
        print("There was an error during a request! Error code: "..code.."\n"..telelove.json.decode(body).description)
        print(table.data)
    end
end

function translator.__ToRussian(str)
    from_body.text = str
    local code, body, headers = https.request("https://api.pons.com/text-translation-web/v4/translate?locale=ru", {method = "post", headers = headers, data = telelove.json.encode(from_body)})
    if code == 200 then
        return telelove.json.decode(body).text
    end
end
function translator.ToRussian(str)
    return __promise(0.5, translator.__ToRussian, str)
end


function translator.__ToEnglish(str)
    to_body.text = str
    local code, body, headers = https.request("https://api.pons.com/text-translation-web/v4/translate?locale=ru", {method = "post", headers = headers, data = telelove.json.encode(to_body)})
    if code == 200 then
        return telelove.json.decode(body).text
    end
end
function translator.ToEnglish(str)
    return __promise(0.5, translator.__ToEnglish, str)
end

function translator.Translate(str, source, target)
    if source == target then return str end
    
    local body = {
        impressionId = "da26b419-206d-4520-8c9e-957b5c08b68a",
        sourceLanguage = source,
        targetLanguage = target,
        text = str
    }
    local r = __saferequest("https://api.pons.com/text-translation-web/v4/translate?locale=ru", {method = "post", headers = headers, data = telelove.json.encode(body)})
    return telelove.json.decode(r).text
end

return translator