-- ===================================
-- SPEED & JUMP FEATURE MODULE
-- ===================================

local State
if getgenv().HNkState then
    State = getgenv().HNkState
else
    State = require(script.Parent.Parent:WaitForChild("core"):WaitForChild("state"))
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = {
    enabled = false,
    connection = nil
}

local player = Players.LocalPlayer

function Player.enable()
    if Player.enabled then return end
    Player.enabled = true
    
    print("[Player]: Ativado")
    
    Player.connection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("Humanoid") then return end
        
        local hum = player.Character.Humanoid
        
        -- Speed
        hum.WalkSpeed = State.get("Speed") and 120 or 16
        
        -- Jump
        hum.JumpPower = State.get("Jump") and 150 or 50
        
        -- BreakJointsOnDeath
        if State.get("God") then
            hum.BreakJointsOnDeath = false
        else
            if State.get("AntiFall") then
                hum.BreakJointsOnDeath = false
            else
                hum.BreakJointsOnDeath = true
            end
        end
    end)
end

function Player.disable()
    if not Player.enabled then return end
    Player.enabled = false
    
    if Player.connection then
        pcall(function() Player.connection:Disconnect() end)
        Player.connection = nil
    end
    
    print("[Player]: Desativado")
end

-- Listeners para mudanças
State.onChange("Speed", function() end) -- Conectado ao heartbeat
State.onChange("Jump", function() end)  -- Conectado ao heartbeat

Player.enable()

return Player
