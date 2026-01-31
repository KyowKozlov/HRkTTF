-- ===================================
-- LOADER: Apenas ESP
-- ===================================

print("HNk Hub v9.4.3 - Carregando ESP...")

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))
local ESP = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("features"):WaitForChild("esp"))

State.set("ESP", true)

print("ESP carregado e ativado!")
