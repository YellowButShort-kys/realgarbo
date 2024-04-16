local t_requests = {}
local threads = {}
local tasks = {}
local cwd = ...

function t_requests.Init(n_threads, retryafter, attempts)
    for x = 1, n_threads do
        local t = love.thread.newThread(cwd .. "/threadcode.lua")
        t:start(x, cwd, retryafter or 0.05, attempts or 24)
        table.insert(threads, {
            thread = t,
            free = true,
            transmiter = love.thread.getChannel("threaded_requests_" .. x .. "_in"),
            receiver = love.thread.getChannel("threaded_requests_" .. x .. "_out"),
        })
    end
end

function t_requests.Request(link, data, callback, extra)
    for _, var in ipairs(threads) do
        if var.free then
            var.transmiter:push({link = link, data = data})
            var.free = false
            var.__callback = callback
            var.__extra = extra
            return
        end
    end
    table.insert(tasks, {link = link, data = data, callback = callback, extra = extra})
end
function t_requests.Update()
    for _, var in ipairs(threads) do
        if not var.free then
            local result = var.receiver:pop()
            if result then
                if not result.success then
                    error("There was an error during a request! Error code: "..result.errcode.."\n"..result.result)
                end
                
                var.__callback(result.success, result.errcode, result.result, var.__extra)
                if #tasks == 0 then
                    var.free = true
                    var.__callback = nil
                    var.__extra = nil
                else
                    local t = table.remove(tasks, 1)
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