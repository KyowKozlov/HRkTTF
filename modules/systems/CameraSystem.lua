-- =============================================
-- HNk TTF HUB v9.4.3 - CAMERA MODULE
-- =============================================

local Camera = workspace.CurrentCamera
local CameraSystem = {}

function CameraSystem:Update(state)
    if not Camera then return end

    local fov = state:Get("FOV")
    if fov and Camera.FieldOfView ~= fov then
        if Camera.CameraType ~= Enum.CameraType.Custom and Camera.CameraType ~= Enum.CameraType.Watch then
            Camera.CameraType = Enum.CameraType.Custom
        end
        Camera.FieldOfView = fov
    end
end

function CameraSystem:GetFieldOfView()
    return Camera and Camera.FieldOfView or 90
end

function CameraSystem:SetFieldOfView(value)
    if Camera then
        Camera.FieldOfView = value
    end
end

function CameraSystem:IsScriptable()
    return Camera and Camera.CameraType == Enum.CameraType.Scriptable or false
end

return CameraSystem
