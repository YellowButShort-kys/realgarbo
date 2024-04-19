local horde = {}
local tasks = {}

local prompt_storybook = [[You are a memory book creator. Collect the main information from the message that should be remembered into this template. Use this and only this template. If there are no important things to remember, output <NOTHING>
Template:
MemoryIndex, MemoryContent, Importance;
MemoryIndex, MemoryContent, Importance;
MemoryIndex, MemoryContent, Importance;


<START>
Anna: I hate rainy days
Output:
Rainy days; Anna dislikes rainy days; 0.8
<END>

<START>]]

local payload_storybook = {
    ["prompt"] = prompt_storybook,
    ["params"] = {
        ["n"] = 1,
        ["frmtadsnsp"] = true,
        ["frmtrmblln"] = false,
        ["frmtrmspch"] = false,
        ["frmttriminc"] = false,
        ["max_context_length"] = 2048,
        ["max_length"] = 30,
        ["rep_pen"] = 1.08,
        ["rep_pen_range"] = 1024,
        ["rep_pen_slope"] = 0.9,
        ["singleline"] = false,
        ["temperature"] = 0.3,
        ["tfs"] = 1,
        ["top_a"] = 0,
        ["top_k"] = 100,
        ["top_p"] = 0.9,
        ["typical"] = 1,
        ["sampler_order"] = {
            6,0,1,3,4,2,5
        },
        ["use_default_badwordsids"] = true,
        ["stop_sequence"] = {
            "#",
            "###"
        },
        ["min_p"] = 0,
        ["dynatemp_range"] = 0,
        ["dynatemp_exponent"] = 1
    },
    ["trusted_workers"] = false,
    ["slow_workers"] = true,
    ["worker_blacklist"] = false,
    ["models"] = {
        "koboldcpp/Mixtral-8x7B-Instruct-v0.1"
    },
    ["dry_run"] = false,
    ["disable_batching"] = false
}
--Airoboros, chronos, nous Hermes
local payload = {
    ["prompt"] = "",
    ["params"] = {
        ["n"] = 1,
        ["frmtadsnsp"] = false,
        ["frmtrmblln"] = false,
        ["frmtrmspch"] = true,
        ["frmttriminc"] = true,
        ["max_context_length"] = 2048,
        ["max_length"] = 120,
        ["rep_pen"] = 1.08,
        ["rep_pen_range"] = 1024,
        ["rep_pen_slope"] = 3,
        ["singleline"] = true,
        ["temperature"] = 0.75,
        ["tfs"] = 0.9,
        ["top_a"] = 1,
        ["top_k"] = 0,
        ["top_p"] = 0.9,
        ["typical"] = 1,
        ["use_default_badwordsids"] = false,
        ["stop_sequence"] = {
            "#",
            "###",
            "**",
            "OOC:"
        },
        ["min_p"] = 0,
        ["dynatemp_range"] = 0,
        ["dynatemp_exponent"] = 1
    },
    ["models"] = {
        "aphrodite/KoboldAI/LLaMA2-13B-Estopia",
        "koboldcpp/Mixtral-8x7B-Instruct-v0.1",
        "aphrodite/KoboldAI/LLaMA2-13B-Psyfighter2"
    },
    ["allow_downgrade"] = true,
    ["trusted_workers"] = false,
    ["slow_workers"] = false,
    ["worker_blacklist"] = false,
    ["dry_run"] = false,
    ["disable_batching"] = false
}
local function __promise(retryafter, f, count, ...)
    if count >= 24 then
        return false
    end
    count = count + 1
    retryafter = retryafter or 0.1
    local r = f(...)
    if not r then
        love.timer.sleep(retryafter)
        __promise(retryafter, f, count, ...)
    end
    return r
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


local headers = {
    ["accept"] = "application/json",
    ["apikey"] = "0000000000",
    ["Client-Agent"] = "unknown:0:unknown",
    ["Content-Type"] = "application/json"
}

function horde.Generate(prompt, callback, errcallback, extra, stop_sequence)
    local res = __promise(0.05, horde.__Generate, 0, prompt, callback, errcallback, extra, stop_sequence)
    if res then
        return res
    else
        errcallback("Timedout") 
    end
