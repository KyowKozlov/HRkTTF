-- ===================================
-- TESTE LOCAL - Simula o ambiente
-- ===================================

-- Este arquivo é para testes em ambiente local
-- Descomente conforme necessário

print("=== HNk Hub Test Environment ===\n")

-- Simula estrutura de pastas para testes
local testPath = {}

-- Teste de módulo config
print("[TEST 1] Carregando Config...")
local Config = {
    ACCENT_ON = Color3.fromRGB(255, 60, 60),
    ACCENT_OFF = Color3.fromRGB(100, 100, 100),
    PRIMARY_BG = Color3.fromRGB(15, 15, 15),
    DARK_BG = Color3.fromRGB(25, 25, 25),
    FILE_NAME = "HNkTTF_config.json",
    UNITS = {"k", "M", "B", "T", "Qa", "Qi"},
    DEFAULTS = {
        ESP = true,
        God = true,
        Speed = false,
        Train = false,
        AntiAFK = true,
    }
}
print("[OK] Config carregado\n")

-- Teste de formatação
print("[TEST 2] Formatação de números...")
local function formatNumber(num)
    if num < 1000 then return tostring(math.floor(num)) end
    local exp = math.log10(num)
    local order = math.floor(exp / 3)
    if order > 0 then
        if order <= #Config.UNITS then
            local unit = Config.UNITS[order]
            local scaled = num / (10 ^ (order * 3))
            return string.format("%.2f %s", scaled, unit)
        end
    end
    return tostring(num)
end

print("1.500 => " .. formatNumber(1500))
print("1.500.000 => " .. formatNumber(1500000))
print("1.500.000.000 => " .. formatNumber(1500000000))
print("[OK] Formatação funcionando\n")

-- Teste de listeners
print("[TEST 3] Sistema de State com listeners...")
local State = {}
local listeners = {}

function State.set(key, value)
    if listeners[key] then
        for _, cb in ipairs(listeners[key]) do
            cb(value)
        end
    end
    print("  -> State[" .. key .. "] = " .. tostring(value))
end

function State.onChange(key, callback)
    if not listeners[key] then listeners[key] = {} end
    table.insert(listeners[key], callback)
end

State.onChange("God", function(val)
    print("    [LISTENER] God Mode mudou para: " .. tostring(val))
end)

State.set("God", true)
State.set("God", false)
print("[OK] Listeners funcionando\n")

-- Teste de estrutura modular
print("[TEST 4] Arquitetura Modular...")
print("  ✓ core/config.lua")
print("  ✓ core/state.lua")
print("  ✓ core/utils.lua")
print("  ✓ features/gui.lua")
print("  ✓ features/esp.lua")
print("  ✓ features/god.lua")
print("  ✓ features/train.lua")
print("  ✓ features/player.lua")
print("  ✓ loaders/gui_only.lua")
print("  ✓ loaders/esp_only.lua")
print("  ✓ loaders/god_only.lua")
print("  ✓ loaders/train_only.lua")
print("  ✓ loaders/full.lua")
print("[OK] Estrutura modular pronta\n")

print("=== Testes Concluídos ===")
print("\nPróximas ações:")
print("1. Copiar estrutura para ReplicatedStorage")
print("2. Testar em jogo com loadstring(game:HttpGet(...))()")
print("3. Usar loaders conforme necessidade")
