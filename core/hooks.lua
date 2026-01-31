-- ===================================
-- HOOKS MODULE - Conecta listeners ao State e ativa loops
-- ===================================

local Config = getgenv().HNkConfig or require(script.Parent:WaitForChild("config"))
local State = getgenv().HNkState or require(script.Parent:WaitForChild("state"))
local Utils = getgenv().HNkUtils or require(script.Parent:WaitForChild("utils"))

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local Hooks = {}
local activeConnections = {}

-- ===================================
-- LISTENER CALLBACKS
-- ===================================

function Hooks.setupStateListeners()
    -- ESP Toggle
    State.onChange("ESP", function(enabled)
        if enabled then
            if not activeConnections.ESP then
                print("[Hooks]: Ativando ESP loop")
                Hooks.startESPLoop()
            end
        else
            if activeConnections.ESP then
                pcall(function() activeConnections.ESP:Disconnect() end)
                activeConnections.ESP = nil
            end
            if activeConnections.ESPCache then
                getgenv().HNkESPCacheStop = true
                task.wait(0.1)
                activeConnections.ESPCache = nil
            end
            -- Limpar billboards
            for _, p in Players:GetPlayers() do
                if getgenv().HNkESPPlayers and getgenv().HNkESPPlayers[p] then
                    if getgenv().HNkESPPlayers[p].billboard then
                        getgenv().HNkESPPlayers[p].billboard:Destroy()
                    end
                    getgenv().HNkESPPlayers[p] = nil
                end
            end
        end
    end)

    -- FOV Toggle
    State.onChange("FOV", function(value)
        if Camera then
            Camera.FieldOfView = value
        end
    end)

    -- God Mode Toggle
    State.onChange("God", function(enabled)
        if enabled then
            if not activeConnections.God then
                print("[Hooks]: Ativando God Mode loop")
                activeConnections.God = RunService.Heartbeat:Connect(function()
                    local char = player.Character
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        pcall(function()
                            hum.Health = hum.MaxHealth
                            hum.BreakJointsOnDeath = false
                        end)
                    end
                end)
            end
        else
            if activeConnections.God then
                pcall(function() activeConnections.God:Disconnect() end)
                activeConnections.God = nil
            end
        end
    end)

    -- Train Toggle
    State.onChange("Train", function(enabled)
        if enabled then
            if not activeConnections.Train then
                print("[Hooks]: Ativando Train loop")
                local trainEquipment = game:GetService("ReplicatedStorage"):WaitForChild("TrainEquipment", 15):WaitForChild("Remote", 15)
                local trainSystem = game:GetService("ReplicatedStorage"):WaitForChild("TrainSystem", 15):WaitForChild("Remote", 15)
                
                local takeUp = trainEquipment:WaitForChild("ApplyTakeUpStationaryTrainEquipment", 15)
                local statEffect = trainEquipment:WaitForChild("ApplyBindingTrainingEffect", 15)
                local boostEffect = trainEquipment:WaitForChild("ApplyBindingTrainingBoostEffect", 15)

                activeConnections.Train = RunService.Heartbeat:Connect(function()
                    if not State.get("Train") then return end
                    Utils.try(function() if takeUp and takeUp.InvokeServer then takeUp:InvokeServer(true) end end)
                    Utils.try(function() if statEffect and statEffect.InvokeServer then statEffect:InvokeServer() end end)
                    Utils.try(function() if boostEffect and boostEffect.InvokeServer then boostEffect:InvokeServer() end end)
                end)
            end
        else
            if activeConnections.Train then
                pcall(function() activeConnections.Train:Disconnect() end)
                activeConnections.Train = nil
            end
        end
    end)

    -- AntiFall Toggle
    State.onChange("AntiFall", function(enabled)
        if enabled then
            if not activeConnections.AntiFall then
                print("[Hooks]: Ativando AntiFall detection")
                Hooks.startAntiFallLoop()
            end
        else
            if activeConnections.AntiFall then
                pcall(function() activeConnections.AntiFall:Disconnect() end)
                activeConnections.AntiFall = nil
            end
        end
    end)

    -- AntiAFK Toggle
    State.onChange("AntiAFK", function(enabled)
        if enabled then
            if not activeConnections.AntiAFK then
                print("[Hooks]: Ativando AntiAFK")
                activeConnections.AntiAFK = player.Idled:Connect(function()
                    pcall(function()
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):ClickButton2(Vector2.new(0, 0))
                    end)
                end)
            end
        else
            if activeConnections.AntiAFK then
                pcall(function() activeConnections.AntiAFK:Disconnect() end)
                activeConnections.AntiAFK = nil
            end
        end
    end)

    -- GodExtreme Toggle
    State.onChange("GodExtreme", function(enabled)
        if enabled then
            if not activeConnections.GodExtreme then
                print("[Hooks]: Ativando GodExtreme")
                local adminRemote = game:GetService("ReplicatedStorage"):FindFirstChild("HNkAdminRemote")
                if adminRemote then
                    pcall(function() adminRemote:FireServer({action = "SetGodExtreme"}) end)
                end
                
                activeConnections.GodExtreme = RunService.Heartbeat:Connect(function()
                    local char = player.Character
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        pcall(function() hum.Health = hum.MaxHealth end)
                    end
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
            end
        else
            if activeConnections.GodExtreme then
                pcall(function() activeConnections.GodExtreme:Disconnect() end)
                activeConnections.GodExtreme = nil
                local adminRemote = game:GetService("ReplicatedStorage"):FindFirstChild("HNkAdminRemote")
                if adminRemote then
                    pcall(function() adminRemote:FireServer({action = "UnsetGodExtreme"}) end)
                end
            end
        end
    end)

    -- Invisible Toggle
    State.onChange("Invisible", function(enabled)
        if enabled then
            print("[Hooks]: Ativando Invisibility")
            local adminRemote = game:GetService("ReplicatedStorage"):FindFirstChild("HNkAdminRemote")
            if adminRemote then
                pcall(function() adminRemote:FireServer({action = "SetInvisible"}) end)
            end
        else
            print("[Hooks]: Desativando Invisibility")
            local adminRemote = game:GetService("ReplicatedStorage"):FindFirstChild("HNkAdminRemote")
            if adminRemote then
                pcall(function() adminRemote:FireServer({action = "UnsetInvisible"}) end)
            end
        end
    end)

    -- PerformanceOverlay Toggle
    State.onChange("PerformanceOverlay", function(enabled)
        if getgenv().HNkPerformanceOverlayLabel then
            getgenv().HNkPerformanceOverlayLabel.Visible = enabled
        end
    end)

    -- Speed/Jump Heartbeat (sempre ligado)
    State.onChange("Speed", function() end)
    State.onChange("Jump", function() end)
end

-- ===================================
-- MAIN LOOPS
-- ===================================

function Hooks.startESPLoop()
    if not getgenv().HNkESPPlayers then
        getgenv().HNkESPPlayers = {}
        getgenv().HNkESPPowerCache = {}
        getgenv().HNkESPRepCache = {}
    end

    -- Cache updater
    if activeConnections.ESPCache then
        getgenv().HNkESPCacheStop = true
        task.wait(0.1)
    end
    
    getgenv().HNkESPCacheStop = false
    activeConnections.ESPCache = task.spawn(function()
        while not getgenv().HNkESPCacheStop and State.get("ESP") and task.wait(0.5) do
            local myPowerText = "0"
            local pGui = player:FindFirstChild("PlayerGui")
            if pGui then
                local targetLabel = pGui:FindFirstChild("MainGui")
                    and pGui.MainGui:FindFirstChild("LeftFrame")
                    and pGui.MainGui.LeftFrame:FindFirstChild("LeftButtonArea")
                    and pGui.MainGui.LeftFrame.LeftButtonArea:FindFirstChild("PowerArea")
                    and pGui.MainGui.LeftFrame.LeftButtonArea.PowerArea:FindFirstChild("PowerButton")
                    and pGui.MainGui.LeftFrame.LeftButtonArea.PowerArea.PowerButton:FindFirstChild("PowerNum")
                if targetLabel and targetLabel:IsA("TextLabel") then myPowerText = targetLabel.Text end
            end
            getgenv().HNkESPPowerCache[player] = myPowerText

            for _, p in Players:GetPlayers() do
                if p ~= player then
                    local val = Utils.findEnemyPower(p)
                    if val then 
                        getgenv().HNkESPPowerCache[p] = Utils.formatNumber(val) 
                    else 
                        getgenv().HNkESPPowerCache[p] = "FAIL" 
                    end
                end
                local repVal = Utils.findPlayerStat(p, "Respect")
                getgenv().HNkESPRepCache[p] = repVal or 0
            end
        end
    end)

    -- Main ESP renderer
    activeConnections.ESP = RunService.Heartbeat:Connect(function()
        if not State.get("ESP") then return end
        
        for _, p in Players:GetPlayers() do
            if p == player and State.get("Invisible") then
                if getgenv().HNkESPPlayers[p] and getgenv().HNkESPPlayers[p].billboard then 
                    getgenv().HNkESPPlayers[p].billboard:Destroy() 
                end
                getgenv().HNkESPPlayers[p] = nil
                continue
            end

            if not p.Character or not p.Character:FindFirstChild("Head") then
                if getgenv().HNkESPPlayers[p] and getgenv().HNkESPPlayers[p].billboard then 
                    getgenv().HNkESPPlayers[p].billboard:Destroy() 
                end
                getgenv().HNkESPPlayers[p] = nil
                continue
            end

            local data = getgenv().HNkESPPlayers[p]
            if not data then
                local head = p.Character.Head
                local bill = Instance.new("BillboardGui", head)
                bill.Name = "HNkESP"
                bill.Size = UDim2.new(0, 200, 0, 70)
                bill.StudsOffset = Vector3.new(0, 3, 0)
                bill.AlwaysOnTop = true

                local name = Instance.new("TextLabel", bill)
                name.Size = UDim2.new(1, 0, 0.5, 0)
                name.Position = UDim2.new(0, 0, 0, 0)
                name.BackgroundTransparency = 1
                name.Text = p.DisplayName
                name.TextColor3 = Color3.new(1, 1, 1)
                name.Font = Enum.Font.GothamBold
                name.TextSize = 16
                name.TextStrokeTransparency = 0
                name.TextStrokeColor3 = Color3.new(0, 0, 0)

                local power = Instance.new("TextLabel", bill)
                power.Size = UDim2.new(1, 0, 0.5, 0)
                power.Position = UDim2.new(0, 0, 0.5, 0)
                power.BackgroundTransparency = 1
                power.Text = "0"
                power.TextColor3 = Color3.fromRGB(255, 100, 100)
                power.Font = Enum.Font.GothamBold
                power.TextSize = 18

                getgenv().HNkESPPlayers[p] = {billboard = bill, power = power, name = name}
                data = getgenv().HNkESPPlayers[p]
            end

            local playerReputation = getgenv().HNkESPRepCache[p] or 0
            local nameColor = Utils.getReputationColor(p, playerReputation, player)

            if data.name then
                data.name.TextColor3 = nameColor
            end

            if data and data.power and getgenv().HNkESPPowerCache[p] then
                local pText = getgenv().HNkESPPowerCache[p]
                data.power.Text = pText
                if string.find(pText, "⚡") then
                    data.power.TextStrokeTransparency = 0
                    data.power.TextStrokeColor3 = Color3.new(0, 0, 0)
                else
                    data.power.TextStrokeTransparency = 1
                end
            end
        end
    end)
end

function Hooks.startAntiFallLoop()
    local airtimeTracker = {}
    local lastY = {}

    activeConnections.AntiFall = RunService.Heartbeat:Connect(function(dt)
        if not State.get("AntiFall") then return end
        
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum then return end

        local onGround = false
        pcall(function() onGround = (hum.FloorMaterial ~= Enum.Material.Air) end)

        if not airtimeTracker[player] then airtimeTracker[player] = 0 end
        if onGround then
            airtimeTracker[player] = 0
        else
            airtimeTracker[player] = airtimeTracker[player] + dt
        end

        local velY = hrp.Velocity and hrp.Velocity.Y or 0
        if not lastY[player] then lastY[player] = velY end

        if airtimeTracker[player] > 2 and math.abs(velY) < 1 then
            pcall(function()
                if hum and hum.Health > 0 then hum.Health = hum.MaxHealth end
                if hrp and hrp:IsA("BasePart") then hrp.Velocity = Vector3.new(hrp.Velocity.X, 60, hrp.Velocity.Z) end
            end)
            airtimeTracker[player] = 0
        end

        pcall(function()
            if hum:GetState() == Enum.HumanoidStateType.FallingDown then
                if hum and hum.Health > 0 then hum.Health = hum.MaxHealth end
                if hrp and hrp:IsA("BasePart") then hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z) end
            end
        end)

        lastY[player] = velY
    end)
