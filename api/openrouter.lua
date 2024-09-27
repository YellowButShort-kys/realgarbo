return function(token, model, price, additional_data)
    local lib = {}
    local LINK = "https://openrouter.ai/api/v1/chat/completions"
    local pool = requests.CreatePool(6, 0.05, 24)
    token = token or OPENROUTER_TOKEN
    
    local data = {
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer "..token
        },
        method = "POST",
        data = {
            ["model"] = model,
            ["max_tokens"] = 150,
            ["temperature"] = 0.8,
            --["top_p"] = 1,
            --["presence_penalty"] = 0,
            --["frequency_penalty"] = 0,
            ["stop"] = {"<|endoftext|>", "<START>", "<|eot_id|>", "#"},
            ["messages"] = {
                
            }
        }
    }
    if additional_data then
        for key, val in pairs(additional_data) do
            data.data[key] = val
        end
    end
    
    local megacallback = function(success, errcode, result, extra)
        if success then
            if not result.usage then
                master_client:SendToFather(prettyjson(result))
                error("Looks like we've run out of money...")
            end
            print(result.usage.prompt_tokens, result.usage.completion_tokens)
            extra.kudos = math.ceil(result.usage.prompt_tokens / (price[1] or 100)) + math.ceil(result.usage.completion_tokens / (price[2] or 50))
            print(extra.kudos)
            extra:callback(result.choices[1].message.content or " ")
        else
            print(errcode)
            print()
            prettyjson(result)
            print()
            extra:err("Error")
        end
    end

    function lib.Generate(messages, callback, errcallback, extra, stop_sequence)
        local old_messages = data["data"]["messages"]
        local old_stop = data["data"]["stop"]
        data["data"]["messages"] = messages
        data["data"]["stop"] = {}
        for _, var in ipairs(old_stop) do
            table.insert(data["data"]["stop"], var)
        end
        for _, var in ipairs(stop_sequence) do
            table.insert(data["data"]["stop"], var)
        end
        
        local task = {}
        task.err = errcallback
        task.callback = callback
        task.extra = extra
        
        pool:Request(LINK, data, megacallback, task)
        data["data"]["messages"] = old_messages
        data["data"]["stop"] = old_stop
        
        return task
    end

    return lib
end