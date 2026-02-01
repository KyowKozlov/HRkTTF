-- =============================================
-- HNk TTF HUB v9.4.3 - MODULES DATA
-- =============================================

local ModulesData = {}

ModulesData.STRUCTURE = {
    ["Shadow Core"] = {
        {name = "Train", type = "Toggle", text = "CORE: DARK TRAINING (STAT/BOOST)", icon = "⚔️"},
        {name = "AntiAFK", type = "Toggle", text = "ANTI-AFK (SOUL LOCK)", icon = "⏳"},
        {name = "AntiFall", type = "Toggle", text = "ANTI-DEATH (VOID RESCUE)", icon = "💀"},
    },
    ["Visuals"] = {
        {name = "ESP", type = "Toggle", text = "SHADOW ESP (POWER ANALYSE)", icon = "👁️‍🗨️"},
        {name = "PerformanceOverlay", type = "Toggle", text = "OVERLAY: STATUS DE LUTA", icon = "📊"},
        {name = "FOVMouseControl", type = "Toggle", text = "FOV: CONTROLE DO MOUSE (SCROLL)", icon = "🖱️"},
        {name = "MinimalMode", type = "Toggle", text = "MINIMAL MODE (COMPACT GUI)", icon = "🔲"},
        {name = "FOV", type = "Slider", text = "VISÃO: ANÁLISE DE CAMPO", min = 70, max = 120, default = 90, icon = "🔭"},
    },
    ["Player"] = {
        {name = "God", type = "Toggle", text = "HEALTH MAX", icon = "🛡️"},
        {name = "Speed", type = "Toggle", text = "SPEED HACK", icon = "🏃‍♂️"},
        {name = "Jump", type = "Toggle", text = "JUMP HACK", icon = "⬆️"},
    },
    ["Themas"] = {},
}

ModulesData.TAB_ORDER = {"Shadow Core", "Visuals", "Player", "Themas"}

function ModulesData:GetStructure()
    return self.STRUCTURE
end

function ModulesData:GetTabOrder()
    return self.TAB_ORDER
end

function ModulesData:GetModulesByTab(tabName)
    return self.STRUCTURE[tabName] or {}
end

return ModulesData
