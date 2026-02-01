-- =============================================
-- HNk TTF HUB v9.4.3 - COLORS MODULE
-- =============================================

local Colors = {}

function Colors:GetReputationColor(player, targetPlayer, reputation)
    local MIN_REP_GRADIENT = 5000
    local MAX_REP_GRADIENT = 1000000

    local dn = ""
    if targetPlayer and targetPlayer.DisplayName then dn = targetPlayer.DisplayName:upper() end

    if targetPlayer == player or string.find(dn, "KOZLOV") then
        return Color3.fromRGB(0, 150, 0) -- KOZLOV verde
    elseif string.find(dn, "NOTORIOUS") then
        return Color3.fromRGB(0, 150, 255) -- NOTORIOUS azul
    elseif reputation and reputation >= MIN_REP_GRADIENT then
        local ratio = math.min(1, (reputation - MIN_REP_GRADIENT) / (MAX_REP_GRADIENT - MIN_REP_GRADIENT))
        local r = 255
        local g = 150 * (1 - ratio)
        local b = 200 + 55 * ratio
        return Color3.fromRGB(r, g, b)
    else
        return Color3.new(1, 1, 1)
    end
end

return Colors
