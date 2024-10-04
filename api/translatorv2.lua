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

function recordExpenses(success, errcode, result, extra)
    sciencev2.onExpenses(result.data.total_cost, "Translation")
end
local OR = function(token, model, additional_data)
    local lib = {}
    local LINK = "https://openrouter.ai/api/v1/chat/completions"
    token = token or OPENROUTER_TOKEN
    
    local ogdata = {
        ["model"] = model,
        ["max_tokens"] = 150,
        ["temperature"] = 0.8,
        --["top_p"] = 1,
        --["presence_penalty"] = 0,
        --["frequency_penalty"] = 0,
        ["stop"] = {"<|endoftext|>", "<START>", "<|eot_id|>", "#"}
    }
    if additional_data then
        for key, val in pairs(additional_data) do
            ogdata[key] = val
        end
    end
    function lib.Generate(messages)
        ogdata["messages"] = messages
        
        local code, body = https.request(LINK, {
            headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer "..token
            },
            method = "POST",
            data = json.encode(ogdata)
        })
        assert(code == 200, body)
        
        ogdata["messages"] = nil
        
        body = json.decode(body)
        requests.Request("https://openrouter.ai/api/v1/generation?id="..body.id, {method = "GET", headers = {["Content-Type"] = "application/json", ["Authorization"] = "Bearer "..token}}, recordExpenses)
        
        return body.choices[1].message.content or " "
    end

    return lib
end


-----------------------------------------------------------------

local model = OR(nil, "mistralai/mistral-nemo", {
    temperature = 0.25,
    max_tokens = 150,
    provider = {
        order = {
            "Mistral"
        },
        allow_fallbacks = false,
    },
})

translation = {}

local lookup = {
    ru = "Russian",
    en = "English"
}
function translation.Translate(str, source, target)
    if source == target then
        return str
    end

    return model.Generate({
        {role = "system", content = string.format([[Translate this message to %s. Preserve all punctuation including asterisks. Output only the translation:

%s]], lookup[target] or target, str)}
    })
end