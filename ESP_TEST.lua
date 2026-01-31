-- Script de teste ESP - Versão simplificada para diagnóstico
print("=== ESP TEST SCRIPT STARTED ===")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

print("Local player: " .. tostring(player))
print("Players in game: " .. #Players:GetPlayers())

local ESP_Players = {}
local ESP_Power_Cache = {}
local ESP_Rep_Cache = {}

-- Teste 1: Verificar se consegue achar jogadores
task.spawn(function()
    print("\n[TEST 1] Procurando por jogadores...")
    while task.wait(1) do
        local playerList = Players:GetPlayers()
        print("[TEST 1] Total de jogadores: " .. #playerList)
        for _, p in pairs(playerList) do
            print("  - " .. p.DisplayName .. " (Character: " .. tostring(p.Character ~= nil) .. ")")
            if p.Character then
                local head = p.Character:FindFirstChild("Head")
                print("    Head existe: " .. tostring(head ~= nil))
            end
        end
    end
end)

-- Teste 2: Renderizar ESP
task.spawn(function()
    print("\n[TEST 2] Iniciando renderização ESP...")
    local count = 0
    
    RunService.Heartbeat:Connect(function()
        for _, p in Players:GetPlayers() do
            if p == player then
                continue
            end
            
            if not p.Character or not p.Character:FindFirstChild("Head") then
                if ESP_Players[p] and ESP_Players[p].billboard then 
                    ESP_Players[p].billboard:Destroy() 
                end
                ESP_Players[p] = nil
                continue
            end
            
            local data = ESP_Players[p]
            if not data then
                local head = p.Character.Head
                
                -- Criar BillboardGui
                local bill = Instance.new("BillboardGui", head)
                bill.Name = "TestESP"
                bill.Size = UDim2.new(0, 200, 0, 50)
                bill.StudsOffset = Vector3.new(0, 3, 0)
                bill.AlwaysOnTop = true
                
                -- Criar TextLabel
                local txt = Instance.new("TextLabel", bill)
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 0.5
                txt.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                txt.Text = p.DisplayName
                txt.TextColor3 = Color3.new(1, 1, 1)
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 14
                
                ESP_Players[p] = {billboard = bill, label = txt}
                count = count + 1
                print("[TEST 2] Created ESP for: " .. p.DisplayName .. " (Total: " .. count .. ")")
            end
        end
    end)
end)

print("=== Tests running, check console output ===")
