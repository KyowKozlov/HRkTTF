-- =============================================
-- HNk TTF HUB v9.4.3 - HELPERS MODULE
-- =============================================

local Helpers = {}

function Helpers:Try(f, ...)
    local success, err = pcall(f, ...)
    if not success then warn("[HNkTTF ERROR]:", err) end
end

function Helpers:GetNumericValue(inst)
    if inst and (inst:IsA("IntValue") or inst:IsA("NumberValue")) then
        return inst.Value
    elseif inst and inst:IsA("StringValue") then
        return tonumber(inst.Value)
    end
    return nil
end

function Helpers:FindPlayerStat(targetPlayer, statName)
    local containers = {targetPlayer:FindFirstChild("AttrConfig"), targetPlayer:FindFirstChild("leaderstats")}
    for _, folder in ipairs(containers) do
        if folder then
            for _, child in folder:GetChildren() do
                if child.Name == statName then
                    return self:GetNumericValue(child)
                end
            end
        end
    end
    return nil
end

function Helpers:FindEnemyPower(targetPlayer)
    local highestValue = 0
    local currentMaxHealth = 100
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
        currentMaxHealth = targetPlayer.Character.Humanoid.MaxHealth
    end
    local containers = {targetPlayer:FindFirstChild("AttrConfig"), targetPlayer:FindFirstChild("leaderstats")}
    for _, folder in ipairs(containers) do
        if folder then
            for _, child in folder:GetChildren() do
                local val = self:GetNumericValue(child)
                if val and val > currentMaxHealth and val > highestValue then highestValue = val end
            end
        end
    end
    return highestValue > 0 and highestValue or nil
end

function Helpers:FormatNumber(num)
    local units = {"k", "M", "B", "T", "Qa", "Qi", "Aa", "Ab", "Ac", "Ad", "Ae", "Af", "Ag", "Ah", "Ai", "Aj", "Ak", "Al", "Am", "An", "Ao", "Ap"}
    
    if type(num) ~= "number" then return tostring(num) end
    if num < 1000 then return tostring(math.floor(num)) end
    local exp = math.log10(num)
    local order = math.floor(exp / 3)
    if order > 0 then
        if order <= #units then
            local unit = units[order]
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

function Helpers:GetDisplayLabelText(module)
    if not module then return "" end
    local icon = module.icon or ""
    local txt = module.text or ""
    if icon == "" then return txt end
    if string.find(txt, icon, 1, true) then
        return txt
    end
    return icon .. " " .. txt
end

return Helpers
