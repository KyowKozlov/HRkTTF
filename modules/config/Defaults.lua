-- =============================================
-- HNk TTF HUB v9.4.3 - DEFAULT CONFIG
-- =============================================

local Defaults = {}

function Defaults:GetDefaults()
    return {
        ESP = true,
        God = true,
        Speed = false,
        Jump = false,
        Train = false,
        AntiAFK = true,
        AntiFall = true,
        PerformanceOverlay = true,
        FOV = 90,
        FOVMOUSECONTROL = false,
        MinimalMode = false,
        CurrentTheme = "Shadowcore"
    }
end

return Defaults
