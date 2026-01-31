-- ===================================
-- LOADER: Apenas GUI
-- ===================================

print("HNk Hub v9.4.3 - Carregando GUI...")

local GUI = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("features"):WaitForChild("gui"))

GUI.create()

print("GUI carregado com sucesso!")
