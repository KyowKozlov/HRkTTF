-- ===================================
-- GOD MODE FEATURE MODULE
-- ===================================

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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local God = {
    enabled = false,
    connection = nil
}

local player = Players.LocalPlayer

function God.sendAdminRemote(action)
    local adminRemote = ReplicatedStorage:FindFirstChild("HNkAdminRemote")
    if not adminRemote then
        warn("[God]: Admin remote não encontrado")
        return
    end
    pcall(function() adminRemote:FireServer({action = action}) end)
end

function God.enable()
    if God.enabled then return end
    God.enabled = true
    
    print("[God Mode]: Ativado")
    
    God.connection = RunService.Heartbeat:Connect(function()
        local char = player.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.Health = hum.MaxHealth
                hum.BreakJointsOnDeath = false
            end)
        end
    end)
end

function God.disable()
    if not God.enabled then return end
    God.enabled = false
    
    if God.connection then
        pcall(function() God.connection:Disconnect() end)
        God.connection = nil
    end
    
    print("[God Mode]: Desativado")
end

function God.toggle()
    if God.enabled then
        God.disable()
    else
        God.enable()
    end
end

-- Listener
State.onChange("God", function(enabled)
    if enabled then
        God.enable()
    else
        God.disable()
    end
end)

return God
