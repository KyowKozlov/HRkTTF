-- =============================================
-- HNk TTF HUB v9.4.3 - ESP SYSTEM MODULE
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ESP = {}

function ESP:Initialize(state, helpers, colors)
    self.state = state
    self.helpers = helpers
    self.colors = colors
    self.players = {}
    self.powerCache = {}
    self.repCache = {}
    self.player = Players.LocalPlayer
end

function ESP:UpdateCache()
    if not self.state:Get("ESP") then return end

    -- Cache power do jogador
    local myPowerText = "0"
    local pGui = self.player:FindFirstChild("PlayerGui")
    if pGui then
        local targetLabel = pGui:FindFirstChild("MainGui")
            and pGui.MainGui:FindFirstChild("LeftFrame")
            and pGui.MainGui.LeftFrame:FindFirstChild("LeftButtonArea")
            and pGui.MainGui.LeftFrame.LeftButtonArea:FindFirstChild("PowerArea")
            and pGui.MainGui.LeftFrame.LeftButtonArea.PowerArea:FindFirstChild("PowerButton")
            and pGui.MainGui.LeftFrame.LeftButtonArea.PowerArea.PowerButton:FindFirstChild("PowerNum")
        if targetLabel and targetLabel:IsA("TextLabel") then
            myPowerText = targetLabel.Text
        end
    end
    self.powerCache[self.player] = myPowerText

    -- Cache power dos outros players
    for _, p in Players:GetPlayers() do
        if p ~= self.player then
            local val = self.helpers:FindEnemyPower(p)
            if val then
                self.powerCache[p] = self.helpers:FormatNumber(val)
            else
                self.powerCache[p] = "FAIL"
            end
        end
        local repVal = self.helpers:FindPlayerStat(p, "Respect")
        self.repCache[p] = repVal or 0
    end
end

function ESP:Render()
    if not self.state:Get("ESP") then
        for _, data in pairs(self.players) do
            if data.billboard then data.billboard:Destroy() end
        end
        self.players = {}
        return
    end

    for _, p in Players:GetPlayers() do
        if not p.Character or not p.Character:FindFirstChild("Head") then
            if self.players[p] and self.players[p].billboard then
                self.players[p].billboard:Destroy()
            end
            self.players[p] = nil
            continue
        end

        local data = self.players[p]
        if not data then
            self:_CreateBillboard(p)
            data = self.players[p]
        end

        self:_UpdateBillboard(p, data)
    end
end

function ESP:_CreateBillboard(p)
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

    self.players[p] = {billboard = bill, power = power, name = name}
end

function ESP:_UpdateBillboard(p, data)
    local playerReputation = self.repCache[p] or 0
    local nameColor = self.colors:GetReputationColor(self.player, p, playerReputation)

    if data.name then
        data.name.TextColor3 = nameColor
    end

    if data.power and self.powerCache[p] then
        local pText = self.powerCache[p]
        data.power.Text = pText
        if string.find(pText, "⚡") then
            data.power.TextStrokeTransparency = 0
            data.power.TextStrokeColor3 = Color3.new(0, 0, 0)
        else
            data.power.TextStrokeTransparency = 1
        end
    end
end

function ESP:Cleanup()
    for _, data in pairs(self.players) do
        if data.billboard then
            pcall(function() data.billboard:Destroy() end)
        end
    end
    self.players = {}
    self.powerCache = {}
    self.repCache = {}
end

return ESP
