-- =============================================
-- HNk TTF HUB v9.4.3 - THEMES MODULE
-- =============================================

local Themes = {}

Themes.CONFIG = {
    ["Shadowcore"] = {
        ACCENT_ON = Color3.fromRGB(255, 60, 60),
        ACCENT_OFF = Color3.fromRGB(80, 80, 80),
        PRIMARY_BG = Color3.fromRGB(15, 15, 15),
        DARK_BG = Color3.fromRGB(25, 25, 25),
    },
    ["CyberSynth"] = {
        ACCENT_ON = Color3.fromRGB(0, 255, 255),
        ACCENT_OFF = Color3.fromRGB(0, 100, 100),
        PRIMARY_BG = Color3.fromRGB(10, 10, 30),
        DARK_BG = Color3.fromRGB(20, 20, 40),
    },
    ["Solar Flare"] = {
        ACCENT_ON = Color3.fromRGB(255, 200, 0),
        ACCENT_OFF = Color3.fromRGB(100, 80, 0),
        PRIMARY_BG = Color3.fromRGB(40, 40, 40),
        DARK_BG = Color3.fromRGB(60, 60, 60),
    },
    ["Vaporwave"] = {
        ACCENT_ON = Color3.fromRGB(255, 0, 255),
        ACCENT_OFF = Color3.fromRGB(150, 0, 150),
        PRIMARY_BG = Color3.fromRGB(30, 0, 30),
        DARK_BG = Color3.fromRGB(40, 40, 60),
    },
    ["Forest Night"] = {
        ACCENT_ON = Color3.fromRGB(0, 255, 120),
        ACCENT_OFF = Color3.fromRGB(0, 100, 50),
        PRIMARY_BG = Color3.fromRGB(10, 20, 10),
        DARK_BG = Color3.fromRGB(20, 40, 20),
    },
    ["Monochrome"] = {
        ACCENT_ON = Color3.fromRGB(255, 255, 255),
        ACCENT_OFF = Color3.fromRGB(150, 150, 150),
        PRIMARY_BG = Color3.fromRGB(0, 0, 0),
        DARK_BG = Color3.fromRGB(20, 20, 20),
    },
}

function Themes:GetTheme(themeName)
    return self.CONFIG[themeName] or self.CONFIG["Shadowcore"]
end

function Themes:GetAllThemes()
    return self.CONFIG
end

function Themes:AddCustomTheme(name, colors)
    self.CONFIG[name] = colors
end

return Themes
