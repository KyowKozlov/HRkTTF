-- ===================================
-- LOADER: Apenas Train
-- ===================================

print("HNk Hub v9.4.3 - Carregando Train...")

local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))
local Train = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("features"):WaitForChild("train"))

State.set("Train", true)

print("Train carregado e ativado!")
