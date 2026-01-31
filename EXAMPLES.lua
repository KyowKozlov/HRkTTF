-- ===================================
-- ADVANCED EXAMPLES - Exemplos Avançados
-- ===================================

-- Todos esses exemplos funcionam DEPOIS que você carregou o hub
-- (após executar um dos loaders)

print("=" .. string.rep("=", 48) .. "=")
print("HNk Hub v9.4.3 - Exemplos Avançados")
print("=" .. string.rep("=", 48) .. "=\n")

-- ===================================
-- 1. SISTEMA DE PRESETS (Salvar combos)
-- ===================================

print("Exemplo 1: Sistema de Presets\n")

--[[

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))

-- Definir presets
local presets = {
    farming = {
        Train = true,
        Speed = true,
        AntiAFK = true,
        AntiFall = true,
        God = false,
        ESP = true,
        Jump = false
    },
    pvp = {
        God = true,
        Speed = true,
        Jump = true,
        ESP = true,
        Train = false,
        AntiAFK = true,
        AntiFall = true
    },
    stealth = {
        Invisible = true,
        AntiFall = true,
        AntiAFK = true,
        ESP = false,
        God = false,
        Speed = false,
        Jump = false
    },
    exploration = {
        Speed = true,
        Jump = true,
        FOV = 110,
        FOVMouseControl = true,
        AntiFall = true,
        God = false,
        Train = false
    }
}

-- Função para aplicar preset
local function applyPreset(presetName)
    local preset = presets[presetName]
    if not preset then
        print("❌ Preset '" .. presetName .. "' não encontrado")
        return
    end
    
    for feature, value in pairs(preset) do
        State.set(feature, value)
        print("  " .. feature .. " = " .. tostring(value))
    end
    
    print("✅ Preset '" .. presetName .. "' aplicado!")
end

-- Usar
-- applyPreset("farming")
-- applyPreset("pvp")
-- applyPreset("stealth")
-- applyPreset("exploration")

]]--

-- ===================================
-- 2. AUTO-ACTIVATE BASEADO EM TEMPO
-- ===================================

print("Exemplo 2: Auto-activate com Timer\n")

--[[

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))

-- Função para ativar depois de X segundos
local function activateAfter(seconds, features)
    print("⏳ Ativando features em " .. seconds .. " segundo(s)...")
    
    task.wait(seconds)
    
    for feature, shouldActivate in pairs(features) do
        if shouldActivate then
            State.set(feature, true)
            print("  ✅ " .. feature .. " ativado")
        end
    end
    
    print("🎉 Todos os features foram ativados!")
end

-- Usar
-- activateAfter(5, {Train = true, Speed = true, AntiAFK = true})

-- Ou com delay progressivo
local function activateProgressive(features)
    for i, feature in ipairs(features) do
        State.set(feature, true)
        print("  [" .. i .. "/" .. #features .. "] " .. feature .. " ativado")
        task.wait(0.5)
    end
    print("🎉 Todos os features foram ativados!")
end

-- Usar
-- activateProgressive({"Train", "Speed", "AntiAFK", "ESP"})

]]--

-- ===================================
-- 3. SISTEMA DE LOGS E MONITORAMENTO
-- ===================================

print("Exemplo 3: Sistema de Logs\n")

--[[

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))

-- Criar sistema de logs
local logs = {}
local maxLogs = 50

local function log(message, level)
    level = level or "INFO"
    local timestamp = os.date("%H:%M:%S")
    local logEntry = "[" .. timestamp .. "] [" .. level .. "] " .. message
    
    table.insert(logs, logEntry)
    if #logs > maxLogs then table.remove(logs, 1) end
    
    print(logEntry)
end

-- Monitorar TODAS as mudanças
local features = {"God", "ESP", "Train", "Speed", "Jump", "AntiAFK", "AntiFall", "Invisible"}

for _, feature in ipairs(features) do
    State.onChange(feature, function(enabled)
        if enabled then
            log(feature .. " foi ATIVADO", "SUCCESS")
        else
            log(feature .. " foi DESATIVADO", "INFO")
        end
    end)
