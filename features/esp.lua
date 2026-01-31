-- ===================================
-- ESP FEATURE MODULE
-- ===================================

local Config
if getgenv().HNkConfig then
    Config = getgenv().HNkConfig
else
    Config = require(script.Parent.Parent:WaitForChild("core"):WaitForChild("config"))
end

local State
if getgenv().HNkState then
    State = getgenv().HNkState
else
    State = require(script.Parent.Parent:WaitForChild("core"):WaitForChild("state"))
end

local Utils
if getgenv().HNkUtils then
    Utils = getgenv().HNkUtils
else
    Utils = require(script.Parent.Parent:WaitForChild("core"):WaitForChild("utils"))
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ESP = {
    enabled = false,
    players = {},
    powerCache = {},
    repCache = {}
}

local player = Players.LocalPlayer

function ESP.enable()
    if ESP.enabled then return end
    ESP.enabled = true
    
    print("[ESP]: Ativado")
    
    -- Thread para atualizar cache
    task.spawn(function()
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
                    local val = Utils.findEnemyPower(p)
                    if val then ESP.powerCache[p] = Utils.formatNumber(val) else ESP.powerCache[p] = "FAIL" end
                end
                local repVal = Utils.findPlayerStat(p, "Respect")
                ESP.repCache[p] = repVal or 0
            end
        end
    end)
    
    -- Renderização
    ESP.connection = RunService.Heartbeat:Connect(function()
        if not ESP.enabled then return end
        
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

            local playerReputation = ESP.repCache[p] or 0
            local nameColor = Utils.getReputationColor(p, playerReputation, player)

            if data.name then
                data.name.TextColor3 = nameColor
            end

            if data and data.power and ESP.powerCache[p] then
                local pText = ESP.powerCache[p]
                data.power.Text = pText
                if string.find(pText, "⚡") then
                    data.power.TextStrokeTransparency = 0
                    data.power.TextStrokeColor3 = Color3.new(0, 0, 0)
                else
                    data.power.TextStrokeTransparency = 1
                end
            end
        end
    end)
end

function ESP.disable()
    if not ESP.enabled then return end
    ESP.enabled = false
    
    if ESP.connection then
        pcall(function() ESP.connection:Disconnect() end)
        ESP.connection = nil
    end
    
    for _, data in pairs(ESP.players) do
        if data.billboard then data.billboard:Destroy() end
    end
    ESP.players = {}
    
    print("[ESP]: Desativado")
end

function ESP.toggle()
    if ESP.enabled then
        ESP.disable()
    else
        ESP.enable()
    end
end

-- Listener para mudanças de estado
State.onChange("ESP", function(enabled)
    if enabled then
        ESP.enable()
    else
        ESP.disable()
    end
end)

return ESP
