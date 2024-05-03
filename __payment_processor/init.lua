local radom = {}

local cwd = ...
local ansicolors = require(cwd .. ".ansicolors")
local requests = require(cwd .. ".threaded_requests")
local pool = requests.CreatePool(3)

local products = {}
local products_base = require(cwd .. ".base")
local TOKEN
local awaitforproducts = false

local monitored = {}

function radom.SetToken(token)
    TOKEN = token
end

local function Callback_ListProducts(success, errcode, result, extra)
    print("CallbackListProducts")
    awaitforproducts = false
    if success then
        for _, var in ipairs(result) do
            table.insert(products, setmetatable(var, products_base))
        end
        print(ansicolors("%{bright yellow}[RADON]%{reset}: Loaded ".. tostring(#result) .. " products"))
    else
        error("There was an error trying loading products:" .. "\n  " .. result)
    end
    print("Done")
end
function radom.ListProducts(include_archived)
    print("ListProducts")
    assert(TOKEN, "Token was not provided")
    pool:Request("https://api.radom.com/products", {method = "get", headers = {["Content-Type"] = "application/json", ["Authorization"] = TOKEN}}, Callback_ListProducts)
    awaitforproducts = true
    while awaitforproducts do
        love.timer.sleep(0.05)
        pool:Update()
    end
    print("Done")
end
function radom.GetProducts()
    return products
end

local function Callback_CreateCheckoutSession(success, errcode, result, extra)
    print("Callback_CreateCheckoutSession")
    if success then
        extra.onStart(result.checkoutSessionUrl, result.checkoutSessionId)
        radom.StartMonitoringCheckout(result.checkoutSessionId, extra.onPayment)
        print(ansicolors("%{bright yellow}[RADON]%{reset}: Created a new checkout session"))
    else
        error("There was an error trying to create a checkout session:" .. "\n  " .. result)
    end
    print("Done")
end
function radom.CreateCheckoutSession(product, onStart, onPayment, successUrl)
    print("CreateCheckoutSession")
    assert(TOKEN, "Token was not provided")
    assert(product, "Product was not provided")
    assert(onStart, "onStart callback was not provided")
    assert(onPayment, "onPayment callback was not provided")
    pool:Request("https://api.radom.com/checkout_session", {method = "post", headers = {["Content-Type"] = "application/json", ["Authorization"] = TOKEN}, data = {
        ["successUrl"] = successUrl or "https://google.com",
        ["lineItems"] = {
            {["productId"] = product:GetID()}
        },
        ["gateway"] = {
            ["managed"] = {
                ["methods"] = {
                    {["network"] = "Bitcoin"},
                    {["network"] = "Tron", ["token"] = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t"}
                }
            }
        },
        ["expiresAt"] = os.time() + 3600 --hour?
    }}, Callback_CreateCheckoutSession, {onStart = onStart, onPayment = onPayment})
    print("Done")
end

function radom.StartMonitoringCheckout(id, callback)
    table.insert(monitored, {id, callback})
end

local function CheckSuccess(success, errcode, result, extra)
    print("CheckSuccess")
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
    print("Done")
end
function radom.CheckCheckoutSession(session)
    print("CheckCheckoutSession")
    assert(TOKEN, "Token was not provided")
    assert(session, "Session was not provided")
    pool:Request("https://api.radom.com/checkout_session/"..session[1], {method = "get", headers = {["Content-Type"] = "application/json", ["Authorization"] = TOKEN}}, CheckSuccess)
    print("Done")
end

local nextcheck = 0
function radom.Update()
    print("RADOM Update")
    pool:Update()
    print("Pool Update DONE")
    
    if love.timer.getTime() > nextcheck then
        for i = #monitored, 1, -1 do
            radom.CheckCheckoutSession(monitored[i])
        end
        nextcheck = love.timer.getTime() + 30
    end
    print("RADOM Update DONE")
end

return radom