end

-- Universal Heartbeat loop (Speed, Jump, FOV, Train speed)
function Hooks.startUniversalLoop()
    local trainSystem = game:GetService("ReplicatedStorage"):WaitForChild("TrainSystem", 15):WaitForChild("Remote", 15)
    local speedRemote = trainSystem:WaitForChild("TrainSpeedHasChanged", 15)

    activeConnections.Universal = RunService.Heartbeat:Connect(function()
        -- Speed & Jump
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local hum = player.Character.Humanoid
            hum.WalkSpeed = State.get("Speed") and 120 or 16
            hum.JumpPower = State.get("Jump") and 150 or 50

            if State.get("God") then
                hum.BreakJointsOnDeath = false
            else
                if State.get("AntiFall") then 
                    hum.BreakJointsOnDeath = false 
                else 
                    hum.BreakJointsOnDeath = true 
                end
            end
        end

        -- Train speed
        if State.get("Train") or State.get("Speed") then 
            Utils.try(function() speedRemote:FireServer(9999) end) 
        end
        
        -- FOV camera
        if Camera and State.get("FOV") then
            if Camera.FieldOfView ~= State.get("FOV") then
                if Camera.CameraType ~= Enum.CameraType.Custom and Camera.CameraType ~= Enum.CameraType.Watch then
                    Camera.CameraType = Enum.CameraType.Custom
                end
                Camera.FieldOfView = State.get("FOV")
            end
        end
    end)