end

-- Função para ver logs
local function viewLogs()
    print("\n📋 ÚLTIMOS LOGS:")
    for i, logEntry in ipairs(logs) do
        print(logEntry)
    end
end

-- Usar
-- viewLogs()

]]--

-- ===================================
-- 4. SISTEMA DE HOTKEYS (Atalhos)
-- ===================================

print("Exemplo 4: Sistema de Hotkeys\n")

--[[

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))
local UserInputService = game:GetService("UserInputService")

-- Definir hotkeys
local hotkeys = {
    [Enum.KeyCode.F1] = function() State.set("God", not State.get("God")) end,
    [Enum.KeyCode.F2] = function() State.set("ESP", not State.get("ESP")) end,
    [Enum.KeyCode.F3] = function() State.set("Train", not State.get("Train")) end,
    [Enum.KeyCode.F4] = function() State.set("Speed", not State.get("Speed")) end,
    [Enum.KeyCode.F5] = function() State.set("Jump", not State.get("Jump")) end,
    [Enum.KeyCode.G] = function() State.set("God", not State.get("God")) end,  -- G para God
    [Enum.KeyCode.E] = function() State.set("ESP", not State.get("ESP")) end,  -- E para ESP
}

-- Ativar hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if hotkeys[input.KeyCode] then
        hotkeys[input.KeyCode]()
    end
end)

print("✅ Hotkeys ativados:")
print("  F1 = Toggle God")
print("  F2 = Toggle ESP")
print("  F3 = Toggle Train")
print("  F4 = Toggle Speed")
print("  F5 = Toggle Jump")
print("  G  = Toggle God (alternativo)")
print("  E  = Toggle ESP (alternativo)")

]]--

-- ===================================
-- 5. SISTEMA DE PERFIL (Multi-slot)
-- ===================================

print("Exemplo 5: Sistema de Perfil\n")

--[[

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))
local HttpService = game:GetService("HttpService")

-- Profiles
local profiles = {}

-- Salvar perfil
local function saveProfile(profileName)
    profiles[profileName] = HttpService:JSONEncode(State.getAll())
    print("💾 Perfil '" .. profileName .. "' salvo!")
end

-- Carregar perfil
local function loadProfile(profileName)
    if not profiles[profileName] then
        print("❌ Perfil '" .. profileName .. "' não encontrado")
        return
    end
    
    local success, data = pcall(HttpService.JSONDecode, HttpService, profiles[profileName])
    if not success then
        print("❌ Erro ao decodificar perfil")
        return
    end
    
    for feature, value in pairs(data) do
        if type(value) == "boolean" or type(value) == "number" then
            State.set(feature, value)
        end
    end
    
    print("📂 Perfil '" .. profileName .. "' carregado!")
end

-- Listar perfis
local function listProfiles()
    print("\n📋 Perfis disponíveis:")
    for name in pairs(profiles) do
        print("  - " .. name)
    end
end

-- Usar
-- saveProfile("gaming")      -- Salva o setup atual como "gaming"
-- saveProfile("farming")     -- Salva o setup atual como "farming"
-- loadProfile("gaming")      -- Carrega o setup "gaming"
-- listProfiles()             -- Lista todos os perfis

]]--

-- ===================================
-- 6. SISTEMA DE ALERTAS
-- ===================================

print("Exemplo 6: Sistema de Alertas\n")

--[[

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))
local Players = game:GetService("Players")

-- Função de alerta
local function alert(title, message, duration)
    duration = duration or 5
    print("🔔 " .. title .. ": " .. message .. " (será removido em " .. duration .. "s)")
    task.wait(duration)
end

-- Alertar quando God Mode sair
State.onChange("God", function(enabled)
    if not enabled then
        alert("⚠️ AVISO", "God Mode foi DESATIVADO!", 5)
    end
end)

-- Alertar quando Health baixar
local Players = game:GetService("Players")
local player = Players.LocalPlayer

