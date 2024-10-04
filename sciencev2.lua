local pool = requests.CreatePool(2)

sciencev2 = {}

function sciencev2.onNewUser()
    pool:Request("http://localhost:5000/AppendNewUsers", {method = "get"})
end

function sciencev2.onTokensSpent(amount)
    pool:Request("http://localhost:5000/AppendTokensSpent", {method = "post", headers = {["Content-Type"] = "application/json"}, data = {TokensSpent = amount}})
end

function sciencev2.onNewChat()
    pool:Request("http://localhost:5000/AppendNewChats", {method = "get"})
end

function sciencev2.onExpenses(amount, origin)
    pool:Request("http://localhost:5000/AppendExpenses", {method = "post", headers = {["Content-Type"] = "application/json"}, data = {MoneySpent = amount, Origin = origin}})
end