end

-- FOV Mouse Wheel Control
function Hooks.startFOVMouseControl()
    UserInputService.InputChanged:Connect(function(input)
        if not State.get("FOVMouseControl") then return end
        if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
        if Camera.CameraType == Enum.CameraType.Scriptable then return end
        
        local delta = input.Position.Z
        local fovChange = -delta * 5 

        local currentFOV = State.get("FOV")
        local newFOV = math.floor(math.clamp(currentFOV + fovChange, 70, 120) + 0.5)
        
        if newFOV ~= currentFOV then
            State.set("FOV", newFOV)
            Camera.FieldOfView = newFOV
        end
    end)
end

-- Performance Overlay Loop
function Hooks.startPerformanceOverlay()
    local CoreGui = game:GetService("CoreGui")
    
    local displayGui = Instance.new("ScreenGui")
    displayGui.Name = "HNkPerformanceOverlay"
    displayGui.Parent = CoreGui
    displayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("TextLabel", displayGui)
    frame.Size = UDim2.new(0, 150, 0, 40)
    frame.Position = UDim2.new(1, -160, 0, 10)
    frame.BackgroundTransparency = 0.8
    frame.BackgroundColor3 = Config.PRIMARY_BG
    frame.TextColor3 = Config.ACCENT_ON
    frame.Font = Enum.Font.SourceSansBold
    frame.TextSize = 14
    frame.TextXAlignment = Enum.TextXAlignment.Left
    frame.TextYAlignment = Enum.TextYAlignment.Top
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
    
    getgenv().HNkPerformanceOverlayLabel = frame
    frame.Visible = State.get("PerformanceOverlay")
    
    local fps = 0
    local frameCount = 0
    local lastFPSTime = tick()
    local FPS_INTERVAL = 0.5
    
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        local elapsed = now - lastFPSTime
        if elapsed >= FPS_INTERVAL then
            fps = math.floor(frameCount / elapsed + 0.5)
            frameCount = 0
            lastFPSTime = now
        end
    end)
    
    activeConnections.PerformanceOverlay = task.spawn(function()
        while State.get("PerformanceOverlay") and task.wait(0.3) do
            if getgenv().HNkPerformanceOverlayLabel and getgenv().HNkPerformanceOverlayLabel.Visible then
                local pingMs = 0
                local ok, pingVal = pcall(function() 
                    return Players.LocalPlayer and Players.LocalPlayer:GetNetworkPing() 
                end)
                if ok and type(pingVal) == "number" then
                    pingMs = math.floor(pingVal * 1000 + 0.5)
                end
                getgenv().HNkPerformanceOverlayLabel.Text = string.format("FPS: %d\nPING: %d ms", fps, pingMs)
            end
        end
    end)
