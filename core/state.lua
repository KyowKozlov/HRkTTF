-- ===================================
-- STATE MODULE - Gerenciador de Estado Global
-- ===================================

-- Carrega Config e Utils se disponíveis via loadstring, senão tenta via require
local Config
if getgenv().HNkConfig then
    Config = getgenv().HNkConfig
else
    Config = require(script.Parent:WaitForChild("config"))
end

local Utils
if getgenv().HNkUtils then
    Utils = getgenv().HNkUtils
else
    Utils = require(script.Parent:WaitForChild("utils"))
end

local State = {}
local listeners = {}

-- Inicializa o estado global
getgenv().HNk = {}
for k, v in pairs(Config.DEFAULTS) do
    getgenv().HNk[k] = v
end

-- Carrega configurações salvas
local saved = Utils.loadConfig()
if saved then
    for k, v in pairs(saved) do
        if getgenv().HNk[k] ~= nil and type(getgenv().HNk[k]) == type(v) then
            getgenv().HNk[k] = v
        end
    end
    print("[HNk State]: Configurações carregadas com sucesso")
end

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
        Utils.saveConfig(getgenv().HNk)
    end
end

function State.getAll()
    return getgenv().HNk
end

return State
