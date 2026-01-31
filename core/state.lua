-- ===================================
-- STATE MODULE - Gerenciador de Estado Global
-- ===================================

local Config = getgenv().HNkConfig
local Utils = getgenv().HNkUtils

-- Aguardar Config e Utils carregarem via getgenv
local maxWait = 50
local attempts = 0
while (not Config or not Utils) and attempts < maxWait do
    Config = getgenv().HNkConfig
    Utils = getgenv().HNkUtils
    if Config and Utils then break end
    task.wait(0.05)
    attempts = attempts + 1
end

if not Config then error("[State]: Config não foi carregado!") end
if not Utils then error("[State]: Utils não foi carregado!") end

local State = {}
local listeners = {}

-- Inicializa o estado global
getgenv().HNk = {}
for k, v in pairs(Config.DEFAULTS) do
    getgenv().HNk[k] = v
end

-- Carrega configurações salvas
pcall(function()
    local saved = Utils.loadConfig()
    if saved then
        for k, v in pairs(saved) do
            if getgenv().HNk[k] ~= nil and type(getgenv().HNk[k]) == type(v) then
                getgenv().HNk[k] = v
            end
        end
        print("[HNk State]: Configurações carregadas com sucesso")
    end
end)

-- Sistema de listeners para mudanças de estado
function State.onChange(key, callback)
    if not listeners[key] then listeners[key] = {} end
    table.insert(listeners[key], callback)
end

function State.get(key)
    return getgenv().HNk[key]
end

function State.set(key, value)
    if getgenv().HNk[key] ~= value then
        getgenv().HNk[key] = value
        if listeners[key] then
            for _, callback in ipairs(listeners[key]) do
                pcall(callback, value)
            end
        end
        pcall(function() Utils.saveConfig(getgenv().HNk) end)
    end
end

function State.getAll()
    return getgenv().HNk
end

return State
