-- ===================================
-- LOADER: Apenas God Mode
-- ===================================

print("HNk Hub v9.4.3 - Carregando God Mode...")

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))
local God = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("features"):WaitForChild("god"))

State.set("God", true)

print("God Mode carregado e ativado!")
