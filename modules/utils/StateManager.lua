-- =============================================
-- HNk TTF HUB v9.4.3 - STATE MANAGER MODULE
-- =============================================

local StateManager = {}
StateManager.__index = StateManager

function StateManager.new(defaults)
    local self = setmetatable({}, StateManager)
    self.state = {}
    for k, v in pairs(defaults) do
        self.state[k] = v
    end
    self.callbacks = {}
    return self
end

function StateManager:Get(key)
    return self.state[key]
end

function StateManager:Set(key, value)
    local oldValue = self.state[key]
    if oldValue ~= value then
        self.state[key] = value
        self:_notify(key, value, oldValue)
    end
end

function StateManager:GetAll()
    return self.state
end

function StateManager:OnChange(key, callback)
    if not self.callbacks[key] then
        self.callbacks[key] = {}
    end
    table.insert(self.callbacks[key], callback)
end

function StateManager:_notify(key, newValue, oldValue)
    if self.callbacks[key] then
        for _, callback in ipairs(self.callbacks[key]) do
            pcall(function() callback(newValue, oldValue, key) end)
        end
    end
end

return StateManager
