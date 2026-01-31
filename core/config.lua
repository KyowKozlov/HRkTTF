-- ===================================
-- CONFIG MODULE - Configurações Centralizadas
-- ===================================

local Config = {}

-- TEMA
Config.ACCENT_ON = Color3.fromRGB(255, 60, 60)
Config.ACCENT_OFF = Color3.fromRGB(100, 100, 100)
Config.PRIMARY_BG = Color3.fromRGB(15, 15, 15)
Config.DARK_BG = Color3.fromRGB(25, 25, 25)

-- ARQUIVO
Config.FILE_NAME = "HNkTTF_config.json"

-- DEFAULTS
Config.DEFAULTS = {
    ESP = true,
    God = true,
    GodExtreme = true,
    Speed = false,
    Jump = false,
    Train = false,
    AntiAFK = true,
    AntiFall = true,
    PerformanceOverlay = true,
    FOV = 90,
    FOVMouseControl = false,
    MinimalMode = false,
    Invisible = true
}

-- UNIDADES (formatação de números)
Config.UNITS = {
    "k", "M", "B", "T", "Qa", "Qi", "Aa", "Ab", "Ac", "Ad",
    "Ae", "Af", "Ag", "Ah", "Ai", "Aj", "Ak", "Al", "Am", "An", "Ao", "Ap"
}

return Config
