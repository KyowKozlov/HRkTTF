-- ESP feature rewritten from the provided v9.4.3 script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local State
if getgenv().HNkState then
    State = getgenv().HNkState
else
    State = require(script.Parent.Parent:WaitForChild("core"):WaitForChild("state"))
end

local player = Players.LocalPlayer

local units = {
    "k", "M", "B", "T", "Qa", "Qi", "Aa", "Ab", "Ac", "Ad",
    "Ae", "Af", "Ag", "Ah", "Ai", "Aj", "Ak", "Al", "Am", "An", "Ao", "Ap"
}

local multipliers = {}
do
    for i, u in ipairs(units) do
        multipliers[u] = 10 ^ (i * 3)
        multipliers[u:upper()] = multipliers[u]
        multipliers[u:lower()] = multipliers[u]
    end
    multipliers["K"] = multipliers["k"]
end

local TARGET_REP_THRESHOLD = 1e18

local function getNumericValue(inst)
    if inst and (inst:IsA("IntValue") or inst:IsA("NumberValue")) then
        return inst.Value
    elseif inst and inst:IsA("StringValue") then
        return tonumber(inst.Value)
    end
    return nil
end

local function findPlayerStat(targetPlayer, statName)
    local containers = {targetPlayer:FindFirstChild("AttrConfig"), targetPlayer:FindFirstChild("leaderstats")}
    for _, folder in ipairs(containers) do
        if folder then
            for _, child in folder:GetChildren() do
                if child.Name == statName then
                    return getNumericValue(child)
                end
            end
        end
    end
    return nil
end

local function findEnemyPower(targetPlayer)
    local highestValue = 0
    local currentMaxHealth = 100
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
        currentMaxHealth = targetPlayer.Character.Humanoid.MaxHealth
    end
    local containers = {targetPlayer:FindFirstChild("AttrConfig"), targetPlayer:FindFirstChild("leaderstats")}
    for _, folder in ipairs(containers) do
        if folder then
            for _, child in folder:GetChildren() do
                local val = getNumericValue(child)
                if val and val > currentMaxHealth and val > highestValue then highestValue = val end
            end
        end
    end
    return highestValue > 0 and highestValue or nil
end

local function formatNumber(num)
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

local function parseHumanNumber(val)
    if val == nil then return nil end
    if type(val) == "number" then return val end
    local s = tostring(val)
    s = s:gsub("⚡", ""):gsub(",", ""):match("^%s*(.-)%s*$") or s

    local n = tonumber(s)
    if n then return n end

    local num, unit = s:match("([%-%d%.]+)%s*([%a]+)")
    if num and unit then
        local mult = multipliers[unit] or multipliers[unit:upper()] or multipliers[unit:lower()]
        if mult then
            local nf = tonumber(num)
            if nf then return nf * mult end
        end
    end

    local unit2, num2 = s:match("([%a]+)%s*([%-%d%.]+)")
    if unit2 and num2 then
        local mult = multipliers[unit2] or multipliers[unit2:upper()] or multipliers[unit2:lower()]
        if mult then
            local nf = tonumber(num2)
            if nf then return nf * mult end
        end
    end

    local onlyDigits = s:match("([%-%d%.]+)")
    if onlyDigits then return tonumber(onlyDigits) end

    return nil
end

local function getRespectValue(targetPlayer)
    if not targetPlayer then return 0 end
    local attr = targetPlayer:GetAttribute("Respect")
    if attr ~= nil then
        if type(attr) == "number" then return attr end
        local n = parseHumanNumber(attr)
        if n then return n end
        return tonumber(attr) or 0
    end

    local containers = { targetPlayer:FindFirstChild("AttrConfig"), targetPlayer:FindFirstChild("leaderstats") }
    for _, folder in ipairs(containers) do
        if folder then
            local stat = folder:FindFirstChild("Respect")
            if stat then
                if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                    return stat.Value
                elseif stat:IsA("StringValue") then
                    local parsed = parseHumanNumber(stat.Value)
                    if parsed then return parsed end
                    return tonumber(stat.Value) or 0
                end
            end
        end
    end

    for _, descendant in pairs(targetPlayer:GetDescendants()) do
        if descendant.Name:lower():find("respect") then
            if descendant:IsA("IntValue") or descendant:IsA("NumberValue") then
                return descendant.Value
            elseif descendant:IsA("StringValue") then
                local parsed = parseHumanNumber(descendant.Value)
                if parsed then return parsed end
                return tonumber(descendant.Value) or 0
            end
        end
    end

    return 0
end

local function getReputationColor(targetPlayer, reputation)
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

local ESP = {
    enabled = false,
    players = {},
    powerCache = {},
    repCache = {}
}

