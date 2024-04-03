local gpt = {}
local tasks = {}
local body = {
    method = "post", 
    headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer t1.9euelZqej52LjM6akM-MnZyXlJKZnO3rnpWajoyKm4uVi5bOzsycjI_Jy5rl9PdOOlVP-e9xAiGi3fT3DmlST_nvcQIhos3n9euelZqLzY_Ky5mJkcyelZvKjsyXyO_8xeuelZqLzY_Ky5mJkcyelZvKjsyXyA.b7IIq4mSAFqzzo00dPY5X1HNkwywjexumEyXTN2yraSqoE3f1fVWLaJgRiTA7cwI-3zBD-1YavPG0Ne1ghUhAA",
        ["x-folder-id"] = "b1g15f5au931q1a4dqve",
        ["x-data-logging-enabled"] = false
    }
}
local data = {
    ["modelUri"] = "gpt://b1g15f5au931q1a4dqve/yandexgpt-lite",
    ["completionOptions"] = {
        ["stream"] = false,
        ["temperature"] = 0.6,
        ["maxTokens"] = 200
    }
}

local function __saferequest(link, table, data)
    local code, body, headers = https.request(link, table, data)
    if code == 0 then
        love.timer.sleep(0.1)
        return __saferequest(link, table, data)
    elseif code == 200 then
        return body
    else
        print("There was an error during a request! Error code: "..code.."\n"..telelove.json.decode(body).description)
        print(table.data)
    end
end
local function RemoveByValue(t, val)
    for i, var in pairs(t) do
        if var == val then
            if type(i) == "number" then
                table.remove(t, i)
            else
                t[i] = nil
            end
        end
    end
end


function gpt.RetriveToken()
    local r = __saferequest("https://iam.api.cloud.yandex.net/iam/v1/tokens", {method = "post", data = telelove.json.encode({yandexPassportOauthToken = "y0_AgAAAAB1Lo5VAATuwQAAAAEAgJ10AADHpMX4thFH-rlsOzbbt56wYqFfRw"})})
    if r then
        print()
        print("New GPT token recieved!")
        body["headers"]["Authorization"] = "Bearer " .. telelove.json.decode(r).iamToken
        print(body["headers"]["Authorization"])
        print()
        return true
    else
        print("TOKEN ERROR!")
    end
end

function gpt.Generate(messages, callback)
    local msg = {}
    for _, var in ipairs(messages) do
        table.insert(msg, {role = var.role, text = var.text})
    end
    data.messages = msg
    body.data = telelove.json.encode(data)
    local r = telelove.json.decode(__saferequest("https://llm.api.cloud.yandex.net/foundationModels/v1/completionAsync", body))
    body.data = nil
    data.messages = nil
    
    table.insert(tasks, r)
    r.callback = callback
    
    return r
end

function gpt.FetchUpdate(task)
    local r = telelove.json.decode(__saferequest("https://llm.api.cloud.yandex.net/operations/"..task.id, {method = "get", headers = {body[headers].Authorization}}))
    if r.done then
        
    end
end

local nextupdate
function gpt.Update()
    if not nextupdate then nextupdate = love.timer.getTime() end
    
    if nextupdate <= love.timer.getTime() then
        for _, var in ipairs(tasks) do
            gpt.FetchUpdate(var)
        end
        
        nextupdate = love.timer.getTime() + 2
    end
end