end

-- ===================================
-- INITIALIZATION
-- ===================================

function Hooks.init()
    print("[Hooks]: Inicializando listeners e loops...")
    
    -- Aguardar State estar pronto
    local attempts = 0
    while not getgenv().HNkState and attempts < 50 do
        task.wait(0.05)
        attempts = attempts + 1
    end
    
    if not getgenv().HNkState then
        error("[Hooks]: State não foi carregado!")
    end
    
    local State = getgenv().HNkState
    
    -- Setup state listeners
    Hooks.setupStateListeners()
    
    -- Start universal loop (sempre ativo)
    Hooks.startUniversalLoop()
    
    -- Start FOV mouse control
    Hooks.startFOVMouseControl()
    
    -- Start Performance Overlay
    Hooks.startPerformanceOverlay()
    
    -- Activate features que estão habilitadas por padrão
    if State.get("ESP") then
        print("[Hooks]: ESP ativado por padrão")
        Hooks.startESPLoop()
    end
    
    if State.get("God") then
        print("[Hooks]: God Mode ativado por padrão")
        State.set("God", true)
    end
    
    if State.get("Train") then
        print("[Hooks]: Train ativado por padrão")
        State.set("Train", true)
    end
    
    if State.get("AntiFall") then
        print("[Hooks]: AntiFall ativado por padrão")
        Hooks.startAntiFallLoop()
    end
    
    print("[Hooks]: ✅ Hooks inicializados com sucesso!")
end

return Hooks