end
function horde.__Generate(prompt, callback, errcallback, extra, stop_sequence)
    local task = {}
    payload["prompt"] = prompt
    
    local stop_old = payload["params"]["stop_sequence"]
    
    if stop_sequence then
        local newstoppers = {}
        for _, var in ipairs(stop_old) do
            table.insert(newstoppers, var)
        end
        for _, var in ipairs(stop_sequence) do
            table.insert(newstoppers, var)
        end
        payload["params"]["stop_sequence"] = newstoppers
    end
    
    
    local code, body, headers = https.request("https://stablehorde.net/api/v2/generate/text/async", {method = "post", headers = headers, data = telelove.json.encode(payload)})
    payload["params"]["stop_sequence"] = stop_old
    if code == 202 then
        task.id = telelove.json.decode(body).id
        task.prompt = prompt
        task.callback = callback
        task.err = errcallback
        task.extra = extra
        
        task.finished = 0
        task.processing = 0
        task.restarted = 0
        task.waiting = 1
        task.done = 0
        task.faulted = false
        task.wait_time = 0
        task.queue_position = 0
        task.kudos = 0
        task.is_possible = true
        task.text = ""
        
        table.insert(tasks, task)
        tasks[task.id] = task
        return task
    else
        print()
        print("HORDE ERROR:")
        print(code)
        print(body)
        print()
        return false
    end
end
function horde.GenerateStoryBook(prompt, callback, errcallback, extra)
    local task = {}
    payload_storybook["params"]["prompt"] = prompt_storybook.."\n"..prompt.."\nOutput:"
    
    local code, body, headers = https.request("https://stablehorde.net/api/v2/generate/text/async", {method = "post", headers = headers, data = telelove.json.encode(payload_storybook)})
    if code == 202 then
        task.id = telelove.json.decode(body).id
        task.prompt = payload_storybook["params"]["prompt"]
        task.callback = callback
        task.extra = extra
        
        task.finished = 0
        task.processing = 0
        task.restarted = 0
        task.waiting = 1
        task.done = 0
        task.faulted = false
        task.wait_time = 0
        task.queue_position = 0
        task.kudos = 0
        task.is_possible = true
        task.text = ""
        
        table.insert(tasks, task)
        tasks[task.id] = task
        return task
    else
        print(code, body)
        return false
    end
end

function horde.CheckForKudos(prompt)
    
    
end


local function cut_unfinished_sentence(str)
    local f = str:find("#")
    if f then
        str = str:sub(0, f - 1)
    end
    
    return str
    --return str:sub(0, math.max(str:find("%.[^%.]*$") or 0, str:find("%?[^%?]*$") or 0, str:find("%![^%!]*$") or 0, str:find("%*[^%*]*$") or 0)):gsub("%\\", ""):sub(0, (str:find("%#") or 0)-1)
end
function horde.FetchUpdate(task)
    local code, body, headers = https.request("https://stablehorde.net/api/v2/generate/text/status/"..task.id)
    
    if code == 200 then
        local r = telelove.json.decode(body)
        
        task.finished         =   r.finished
        task.processing       =   r.processing
        task.restarted        =   r.restarted
        task.waiting          =   r.waiting
        task.done             =   r.done
        task.faulted          =   r.faulted
        task.wait_time        =   r.wait_time
        task.queue_position   =   r.queue_position
        task.kudos            =   r.kudos
        task.is_possible      =   r.is_possible
        task.text             =   r.generations and r.generations[1] and cut_unfinished_sentence(r.generations[1].text) or ""
        task.model            =   r.generations and r.generations[1] and r.generations[1].model or ""
        task.name             =   r.generations and r.generations[1] and r.generations[1].worker_name or ""
        if task.done then
            if task.callback then
                task:callback(task.text ~= "" and task.text or " ")
            end
            RemoveByValue(tasks, task)
        end
        if task.faulted then
            RemoveByValue(tasks, task)
            task:err("faulted")
        end
        if not task.is_possible then
            RemoveByValue(tasks, task)
            task:err("impossible")
        end
        return true
    end
end
local nextupdate
function horde.Update()
    if not nextupdate then nextupdate = love.timer.getTime() end
    
    if nextupdate <= love.timer.getTime() then
        for _, var in ipairs(tasks) do
            __promise(0.1, horde.FetchUpdate, 1, var)
        end
        
        nextupdate = love.timer.getTime() + 2
    end
end

return horde