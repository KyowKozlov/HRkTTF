-- ===================================
-- UTILS MODULE - Funções Utilitárias
-- ===================================

-- Carrega Config se disponível via loadstring, senão tenta via require
local Config
if getgenv().HNkConfig then
    Config = getgenv().HNkConfig
else
    Config = require(script.Parent:WaitForChild("config"))
end

local HttpService = game:GetService("HttpService")

local Utils = {}

function Utils.try(f, ...)
    local success, err = pcall(f, ...)
    if not success then warn("[HNk ERROR]:", err) end
end

function Utils.getNumericValue(inst)
    if inst and (inst:IsA("IntValue") or inst:IsA("NumberValue")) then
        return inst.Value
    elseif inst and inst:IsA("StringValue") then
        return tonumber(inst.Value)
    end
    return nil
end

function Utils.findPlayerStat(targetPlayer, statName)
    local containers = {targetPlayer:FindFirstChild("AttrConfig"), targetPlayer:FindFirstChild("leaderstats")}
    for _, folder in ipairs(containers) do
        if folder then
            for _, child in folder:GetChildren() do
                if child.Name == statName then
                    return Utils.getNumericValue(child)
                end
            end
        end
    end
    return nil
end

function Utils.findEnemyPower(targetPlayer)
    local highestValue = 0
    local currentMaxHealth = 100
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
        currentMaxHealth = targetPlayer.Character.Humanoid.MaxHealth
    end
    local containers = {targetPlayer:FindFirstChild("AttrConfig"), targetPlayer:FindFirstChild("leaderstats")}
    for _, folder in ipairs(containers) do
        if folder then
            for _, child in folder:GetChildren() do
                local val = Utils.getNumericValue(child)
                if val and val > currentMaxHealth and val > highestValue then highestValue = val end
            end
        end
    end
    return highestValue > 0 and highestValue or nil
end

function Utils.getReputationColor(targetPlayer, reputation, player)
    local MIN_REP_GRADIENT = 5000
    local MAX_REP_GRADIENT = 1000000
    local QI_REP_THRESHOLD = 1e18

    local dn = ""
    if targetPlayer and targetPlayer.DisplayName then dn = targetPlayer.DisplayName:upper() end

    if targetPlayer == player or (dn and string.find(dn, "KOZLOV")) then
        return Color3.fromRGB(0, 150, 0)
    end

    local repNum = reputation
    if type(repNum) ~= "number" then
        repNum = tonumber(repNum)
    end

    if repNum and repNum >= QI_REP_THRESHOLD then
        return Color3.fromRGB(255, 215, 0)
    end

    if repNum and repNum >= MIN_REP_GRADIENT then
        local ratio = math.min(1, (repNum - MIN_REP_GRADIENT) / (MAX_REP_GRADIENT - MIN_REP_GRADIENT))
        local r = 255
        local g = 150 * (1 - ratio)
        local b = 200 + 55 * ratio
        return Color3.fromRGB(r, g, b)
    else
        return Color3.new(1, 1, 1)
    end
end

function Utils.formatNumber(num)
    if type(num) ~= "number" then return tostring(num) end
    if num < 1000 then return tostring(math.floor(num)) end
    local exp = math.log10(num)
    local order = math.floor(exp / 3)
    if order > 0 then
        if order <= #Config.UNITS then
            local unit = Config.UNITS[order]
            local scaled = num / (10 ^ (order * 3))
            local formatted = string.format("%.2f %s", scaled, unit)
            if order >= 13 then return "⚡ " .. formatted end
            return formatted
        else
            return "⚡ " .. string.format("%.2fe%.0f", num / (10 ^ exp), exp)
        end
    end
    return tostring(num)
end

-- PERSISTENCE
function Utils.saveConfig(data)
    local isFileSupport = (pcall(function() readfile() end) and pcall(function() writefile() end)) or false
    if isFileSupport then
        local encoded = HttpService:JSONEncode(data)
        writefile(Config.FILE_NAME, encoded)
    end
end

function Utils.loadConfig()
    local isFileSupport = (pcall(function() readfile() end) and pcall(function() writefile() end)) or false
    if isFileSupport and readfile(Config.FILE_NAME) then
        local data = readfile(Config.FILE_NAME)
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, data)
        if success and type(decoded) == "table" then
            return decoded
        end
    end
    return nil
end

return Utils
