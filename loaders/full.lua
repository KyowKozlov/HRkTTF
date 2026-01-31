-- ===================================
-- LOADER: COMPLETO (GUI + TODAS as FEATURES)
-- ===================================

print("HNk Hub v9.4.3 - Carregando COMPLETO...")

local BASE_URL = "https://raw.githubusercontent.com/KyowKozlov/HRkTTF/main"

local function loadModule(path)
    local url = BASE_URL .. "/" .. path
    local code = game:HttpGet(url)
    local func = loadstring(code)
    return func()
end

-- Carrega core (na ordem correta: config -> utils -> state)
local Config = loadModule("core/config.lua")
getgenv().HNkConfig = Config

local Utils = loadModule("core/utils.lua")
getgenv().HNkUtils = Utils

local State = loadModule("core/state.lua")
getgenv().HNkState = State

-- Carrega todas as features
local GUI = loadModule("features/gui.lua")
local ESP = loadModule("features/esp.lua")
local God = loadModule("features/god.lua")
local Train = loadModule("features/train.lua")
local Player = loadModule("features/player.lua")

-- Cria a GUI
GUI.create()

-- Ativa features baseado na config salva
for name, value in pairs(State.getAll()) do
    if type(value) == "boolean" then
        State.set(name, value)
    end
end

print("HNk Hub v9.4.3 COMPLETO ATIVADO! GUI + todas as features!")
