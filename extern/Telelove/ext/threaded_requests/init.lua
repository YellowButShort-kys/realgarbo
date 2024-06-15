local t_requests = {}
local main_pool
local cwd = ...
local pool_base = {}
local pool_hub = {}

function t_requests.CreateMainPool(n_threads, retryafter, attempts)
    main_pool = t_requests.CreatePool(n_threads, retryafter, attempts)
end
function t_requests.CreatePool(n_threads, retryafter, attempts)
    local name = "ThreadedRequestsPool:"..tostring(#pool_hub)
    local pool = setmetatable({}, {__index = pool_base, __tostring = name})
    pool.threads = {}
    pool.tasks = {}
    for x = 1, n_threads do
        local t = love.thread.newThread(cwd:gsub("%.", "/") .. "/threadcode.lua")
        t:start(tostring(#pool_hub)..":"..tostring(x), cwd, retryafter or 0.05, attempts or 24)
        table.insert(pool.threads, {
            thread = t,
            free = true,
            transmiter = love.thread.getChannel("threaded_requests_" .. tostring(#pool_hub)..":"..tostring(x) .. "_in"),
            receiver = love.thread.getChannel("threaded_requests_" .. tostring(#pool_hub)..":"..tostring(x) .. "_out"),
        })
    end
    table.insert(pool_hub, pool)
    return pool
end

function t_requests.Request(link, data, callback, extra)
    assert(main_pool, "Attemped request to an uninitialized main pool. Did you forget to create a main pool?")
    main_pool:Request(link, data, callback, extra)
end
function t_requests.Update()
    if main_pool then
        main_pool:Update()
    end
    for _, var in ipairs(pool_hub) do
        var:Update()
    end
end

function pool_base:Request(link, data, callback, extra)
    for _, var in ipairs(self.threads) do
        if var.free then
            var.transmiter:push({link = link, data = data})
            var.free = false
            var.__callback = callback
            var.__extra = extra
            return
        end
    end
    table.insert(self.tasks, {link = link, data = data, callback = callback, extra = extra})
end
function pool_base:Update()
    for _, var in ipairs(self.threads) do
        if not var.free then
            local result = var.receiver:pop()
            if result then
                if not result.success then
                    error("There was an error during a request! Error code: "..result.errcode.."\n"..result.result)
                end
                
                var.__callback(result.success, result.errcode, result.result, var.__extra)
                if #self.tasks == 0 then
                    var.free = true
                    var.__callback = nil
                    var.__extra = nil
                else
                    local t = table.remove(self.tasks, 1)
                    var.transmiter:push({link = t.link, data = t.data})
                    var.free = false
                    var.__callback = t.callback
                    var.__extra = t.extra
                end
            end
        end
    end
end

return t_requests