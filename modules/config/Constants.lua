-- =============================================
-- HNk TTF HUB v9.4.3 - CONSTANTS MODULE
-- =============================================

local Constants = {}

Constants.VERSION = "9.4.3"
Constants.HUB_NAME = "HNk TTF HUB"

-- Arquivo de configuração
Constants.FILE_NAME = "HNkTTF_config.json"

-- Dimensões da GUI
Constants.INITIAL_WIDTH = 450
Constants.INITIAL_HEIGHT = 380
Constants.TAB_WIDTH = 130
Constants.MINIMIZED_HEIGHT = 25

-- Unidades de formatação numérica
Constants.UNITS = {
    "k", "M", "B", "T", "Qa", "Qi", "Aa", "Ab", "Ac", "Ad",
    "Ae", "Af", "Ag", "Ah", "Ai", "Aj", "Ak", "Al", "Am", "An", "Ao", "Ap"
}

-- Configurações de reputação para cores
Constants.MIN_REP_GRADIENT = 5000
Constants.MAX_REP_GRADIENT = 1000000

-- Timeouts para remotes
Constants.REMOTE_TIMEOUT = 15

-- Animação
Constants.TWEEN_DURATION = 0.3
Constants.TOGGLE_ANIMATE_DURATION = 0.15

-- Taxa de atualização de performance overlay
Constants.PERFORMANCE_UPDATE_INTERVAL = 0.3
Constants.FPS_INTERVAL = 0.5

-- Anti-fall
Constants.AIRTIME_THRESHOLD = 2
Constants.VELOCITY_THRESHOLD = 1
Constants.RECOVERY_IMPULSE = 60
Constants.RECOVERY_IMPULSE_FALLDOWN = 50

return Constants
