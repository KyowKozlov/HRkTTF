-- ===================================
-- QUICK START GUIDE
-- ===================================

-- Se você quer carregar TUDO (GUI + todas features):
-- Cole isto no console do Roblox:

--[[

loadstring(game:HttpGet("https://seu-link/loaders/full.lua"))()

]]--

-- Se você quer carregar APENAS GUI (controle manual):

--[[

loadstring(game:HttpGet("https://seu-link/loaders/gui_only.lua"))()

]]--

-- Se você quer APENAS ESP:

--[[

loadstring(game:HttpGet("https://seu-link/loaders/esp_only.lua"))()

]]--

-- Se você quer APENAS God Mode:

--[[

loadstring(game:HttpGet("https://seu-link/loaders/god_only.lua"))()

]]--

-- Se você quer APENAS Train:

--[[

loadstring(game:HttpGet("https://seu-link/loaders/train_only.lua"))()

]]--

-- ===================================
-- CONTROLAR VIA SCRIPT
-- ===================================

-- Depois de carregar, você pode fazer:

--[[

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))

-- ATIVAR/DESATIVAR FEATURES
State.set("God", true)         -- Ativa God Mode
State.set("ESP", true)         -- Ativa ESP
State.set("Train", true)       -- Ativa Train
State.set("Speed", true)       -- Ativa Speed (120 walk speed)
State.set("Jump", true)        -- Ativa Jump (150 jump power)
State.set("AntiAFK", true)     -- Ativa Anti-AFK
State.set("AntiFall", true)    -- Ativa Anti-Fall
State.set("Invisible", true)   -- Ativa Invisibilidade

-- DESATIVAR
State.set("God", false)        -- Desativa God Mode
State.set("ESP", false)        -- Desativa ESP

-- VERIFICAR STATUS
if State.get("God") then
    print("God Mode está ATIVADO")
else
    print("God Mode está DESATIVADO")
end

-- MUDAR FOV (Camera Zoom)
State.set("FOV", 100)          -- FOV de 100 graus

-- OUVIR MUDANÇAS (executar código quando algo muda)
State.onChange("God", function(enabled)
    if enabled then
        print("💪 God Mode ATIVADO!")
    else
        print("❌ God Mode DESATIVADO!")
    end
end)

State.onChange("ESP", function(enabled)
    if enabled then
        print("👁️ ESP ATIVADO!")
    else
        print("❌ ESP DESATIVADO!")
    end
end)

]]--

-- ===================================
-- COMBINAÇÕES ÚTEIS
-- ===================================

-- SETUP 1: Farming (Treino + Speed)
--[[

local core = game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core")
local features = game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("features")
local State = require(core:WaitForChild("state"))
local GUI = require(features:WaitForChild("gui"))

GUI.create()
State.set("Train", true)
State.set("Speed", true)
State.set("AntiAFK", true)
State.set("AntiFall", true)

print("🚀 Setup de Farming ativado!")

]]--

-- SETUP 2: PVP (God + Speed + ESP)
--[[

local core = game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core")
local features = game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("features")
local State = require(core:WaitForChild("state"))
local GUI = require(features:WaitForChild("gui"))

GUI.create()
State.set("God", true)
State.set("Speed", true)
State.set("ESP", true)
State.set("Jump", true)

print("⚔️ Setup de PVP ativado!")

]]--

-- SETUP 3: Stealth (Invisible + Anti-Fall)
--[[

local core = game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core")
local features = game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("features")
local State = require(core:WaitForChild("state"))
local GUI = require(features:WaitForChild("gui"))

GUI.create()
State.set("Invisible", true)
State.set("AntiFall", true)
State.set("AntiAFK", true)

print("👻 Setup de Stealth ativado!")

]]--

print([[
╔════════════════════════════════════════╗
║  HNk Hub v9.4.3 - Quick Start Guide   ║
╚════════════════════════════════════════╝

Para começar, cole um dos códigos acima!

Opções:
  1️⃣  full.lua        - Tudo (GUI + features)
  2️⃣  gui_only.lua    - Apenas interface
  3️⃣  esp_only.lua    - Apenas ESP
  4️⃣  god_only.lua    - Apenas God
  5️⃣  train_only.lua  - Apenas Train

Depois, use State.set() para controlar!

Para mais info, veja USAGE.md
]])
