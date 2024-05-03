local base = {}
base.id = nil
base.name = nil
base.description = nil
base.chargingIntervalSeconds = nil
base.price = nil
base.isArchived = nil

function base:GetID()
    return self.id
end
function base:GetName()
    return self.name
end
function base:GetDescription()
    return self.description
end
function base:GetChargingInterval()
    return self.chargingIntervalSeconds
end
function base:GetPrice()
    return self.price
end
function base:IsArchived()
    return self.isArchived
end

return {__index = base}