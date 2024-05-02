local translator = {}
--y0_AgAAAAB1Lo5VAATuwQAAAAEAgJ10AADHpMX4thFH-rlsOzbbt56wYqFfRw

local body = {
    method = "post", 
    headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer t1.9euelZqej52LjM6akM-MnZyXlJKZnO3rnpWajoyKm4uVi5bOzsycjI_Jy5rl9PdOOlVP-e9xAiGi3fT3DmlST_nvcQIhos3n9euelZqLzY_Ky5mJkcyelZvKjsyXyO_8xeuelZqLzY_Ky5mJkcyelZvKjsyXyA.b7IIq4mSAFqzzo00dPY5X1HNkwywjexumEyXTN2yraSqoE3f1fVWLaJgRiTA7cwI-3zBD-1YavPG0Ne1ghUhAA"
    }
}
local data

local function __saferequest(link, table, data)
    local code, body, headers = https.request(link, table, data)
    if code == 0 then
        love.timer.sleep(0.2)
        return __saferequest(link, table, data)
    elseif code == 200 then
        return body
    else
        prettyprint(telelove.json.decode(body))
        print("There was an error during a request! Error code: "..code.."\n")
        print(table.data)
    end
end
function translator.RetriveToken()
    local r = __saferequest("https://iam.api.cloud.yandex.net/iam/v1/tokens", {method = "post", data = telelove.json.encode({yandexPassportOauthToken = "y0_AgAAAAB1Lo5VAATuwQAAAAEAgJ10AADHpMX4thFH-rlsOzbbt56wYqFfRw"})})
    if r then
        print()
        print("New token recieved!")
        body["headers"]["Authorization"] = "Bearer " .. telelove.json.decode(r).iamToken
        print(body["headers"]["Authorization"])
        print()
        return true
    else
        print("TOKEN ERROR!")
    end
end
function translator.Translate(str, source, target, test)
    if source == target then
        return str
    end
    
    data = telelove.json.encode({
        ["sourceLanguageCode"] = source,
        ["targetLanguageCode"] = target,
        ["texts"] = {str},
        ["folderId"] = "b1g15f5au931q1a4dqve",
    })
    
    body.data = data
    local r = __saferequest("https://translate.api.cloud.yandex.net/translate/v2/translate", body)
    if r then
        return telelove.json.decode(r).translations[1].text
    else
        if not test and translator.RetriveToken() then
            return translator.Translate(str, source, target, true)
        else
            return "Произошла ошибка во время перевода, скорее всего из за некачественного ответа нейросети. Попробуйте опять."
        end
    end
end

return translator