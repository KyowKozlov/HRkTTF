-- =============================================
-- HNk TTF HUB v9.4.3 - PLAYER FEATURES MODULE
-- =============================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerFeatures = {}

function PlayerFeatures:Initialize(state, remotes)
    self.state = state
    self.remotes = remotes
    self.speedConnection = nil
    self.return self
end

function PlayerFeatures:Update()
    if not player.Character then return end
    
    local hum = player.Character:FindFirstChild("Humanoid")
    if not hum then return end

    -- God Mode
    if self.state:Get("God") then
        hum.Health = hum.MaxHealth
        hum.BreakJointsOnDeath = false
    end

    -- Speed e Jump
    local walkSpeed = self.state:Get("Speed") and 120 or 16
    local jumpPower = self.state:Get("Jump") and 150 or 50

    if hum.WalkSpeed ~= walkSpeed then
        hum.WalkSpeed = walkSpeed
    end
    if hum.JumpPower ~= jumpPower then
        hum.JumpPower = jumpPower
    end

    -- Anti-Fall BreakJointsOnDeath
    if not self.state:Get("God") then
        local shouldBreak = not self.state:Get("AntiFall")
        if hum.BreakJointsOnDeath ~= shouldBreak then
            hum.BreakJointsOnDeath = shouldBreak
        end
    end

    -- Train ou Speed - enviar remote
    if (self.state:Get("Train") or self.state:Get("Speed")) and self.remotes.speedRemote then
        pcall(function() self.remotes.speedRemote:FireServer(9999) end)
    end
end

return PlayerFeatures
