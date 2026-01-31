-- ===================================
-- VALIDATION TEST - Validar se tudo está funcionando
-- ===================================

print("=== HNk Hub v9.4.3 - Validation Test ===\n")

local testsPassed = 0
local testsFailed = 0

local function test(name, condition, expectedResult)
    if condition == expectedResult then
        print("✅ [PASS] " .. name)
        testsPassed = testsPassed + 1
    else
        print("❌ [FAIL] " .. name)
        testsFailed = testsFailed + 1
    end
end

-- ===================================
-- TEST 1: Verificar se módulos estão carregados
-- ===================================
print("\n[TEST SUITE 1] Módulos Carregados")
print("-" .. string.rep("-", 40))

test("Config Module", getgenv().HNkConfig ~= nil, true)
test("Utils Module", getgenv().HNkUtils ~= nil, true)
test("State Module", getgenv().HNkState ~= nil, true)
test("Hooks Module", getgenv().HNkHooks ~= nil, true)

-- ===================================
-- TEST 2: Verificar se Estado Global existe
-- ===================================
print("\n[TEST SUITE 2] Estado Global")
print("-" .. string.rep("-", 40))

test("getgenv().HNk exists", getgenv().HNk ~= nil, true)
test("HNk.God exists", getgenv().HNk.God ~= nil, true)
test("HNk.Train exists", getgenv().HNk.Train ~= nil, true)
test("HNk.ESP exists", getgenv().HNk.ESP ~= nil, true)
test("HNk.Speed exists", getgenv().HNk.Speed ~= nil, true)
test("HNk.Jump exists", getgenv().HNk.Jump ~= nil, true)
test("HNk.AntiAFK exists", getgenv().HNk.AntiAFK ~= nil, true)
test("HNk.AntiFall exists", getgenv().HNk.AntiFall ~= nil, true)
test("HNk.GodExtreme exists", getgenv().HNk.GodExtreme ~= nil, true)
test("HNk.Invisible exists", getgenv().HNk.Invisible ~= nil, true)
test("HNk.FOV exists", getgenv().HNk.FOV ~= nil, true)

-- ===================================
-- TEST 3: Verificar funções State
-- ===================================
print("\n[TEST SUITE 3] Funções State")
print("-" .. string.rep("-", 40))

local State = getgenv().HNkState
if State then
    test("State.get exists", type(State.get) == "function", true)
    test("State.set exists", type(State.set) == "function", true)
    test("State.onChange exists", type(State.onChange) == "function", true)
    test("State.getAll exists", type(State.getAll) == "function", true)
    
    -- Test State.get
    local godValue = State.get("God")
    test("State.get('God') returns value", godValue ~= nil, true)
    
    -- Test State.set
    pcall(function()
        State.set("God", true)
        test("State.set('God', true) works", State.get("God") == true, true)
    end)
else
    print("❌ State module not loaded!")
    testsFailed = testsFailed + 5
end

-- ===================================
-- TEST 4: Verificar Hooks
-- ===================================
print("\n[TEST SUITE 4] Hooks Functions")
print("-" .. string.rep("-", 40))

local Hooks = getgenv().HNkHooks
if Hooks then
    test("Hooks.init exists", type(Hooks.init) == "function", true)
    test("Hooks.setupStateListeners exists", type(Hooks.setupStateListeners) == "function", true)
    test("Hooks.startESPLoop exists", type(Hooks.startESPLoop) == "function", true)
    test("Hooks.startAntiFallLoop exists", type(Hooks.startAntiFallLoop) == "function", true)
    test("Hooks.startUniversalLoop exists", type(Hooks.startUniversalLoop) == "function", true)
    test("Hooks.startFOVMouseControl exists", type(Hooks.startFOVMouseControl) == "function", true)
    test("Hooks.startPerformanceOverlay exists", type(Hooks.startPerformanceOverlay) == "function", true)
else
    print("❌ Hooks module not loaded!")
    testsFailed = testsFailed + 7
end

-- ===================================
-- TEST 5: Verificar Utils
-- ===================================
print("\n[TEST SUITE 5] Utils Functions")
print("-" .. string.rep("-", 40))

local Utils = getgenv().HNkUtils
if Utils then
    test("Utils.try exists", type(Utils.try) == "function", true)
    test("Utils.formatNumber exists", type(Utils.formatNumber) == "function", true)
    test("Utils.findEnemyPower exists", type(Utils.findEnemyPower) == "function", true)
    test("Utils.findPlayerStat exists", type(Utils.findPlayerStat) == "function", true)
    test("Utils.getReputationColor exists", type(Utils.getReputationColor) == "function", true)
else
    print("❌ Utils module not loaded!")
    testsFailed = testsFailed + 5
end

-- ===================================
-- TEST 6: Verificar GUI
-- ===================================
print("\n[TEST SUITE 6] GUI Elements")
print("-" .. string.rep("-", 40))

local CoreGui = game:GetService("CoreGui")
local hasMainGui = CoreGui:FindFirstChild("HNkHubModern") ~= nil
test("Main GUI created", hasMainGui, true)

-- ===================================
-- TEST 7: Listeners Setup (Validação indireta)
-- ===================================
print("\n[TEST SUITE 7] State Listeners")
print("-" .. string.rep("-", 40))

local listenerTestPassed = false
if State then
    State.onChange("_TestListener", function(value)
        listenerTestPassed = value == true
    end)
    State.set("_TestListener", true)
    test("onChange callback triggers", listenerTestPassed, true)
else
    print("⚠️  Skipped (State not available)")
    testsFailed = testsFailed + 1
end

-- ===================================
-- RESULTADO FINAL
-- ===================================
print("\n" .. string.rep("=", 50))
print("RESULTADO FINAL")
print(string.rep("=", 50))
print("✅ Testes passaram: " .. testsPassed)
print("❌ Testes falharam: " .. testsFailed)
print("📊 Taxa de sucesso: " .. math.floor((testsPassed / (testsPassed + testsFailed)) * 100) .. "%")
print(string.rep("=", 50))

if testsFailed == 0 then
    print("\n🎉 TODOS OS TESTES PASSARAM!")
    print("Hub está pronto para uso!")
else
    print("\n⚠️  Alguns testes falharam")
    print("Verifique os logs acima")
end

print("\n=== Teste Concluído ===")
