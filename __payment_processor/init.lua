local radom = {}

local cwd = ...
local ansicolors = require(cwd .. ".ansicolors")
local requests = require(cwd .. ".threaded_requests")
local pool = requests.CreatePool(3)

local products = {}
local products_base = require(cwd .. ".base")
local TOKEN

local monitored = {}

function radom.SetToken(token)
    TOKEN = token
end

local function Callback_ListProducts(success, errcode, result, extra)
    if success then
        for _, var in ipairs(result) do
            table.insert(products, setmetatable(var, products_base))
        end
        print(ansicolors("%{bright yellow}[RADON]%{reset}: Loaded ".. tostring(#result) .. " products"))
    else
        error("There was an error trying loading products:" .. "\n  " .. result)
    end
end
function radom.ListProducts(include_archived)
    assert(TOKEN, "Token was not provided")
    pool:Request("https://api.radom.com/products", {method = "get", headers = {["Content-Type"] = "application/json", ["Authorization"] = TOKEN}}, Callback_ListProducts)
end
function radom.GetProducts()
    return products
end

local function Callback_CreateCheckoutSession(success, errcode, result, extra)
    if success then
        extra.onStart(result.checkoutSessionUrl, result.checkoutSessionId)
        radom.StartMonitoringCheckout(result.checkoutSessionId, extra.onPayment)
        print(ansicolors("%{bright yellow}[RADON]%{reset}: Created a new checkout session"))
    else
        error("There was an error trying to create a checkout session:" .. "\n  " .. result)
    end
end
function radom.CreateCheckoutSession(product, onStart, onPayment, successUrl)
    assert(TOKEN, "Token was not provided")
    assert(product, "Product was not provided")
    assert(onStart, "onStart callback was not provided")
    assert(onPayment, "onPayment callback was not provided")
    pool:Request("https://api.radom.com/checkout_session", {method = "post", headers = {["Content-Type"] = "application/json", ["Authorization"] = TOKEN}, data = {
        ["successUrl"] = successUrl or "https://google.com",
        ["lineItems"] = {
            ["productId"] = product:GetID()
        },
        ["expiresAt"] = os.time() + 1800 --half an hour
    }}, {onStart = onStart, onPayment = onPayment}, Callback_CreateCheckoutSession)
end

function radom.StartMonitoringCheckout(id, callback)
    table.insert(monitored, {id, callback})
end

local function CheckSuccess(success, errcode, result, extra)
    if success then
        if result.sessionStatus == "success" then
            print(ansicolors("%{bright yellow}[RADON]%{reset}: Payment received!"))
            extra[2](extra[1])
        elseif result.sessionStatus == "cancelled" or result.sessionStatus == "expired" then
            for i, var in ipairs(monitored) do
                if var[1] == extra[1] then
                    table.remove(monitored, i)
                end
            end
        end
    else
        error("There was an error trying to check a session:" .. "\n  " .. result) 
    end
end
function radom.CheckCheckoutSession(session)
    assert(TOKEN, "Token was not provided")
    assert(session, "Session was not provided")
    pool:Request("https://api.radom.com/checkout_session/"..session[1], {method = "get", headers = {["Content-Type"] = "application/json", ["Authorization"] = TOKEN}}, CheckSuccess)
end

local nextcheck = 0
function radom.Update()
    pool:Update()
    
    if love.timer.getTime() > nextcheck then
        for i = #monitored, 1, -1 do
            radom.CheckCheckoutSession(monitored[i])
        end
        nextcheck = love.timer.getTime() + 30
    end
end

return radom

