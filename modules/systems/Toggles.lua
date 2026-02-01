-- =============================================
-- HNk TTF HUB v9.4.3 - TOGGLE SYSTEM MODULE
-- =============================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Toggles = {}
Toggles.__index = Toggles

function Toggles.new(state, remotes)
    local self = setmetatable({}, Toggles)
    self.state = state
    self.remotes = remotes
    self.connections = {}
    return self
end

function Toggles:HandleToggleLogic(name, enabled)
    if self.connections[name] then
        pcall(function() self.connections[name]:Disconnect() end)
        self.connections[name] = nil
    end

    if enabled then
        if name == "Train" then
            self:_startTrain()
        elseif name == "AntiAFK" then
            self:_startAntiAFK()
        elseif name == "AntiFall" then
            self:_enableAntiFallDetection()
        end
    else
        if name == "AntiFall" then
            self:_disableAntiFallDetection()
        end
    end
end

function Toggles:_startTrain()
    if not self.remotes.train or not self.remotes.statEffect or not self.remotes.boostEffect then
        warn("[Train]: Remotes not available")
        return
    end

    self.connections.Train = RunService.Heartbeat:Connect(function()
        pcall(function() self.remotes.train:InvokeServer(true) end)
        pcall(function() self.remotes.statEffect:InvokeServer() end)
        pcall(function() self.remotes.boostEffect:InvokeServer() end)
    end)
end

function Toggles:_startAntiAFK()
    local player = Players.LocalPlayer
    self.connections.AntiAFK = player.Idled:Connect(function()
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new(0, 0))
        end)
    end)
end

function Toggles:_enableAntiFallDetection()
    if self.connections._AntiFallChecker then return end
    
    local airtimeTracker = {}
    local lastY = {}
    local player = Players.LocalPlayer

    self.connections._AntiFallChecker = RunService.Heartbeat:Connect(function(dt)
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum then return end

        local onGround = false
        pcall(function() onGround = (hum.FloorMaterial ~= Enum.Material.Air) end)

        if not airtimeTracker[player] then airtimeTracker[player] = 0 end
        if onGround then
            airtimeTracker[player] = 0
        else
            airtimeTracker[player] = airtimeTracker[player] + dt
        end

        local velY = hrp.Velocity and hrp.Velocity.Y or 0
        if not lastY[player] then lastY[player] = velY end

        if airtimeTracker[player] > 2 and math.abs(velY) < 1 then
            pcall(function()
                if hum and hum.Health > 0 then
                    hum.Health = hum.MaxHealth
                end
                if hrp and hrp:IsA("BasePart") then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 60, hrp.Velocity.Z)
                end
            end)
            airtimeTracker[player] = 0
        end

        pcall(function()
            if hum:GetState() == Enum.HumanoidStateType.FallingDown then
                if hum and hum.Health > 0 then
                    hum.Health = hum.MaxHealth
                end
                if hrp and hrp:IsA("BasePart") then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
                end
            end
        end)

        lastY[player] = velY
    end)
end

function Toggles:_disableAntiFallDetection()
    if self.connections._AntiFallChecker then
        pcall(function() self.connections._AntiFallChecker:Disconnect() end)
        self.connections._AntiFallChecker = nil
    end
end

function Toggles:Disconnect(name)
    if self.connections[name] then
        pcall(function() self.connections[name]:Disconnect() end)
        self.connections[name] = nil
    end
end

function Toggles:DisconnectAll()
    for name, conn in pairs(self.connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    self.connections = {}
end

return Toggles