function ESP.enable()
    if ESP.enabled then return end
    ESP.enabled = true

    -- Cache updater
    ESP.cacheThread = task.spawn(function()
        while ESP.enabled and task.wait(0.5) do
            local myPowerText = "0"
            local pGui = player:FindFirstChild("PlayerGui")
            if pGui then
                local targetLabel = pGui:FindFirstChild("MainGui")
                    and pGui.MainGui:FindFirstChild("LeftFrame")
                    and pGui.MainGui.LeftFrame:FindFirstChild("LeftButtonArea")
                    and pGui.MainGui.LeftFrame.LeftButtonArea:FindFirstChild("PowerArea")
                    and pGui.MainGui.LeftFrame.LeftButtonArea.PowerArea:FindFirstChild("PowerButton")
                    and pGui.MainGui.LeftFrame.LeftButtonArea.PowerArea.PowerButton:FindFirstChild("PowerNum")
                if targetLabel and targetLabel:IsA("TextLabel") then myPowerText = targetLabel.Text end
            end
            ESP.powerCache[player] = myPowerText

            for _, p in Players:GetPlayers() do
                if p ~= player then
                    local val = findEnemyPower(p)
                    if val then ESP.powerCache[p] = formatNumber(val) else ESP.powerCache[p] = "?" end
                end
                local repVal = getRespectValue(p)
                ESP.repCache[p] = repVal or 0
            end
        end
    end)

    -- Renderer
    ESP.renderConn = RunService.Heartbeat:Connect(function()
        if not ESP.enabled then return end

        local hue = (tick() % 5) / 5
        local rgbColor = Color3.fromHSV(hue, 1, 1)

        for _, p in Players:GetPlayers() do
            if p == player and State.get("Invisible") then
                if ESP.players[p] and ESP.players[p].billboard then ESP.players[p].billboard:Destroy() end
                ESP.players[p] = nil
                continue
            end

            if not p.Character or not p.Character:FindFirstChild("Head") then
                if ESP.players[p] and ESP.players[p].billboard then ESP.players[p].billboard:Destroy() end
                ESP.players[p] = nil
                continue
            end

            local data = ESP.players[p]
            if not data then
                local head = p.Character.Head
                local bill = Instance.new("BillboardGui", head)
                bill.Name = "HNkESP"
                bill.Size = UDim2.new(0, 200, 0, 70)
                bill.StudsOffset = Vector3.new(0, 3, 0)
                bill.AlwaysOnTop = true

                local name = Instance.new("TextLabel", bill)
                name.Size = UDim2.new(1, 0, 0.5, 0)
                name.Position = UDim2.new(0, 0, 0, 0)
                name.BackgroundTransparency = 1
                name.Text = p.DisplayName
                name.TextColor3 = Color3.new(1, 1, 1)
                name.Font = Enum.Font.GothamBold
                name.TextSize = 16
                name.TextStrokeTransparency = 0
                name.TextStrokeColor3 = Color3.new(0, 0, 0)

                local power = Instance.new("TextLabel", bill)
                power.Size = UDim2.new(1, 0, 0.5, 0)
                power.Position = UDim2.new(0, 0, 0.5, 0)
                power.BackgroundTransparency = 1
                power.Text = "0"
                power.TextColor3 = Color3.fromRGB(255, 100, 100)
                power.Font = Enum.Font.GothamBold
                power.TextSize = 18

                ESP.players[p] = {billboard = bill, power = power, name = name}
                data = ESP.players[p]
            end

            pcall(function()
                local playerReputation = ESP.repCache[p] or 0
                local nameColor = getReputationColor(p, playerReputation)

                data.name.Visible = true
                data.name.Text = p.DisplayName
                data.name.TextColor3 = nameColor
                data.power.Text = ESP.powerCache[p] or "?"
                data.power.TextColor3 = Color3.fromRGB(255, 100, 100)

                if data and data.power and ESP.powerCache[p] then
                    local pText = ESP.powerCache[p]
                    data.power.Text = pText
                    if playerReputation and playerReputation >= TARGET_REP_THRESHOLD then
                        data.power.TextColor3 = rgbColor
                    else
                        data.power.TextColor3 = Color3.fromRGB(255,100,100)
                    end
                    if string.find(pText, "⚡") then data.power.TextStrokeTransparency = 0; data.power.TextStrokeColor3 = Color3.new(0, 0, 0) else data.power.TextStrokeTransparency = 1 end
                end
            end)
        end
    end)
end

function ESP.disable()
    if not ESP.enabled then return end
    ESP.enabled = false
    if ESP.renderConn then pcall(function() ESP.renderConn:Disconnect() end) ESP.renderConn = nil end
    if ESP.cacheThread then ESP.cacheThread = nil end
    for _, data in pairs(ESP.players) do if data.billboard then pcall(function() data.billboard:Destroy() end) end end
    ESP.players = {}
end

function ESP.toggle()
    if ESP.enabled then ESP.disable() else ESP.enable() end
end

State.onChange("ESP", function(enabled)
    if enabled then ESP.enable() else ESP.disable() end
end)

return ESP
