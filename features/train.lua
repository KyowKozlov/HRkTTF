-- ===================================
-- TRAIN FEATURE MODULE
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

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Train = {
    enabled = false,
    connection = nil,
    remotes = {}
}

function Train.initRemotes()
    local trainEquipment = ReplicatedStorage:WaitForChild("TrainEquipment", 15):WaitForChild("Remote", 15)
    local trainSystem = ReplicatedStorage:WaitForChild("TrainSystem", 15):WaitForChild("Remote", 15)

    Train.remotes.takeUp = trainEquipment:WaitForChild("ApplyTakeUpStationaryTrainEquipment", 15)
    Train.remotes.statEffect = trainEquipment:WaitForChild("ApplyBindingTrainingEffect", 15)
    Train.remotes.boostEffect = trainEquipment:WaitForChild("ApplyBindingTrainingBoostEffect", 15)
    Train.remotes.speedRemote = trainSystem:WaitForChild("TrainSpeedHasChanged", 15)
    
    print("[Train]: Remotes inicializados")
end

function Train.enable()
    if Train.enabled then return end
    Train.enabled = true
    
    if not Train.remotes.takeUp then
        Train.initRemotes()
    end
    
    print("[Train]: Ativado")
    
    Train.connection = RunService.Heartbeat:Connect(function()
        if not Train.enabled then return end
        
        Utils.try(function()
            if Train.remotes.takeUp and Train.remotes.takeUp.InvokeServer then
                Train.remotes.takeUp:InvokeServer(true)
            end
        end)
        
        Utils.try(function()
            if Train.remotes.statEffect and Train.remotes.statEffect.InvokeServer then
                Train.remotes.statEffect:InvokeServer()
            end
        end)
        
        Utils.try(function()
            if Train.remotes.boostEffect and Train.remotes.boostEffect.InvokeServer then
                Train.remotes.boostEffect:InvokeServer()
            end
        end)
    end)
end

function Train.disable()
    if not Train.enabled then return end
    Train.enabled = false
    
    if Train.connection then
        pcall(function() Train.connection:Disconnect() end)
        Train.connection = nil
    end
    
    print("[Train]: Desativado")
end

function Train.toggle()
    if Train.enabled then
        Train.disable()
    else
        Train.enable()
    end
end

-- Listener
State.onChange("Train", function(enabled)
    if enabled then
        Train.enable()
    else
        Train.disable()
    end
end)

return Train
