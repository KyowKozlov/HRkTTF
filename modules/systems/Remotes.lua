-- =============================================
-- HNk TTF HUB v9.4.3 - REMOTES MANAGER
-- =============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = {}

function Remotes:Initialize()
    local remotes = {
        train = nil,
        statEffect = nil,
        boostEffect = nil,
        speedRemote = nil,
    }

    local TIMEOUT = 15

    -- Buscar TrainEquipment remotes
    local trainEquipment = ReplicatedStorage:WaitForChild("TrainEquipment", TIMEOUT)
    if trainEquipment then
        local remote = trainEquipment:WaitForChild("Remote", TIMEOUT)
        if remote then
            remotes.train = remote:WaitForChild("ApplyTakeUpStationaryTrainEquipment", TIMEOUT)
            remotes.statEffect = remote:WaitForChild("ApplyBindingTrainingEffect", TIMEOUT)
            remotes.boostEffect = remote:WaitForChild("ApplyBindingTrainingBoostEffect", TIMEOUT)
        end
    end

    -- Buscar TrainSystem remotes
    local trainSystem = ReplicatedStorage:WaitForChild("TrainSystem", TIMEOUT)
    if trainSystem then
        local remote = trainSystem:WaitForChild("Remote", TIMEOUT)
        if remote then
            remotes.speedRemote = remote:WaitForChild("TrainSpeedHasChanged", TIMEOUT)
        end
    end

    return remotes
end

return Remotes
