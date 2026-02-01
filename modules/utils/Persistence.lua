-- =============================================
-- HNk TTF HUB v9.4.3 - PERSISTENCE MODULE
-- =============================================

local HttpService = game:GetService("HttpService")
local Persistence = {}

function Persistence:IsFileSupported()
    return (pcall(function() readfile() end) and pcall(function() writefile() end)) or false
end

function Persistence:SaveConfig(fileName, data)
    if self:IsFileSupported() then
        local jsonData = HttpService:JSONEncode(data)
        pcall(function() writefile(fileName, jsonData) end)
    end
end

function Persistence:LoadConfig(fileName, defaults)
    if not self:IsFileSupported() then
        print("[HNk Config]: File support unavailable, using defaults")
        return defaults
    end

    local success, fileContent = pcall(function() return readfile(fileName) end)
    if not success or not fileContent then
        print("[HNk Config]: Configuration file not found, using defaults")
        return defaults
    end

    local success2, decoded = pcall(function() return HttpService:JSONDecode(fileContent) end)
    if not success2 or type(decoded) ~= "table" then
        warn("[HNk Config]: Failed to decode configurations, using defaults")
        return defaults
    end

    -- Validar e mergear com defaults
    local merged = {}
    for k, v in pairs(defaults) do
        merged[k] = (decoded[k] ~= nil and type(decoded[k]) == type(v)) and decoded[k] or v
    end

    print("[HNk Config]: Configurations loaded successfully. Theme: " .. (merged.CurrentTheme or "unknown"))
    return merged
end

return Persistence
