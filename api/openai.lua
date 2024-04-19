local openai = {}
local LINK = "https://unicorn.dragonetwork.pl/proxy/openai/chat/completions"
requests.Init(6, 0.05, 24)

local data = {
    ["model"] = "gpt-3.5-turbo",
    ["max_tokens"] = 250,
    ["temperature"] = 0.9,
    ["top_p"] = 1,
    ["presence_penalty"] = 0,
    ["frequency_penalty"] = 0,
    ["stop"] = {"<|endoftext|>"},
    ["messages"] = {
        
    }
}
local megacallback = function(success, errcode, result, extra)
    if success then
        extra.kudos = result.total_tokens / 10
        extra:callback(result.choices[1].message.content or " ")
    else
        print(errcode)
        print()
        prettyjson(result)
        print()
        extra:err("Error")
    end
end

function openai.Generate(messages, callback, errcallback, extra, stop_sequence)
    local old_messages = data["messages"]
    local old_stop = data["stop"]
    data["messages"] = messages
    data["stop"] = {}
    for _, var in ipairs(old_stop) do
        table.insert(data["stop"], var)
    end
    for _, var in ipairs(stop_sequence) do
        table.insert(data["stop"], var)
    end
    
    local task = {}
    task.err = errcallback
    task.callback = callback
    task.extra = extra
    
    requests.Request(LINK, data, megacallback, task)
    data["messages"] = old_messages
    data["stop"] = old_stop
    
    return task
end

return openai