task.spawn(function()
    while true do
        task.wait(1)
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health < hum.MaxHealth * 0.25 and not State.get("God") then
                print("🚨 ALERTA: Health baixa! (" .. math.floor(hum.Health) .. "/" .. hum.MaxHealth .. ")")
            end
        end
    end
end)

]]--

-- ===================================
-- 7. EXPORT/IMPORT DE CONFIG
-- ===================================

print("Exemplo 7: Export/Import\n")

--[[

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))
local HttpService = game:GetService("HttpService")

-- Exportar config como JSON
local function exportConfig()
    local json = HttpService:JSONEncode(State.getAll())
    print("\n📤 Config Exportada:")
    print(json)
    return json
end

-- Importar config de JSON
local function importConfig(jsonString)
    local success, data = pcall(HttpService.JSONDecode, HttpService, jsonString)
    if not success then
        print("❌ JSON inválido")
        return
    end
    
    for feature, value in pairs(data) do
        if State.get(feature) ~= nil then
            State.set(feature, value)
        end
    end
    
    print("✅ Config importada!")
end

-- Usar
-- local exported = exportConfig()
-- importConfig(exported)

]]--

-- ===================================
-- 8. DEBUG MODE
-- ===================================

print("Exemplo 8: Debug Mode\n")

--[[

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))

local DebugMode = {
    enabled = false,
    
    enable = function(self)
        self.enabled = true
        print("🐛 Debug Mode ATIVADO")
        
        -- Monitorar tudo
        local features = {"God", "ESP", "Train", "Speed", "Jump", "AntiAFK", "AntiFall", "Invisible", "FOV"}
        for _, feature in ipairs(features) do
            State.onChange(feature, function(value)
                print("[DEBUG] " .. feature .. " changed to " .. tostring(value))
            end)
        end
    end,
    
    disable = function(self)
        self.enabled = false
        print("🐛 Debug Mode DESATIVADO")
    end,
    
    status = function(self)
        if self.enabled then
            print("\n📊 Status:")
            for feature, value in pairs(State.getAll()) do
                print("  " .. feature .. " = " .. tostring(value))
            end
        end
    end
}

-- Usar
-- DebugMode:enable()
-- DebugMode:status()
-- DebugMode:disable()

]]--

-- ===================================
-- 9. PERFORMANCE MONITOR
-- ===================================

print("Exemplo 9: Performance Monitor\n")

--[[

local RunService = game:GetService("RunService")

local PerfMon = {
    fps = 0,
    ping = 0,
    
    start = function(self)
        print("📊 Performance Monitor iniciado")
        
        local frameCount = 0
        local lastTime = tick()
        local updateInterval = 1
        
        local Players = game:GetService("Players")
        
        RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            
            local now = tick()
            if now - lastTime >= updateInterval then
                self.fps = math.floor(frameCount / (now - lastTime))
                frameCount = 0
                lastTime = now
                
                -- Pegar ping
                local ok, pingVal = pcall(function()
                    return Players.LocalPlayer:GetNetworkPing()
                end)
                if ok then
                    self.ping = math.floor(pingVal * 1000)
                end
            end
        end)
    end,
    
    getStatus = function(self)
        return string.format("FPS: %d | PING: %d ms", self.fps, self.ping)
    end
}

-- Usar
-- PerfMon:start()
-- print(PerfMon:getStatus())

]]--

-- ===================================
-- 10. AUTO-SAVE/LOAD CONFIG
-- ===================================

print("Exemplo 10: Auto-Save/Load\n")

--[[

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))

-- Auto-save a cada 30 segundos
task.spawn(function()
    while true do
        task.wait(30)
        -- Estado já é salvo automaticamente pelo core/state.lua
        print("💾 Config salva automaticamente")
    end
end)

-- On game close, salva
game:BindToClose(function()
    print("💾 Salvando config antes de fechar...")
    -- State já salva automaticamente
end)

]]--

print("\n" .. string.rep("=", 50))
print("Todos os exemplos estão comentados.")
print("Descomente os que quiser usar!")
print(string.rep("=", 50) .. "\n")
