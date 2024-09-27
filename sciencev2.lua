local pool = requests.CreatePool(2)

sciencev2 = {}

function sciencev2.onNewUser()
    pool:Request("https://localhost:5000/AppendNewUsers")
end

function sciencev2.onTokensSpent(amount)
    pool:Request("https://localhost:5000/AppendTokensSpent", {method = "post", headers = {["Content-Type"] = "application/json"}, data = {TokensSpent = amount}})
end

function sciencev2.onNewChat()
    pool:Request("https://localhost:5000/AppendNewChats")
end