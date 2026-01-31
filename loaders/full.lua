print("HNk TTF HUB v9.4.3 loading: Full client with admin remote hooks.")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

-- ===================================
-- 1. REMOTE CONFIGURATION (Mantido)
-- ===================================
local trainEquipment = ReplicatedStorage:WaitForChild("TrainEquipment", 15):WaitForChild("Remote", 15)
local trainSystem = ReplicatedStorage:WaitForChild("TrainSystem", 15):WaitForChild("Remote", 15)

local takeUp = trainEquipment:WaitForChild("ApplyTakeUpStationaryTrainEquipment", 15)
local statEffect = trainEquipment:WaitForChild("ApplyBindingTrainingEffect", 15)
local boostEffect = trainEquipment:WaitForChild("ApplyBindingTrainingBoostEffect", 15)
local speedRemote = trainSystem:WaitForChild("TrainSpeedHasChanged", 15)

-- Remote expected on server
local adminRemote = ReplicatedStorage:FindFirstChild("HNkAdminRemote")

-- ===================================
-- 2. UTILITY CONFIGURATIONS AND FUNCTIONS
-- ===================================

-- Tema fixo: preto com detalhes vermelho (sem temas customizáveis)
local ACCENT_ON = Color3.fromRGB(255, 60, 60) -- Vermelho para ON/accentos
local ACCENT_OFF = Color3.fromRGB(100, 100, 100) -- Cinza para OFF
local PRIMARY_BG = Color3.fromRGB(15, 15, 15) -- Preto principal
local DARK_BG = Color3.fromRGB(25, 25, 25) -- Preto mais claro para elementos

local FILE_NAME = "HNkTTF_config.json"
local activeConnections = {}
local _invisibleOriginalProps = {} -- store original props to restore on disable
local _godExtremeOriginalProps = {} -- store original props for GodExtreme

local function try(f, ...)
    local success, err = pcall(f, ...)
    if not success then warn("[SafeAutoTrain ERROR]:", err) end
end

local function getNumericValue(inst)
    if inst and (inst:IsA("IntValue") or inst:IsA("NumberValue")) then
        return inst.Value
    elseif inst and inst:IsA("StringValue") then
        return tonumber(inst.Value)
    end
    return nil
end

local function findPlayerStat(targetPlayer, statName)
    local containers = {targetPlayer:FindFirstChild("AttrConfig"), targetPlayer:FindFirstChild("leaderstats")}
    for _, folder in ipairs(containers) do
        if folder then
            for _, child in folder:GetChildren() do
                if child.Name == statName then
                    return getNumericValue(child)
                end
            end
        end
    end
    return nil
end

local function findEnemyPower(targetPlayer)
    local highestValue = 0
    local currentMaxHealth = 100
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
        currentMaxHealth = targetPlayer.Character.Humanoid.MaxHealth
    end
    local containers = {targetPlayer:FindFirstChild("AttrConfig"), targetPlayer:FindFirstChild("leaderstats")}
    for _, folder in ipairs(containers) do
        if folder then
            for _, child in folder:GetChildren() do
                local val = getNumericValue(child)
                if val and val > currentMaxHealth and val > highestValue then highestValue = val end
            end
        end
    end
    return highestValue > 0 and highestValue or nil
end

-- KOZLOV ally green, remove NOTORIOUS special-case, 1Qi+ => YELLOW
local function getReputationColor(targetPlayer, reputation)
    local MIN_REP_GRADIENT = 5000
    local MAX_REP_GRADIENT = 1000000
    local QI_REP_THRESHOLD = 1e18 -- 1 Quintilhão (1 Qi)

    local dn = ""
    if targetPlayer and targetPlayer.DisplayName then dn = targetPlayer.DisplayName:upper() end

    -- Preserve self / KOZLOV green
    if targetPlayer == player or (dn and string.find(dn, "KOZLOV")) then
        return Color3.fromRGB(0, 150, 0) -- KOZLOV verde (e você)
    end

    -- Normalize reputation to number if possible (handles strings)
    local repNum = reputation
    if type(repNum) ~= "number" then
        repNum = tonumber(repNum)
    end

    -- REP >= 1Qi => YELLOW
    if repNum and repNum >= QI_REP_THRESHOLD then
        return Color3.fromRGB(255, 215, 0) -- Amarelo (Gold)
    end

    -- Gradiente padrão
    if repNum and repNum >= MIN_REP_GRADIENT then
        local ratio = math.min(1, (repNum - MIN_REP_GRADIENT) / (MAX_REP_GRADIENT - MIN_REP_GRADIENT))
        local r = 255
        local g = 150 * (1 - ratio)
        local b = 200 + 55 * ratio
        return Color3.fromRGB(r, g, b)
    else
        return Color3.new(1, 1, 1)
    end
end

local units = {
    "k", "M", "B", "T", "Qa", "Qi", "Aa", "Ab", "Ac", "Ad",
    "Ae", "Af", "Ag", "Ah", "Ai", "Aj", "Ak", "Al", "Am", "An", "Ao", "Ap"
}

local function formatNumber(num)
    if type(num) ~= "number" then return tostring(num) end
    if num < 1000 then return tostring(math.floor(num)) end
    local exp = math.log10(num)
    local order = math.floor(exp / 3)
    if order > 0 then
        if order <= #units then
            local unit = units[order]
            local scaled = num / (10 ^ (order * 3))
            local formatted = string.format("%.2f %s", scaled, unit)
            if order >= 13 then return "⚡ " .. formatted end
            return formatted
        else
            return "⚡ " .. string.format("%.2fe%.0f", num / (10 ^ exp), exp)
        end
    end
    return tostring(num)
end

-- ===================================
-- REP RGB PARSING FUNCTIONS (v9.4.9)
-- ===================================
local multipliers = {}
do
    for i, u in ipairs(units) do
        multipliers[u] = 10 ^ (i * 3)
        multipliers[u:upper()] = multipliers[u]
        multipliers[u:lower()] = multipliers[u]
    end
    multipliers["K"] = multipliers["k"]
end

local TARGET_REP_THRESHOLD = 1e18 -- 1 Quintilhão (Qi)

local function parseHumanNumber(val)
    if val == nil then return nil end
    if type(val) == "number" then return val end
    local s = tostring(val)
    s = s:gsub("⚡", ""):gsub(",", ""):match("^%s*(.-)%s*$") or s

    local n = tonumber(s)
    if n then return n end

    local num, unit = s:match("([%-%d%.]+)%s*([%a]+)")
    if num and unit then
        local mult = multipliers[unit] or multipliers[unit:upper()] or multipliers[unit:lower()]
        if mult then
            local nf = tonumber(num)
            if nf then return nf * mult end
        end
    end

    local unit2, num2 = s:match("([%a]+)%s*([%-%d%.]+)")
    if unit2 and num2 then
        local mult = multipliers[unit2] or multipliers[unit2:upper()] or multipliers[unit2:lower()]
        if mult then
            local nf = tonumber(num2)
            if nf then return nf * mult end
        end
    end

    local onlyDigits = s:match("([%-%d%.]+)")
    if onlyDigits then return tonumber(onlyDigits) end

    return nil
end

local function getRespectValue(targetPlayer)
    if not targetPlayer then return 0 end
    
    -- Tenta atributo primeiro
    local attr = targetPlayer:GetAttribute("Respect")
    if attr ~= nil then
        if type(attr) == "number" then 
            print("[getRespectValue] Found via Attribute: " .. tostring(attr))
            return attr 
        end
        local n = parseHumanNumber(attr)
        if n then 
            print("[getRespectValue] Found via Attribute (parsed): " .. tostring(n))
            return n 
        end
        return tonumber(attr) or 0
    end

    -- Procura em containers conhecidos
    local containers = { targetPlayer:FindFirstChild("AttrConfig"), targetPlayer:FindFirstChild("leaderstats") }
    for _, folder in ipairs(containers) do
        if folder then
            local stat = folder:FindFirstChild("Respect")
            if stat then
                if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                    print("[getRespectValue] Found in " .. folder.Name .. " as Value: " .. tostring(stat.Value))
                    return stat.Value
                elseif stat:IsA("StringValue") then
                    local parsed = parseHumanNumber(stat.Value)
                    if parsed then 
                        print("[getRespectValue] Found in " .. folder.Name .. " as StringValue (parsed): " .. tostring(parsed))
                        return parsed 
                    end
                    return tonumber(stat.Value) or 0
                end
            end
        end
    end
    
    -- Se não encontrou, procura por qualquer thing que tenha "Respect" no nome
    print("[getRespectValue] Normal search failed for " .. targetPlayer.DisplayName .. ", searching all descendants...")
    for _, descendant in pairs(targetPlayer:GetDescendants()) do
        if descendant.Name:lower():find("respect") then
            print("[getRespectValue] Found descendant with respect: " .. descendant.Name .. " (" .. descendant.ClassName .. ")")
            if descendant:IsA("IntValue") or descendant:IsA("NumberValue") then
                print("[getRespectValue] Final value from descendant: " .. tostring(descendant.Value))
                return descendant.Value
            elseif descendant:IsA("StringValue") then
                local parsed = parseHumanNumber(descendant.Value)
                if parsed then return parsed end
                return tonumber(descendant.Value) or 0
            end
        end
    end

    print("[getRespectValue] No respect found for " .. targetPlayer.DisplayName)
    return 0
end

-- ===================================
-- 3. PERSISTENCE AND TOGGLE LOGIC
-- ===================================

getgenv().HNk = {
    ESP = true, God = true, GodExtreme = true, Speed = false, Jump = false, Train = false,
    AntiAFK = true, AntiFall = true, PerformanceOverlay = true,
    FOV = 90, FOVMouseControl = false, MinimalMode = false,
    Invisible = true
}

local isFileSupport = (pcall(function() readfile() end) and pcall(function() writefile() end)) or false

local function SaveConfig()
    if isFileSupport then
        local data = HttpService:JSONEncode(getgenv().HNk)
        writefile(FILE_NAME, data)
    end
end

local function LoadConfig()
    if isFileSupport and readfile(FILE_NAME) then
        local data = readfile(FILE_NAME)
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, data)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if getgenv().HNk[k] ~= nil and type(getgenv().HNk[k]) == type(v) then
                    getgenv().HNk[k] = v
                end
            end
            print("[HNk Config]: Configurations loaded successfully.")
        else
            warn("[HNk Config]: Failed to decode configurations, using defaults.")
        end
    else
        warn("[HNk Config]: Configuration file not found or file support unavailable, using defaults.")
    end
end

-- Enhanced Anti-Fall/Stuck detection (will be connected when toggled on)
local function enableAntiFallDetection()
    if activeConnections._AntiFallChecker then return end
    local airtimeTracker = {}
    local lastY = {}

    activeConnections._AntiFallChecker = RunService.Heartbeat:Connect(function(dt)
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
                if hum and hum.Health > 0 then
                    hum.Health = hum.MaxHealth
                end
                if hrp and hrp:IsA("BasePart") then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 60, hrp.Velocity.Z)
                end
            end)
            airtimeTracker[player] = 0
        end

        pcall(function()
            if hum:GetState() == Enum.HumanoidStateType.FallingDown then
                if hum and hum.Health > 0 then
                    hum.Health = hum.MaxHealth
                end
                if hrp and hrp:IsA("BasePart") then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
                end
            end
        end)

        lastY[player] = velY
    end)
end

local function disableAntiFallDetection()
    if activeConnections._AntiFallChecker then
        pcall(function() activeConnections._AntiFallChecker:Disconnect() end)
        activeConnections._AntiFallChecker = nil
    end
end

-- send admin remote helper (client -> server)
local function sendAdminRemote(action)
    if not adminRemote then
        warn("Admin remote not found in ReplicatedStorage (HNkAdminRemote). Server script may be missing.")
        return
    end
    pcall(function() adminRemote:FireServer({action = action}) end)
end

local function HandleToggleLogic(name)
    if activeConnections[name] then
        pcall(function() activeConnections[name]:Disconnect() end)
        activeConnections[name] = nil
    end

    if getgenv().HNk[name] then
        if name == "Train" then
            activeConnections.Train = RunService.Heartbeat:Connect(function()
                try(function() if takeUp and takeUp.InvokeServer then takeUp:InvokeServer(true) end end)
                try(function() if statEffect and statEffect.InvokeServer then statEffect:InvokeServer() end end)
                try(function() if boostEffect and boostEffect.InvokeServer then boostEffect:InvokeServer() end end)
            end)
        elseif name == "AntiAFK" then
            activeConnections.AntiAFK = player.Idled:Connect(function()
                game:GetService("VirtualUser"):CaptureController(); game:GetService("VirtualUser"):ClickButton2(Vector2.new(0, 0))
            end)
        elseif name == "AntiFall" then
            enableAntiFallDetection()
        elseif name == "MinimalMode" then
            -- handled in GUI visuals
        elseif name == "God" then
            activeConnections.God = RunService.Heartbeat:Connect(function()
                local char = player.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function() hum.Health = hum.MaxHealth; hum.BreakJointsOnDeath = false end)
                end
            end)
        elseif name == "GodExtreme" then
            sendAdminRemote("SetGodExtreme")
            activeConnections.GodExtremeLocal = RunService.Heartbeat:Connect(function()
                local char = player.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum.Health = hum.MaxHealth end) end
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        elseif name == "Invisible" then
            sendAdminRemote("SetInvisible")
        elseif name == "ESP" then
            -- Handled in loop
        elseif name == "PerformanceOverlay" then
            -- Handled in overlay task
        elseif name == "FOVMouseControl" then
            -- Handled in input connect
        elseif name == "Speed" then
            -- Handled in heartbeat
        elseif name == "Jump" then
            -- Handled in heartbeat
        end
    else
        if name == "AntiFall" then
            disableAntiFallDetection()
        elseif name == "God" then
            if activeConnections.God then pcall(function() activeConnections.God:Disconnect() end) end
            activeConnections.God = nil
        elseif name == "GodExtreme" then
            sendAdminRemote("UnsetGodExtreme")
            if activeConnections.GodExtremeLocal then pcall(function() activeConnections.GodExtremeLocal:Disconnect() end) end
            activeConnections.GodExtremeLocal = nil
        elseif name == "Invisible" then
            sendAdminRemote("UnsetInvisible")
        end
    end
    SaveConfig()
end

-- Initialize toggles that are boolean except some special visuals
LoadConfig()
for name, value in pairs(getgenv().HNk) do
    if type(value) == "boolean" then
        HandleToggleLogic(name)
    end
end

-- ===================================
-- 5. NOVA GUI: Leve, funcional, bonita (tema preto com detalhes vermelho, moderna)
-- ===================================
local sg = Instance.new("ScreenGui"); sg.Name = "HNkHubModern"; sg.Parent = CoreGui; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 250, 0, 400)
main.Position = UDim2.new(1, -500, 0, 10)
main.BackgroundColor3 = PRIMARY_BG -- Preto
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
local corner = Instance.new("UICorner", main); corner.CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", main); stroke.Color = ACCENT_ON; stroke.Transparency = 0.5; stroke.Thickness = 1.5

local titleFrame = Instance.new("Frame", main)
titleFrame.Size = UDim2.new(1, 0, 0, 50)
titleFrame.BackgroundColor3 = DARK_BG -- Preto claro
local titleCorner = Instance.new("UICorner", titleFrame); titleCorner.CornerRadius = UDim.new(0, 12)
local titleStroke = Instance.new("UIStroke", titleFrame); titleStroke.Color = ACCENT_ON; titleStroke.Transparency = 0.7

local titleLabel = Instance.new("TextLabel", titleFrame)
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "HNk Hub v9.4.3"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -45, 0.5, -15)
closeBtn.BackgroundColor3 = ACCENT_ON -- Vermelho
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
local closeCorner = Instance.new("UICorner", closeBtn); closeCorner.CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

local minBtn = Instance.new("TextButton", titleFrame)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -80, 0.5, -15)
minBtn.BackgroundColor3 = ACCENT_ON -- Vermelho
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
local minCorner = Instance.new("UICorner", minBtn); minCorner.CornerRadius = UDim.new(0, 6)
local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        main.Size = UDim2.new(0, 250, 0, 50)
        scroll.Visible = false
        minBtn.Text = "+"
    else
        main.Size = UDim2.new(0, 250, 0, 400)
        scroll.Visible = true
        minBtn.Text = "-"
    end
end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -70)
scroll.Position = UDim2.new(0, 10, 0, 60)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = ACCENT_ON -- Vermelho
scroll.ScrollBarImageTransparency = 0.5

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Função para criar toggles modernos
local function createToggle(name, prop, icon)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundColor3 = DARK_BG
    local toggleCorner = Instance.new("UICorner", toggleFrame); toggleCorner.CornerRadius = UDim.new(0, 8)
    local toggleStroke = Instance.new("UIStroke", toggleFrame); toggleStroke.Color = ACCENT_OFF; toggleStroke.Transparency = 0.8

    local toggleLabel = Instance.new("TextLabel", toggleFrame)
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = icon .. " " .. name
    toggleLabel.TextColor3 = Color3.new(1, 1, 1)
    toggleLabel.Font = Enum.Font.GothamSemibold
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton", toggleFrame)
    toggleBtn.Size = UDim2.new(0.2, 0, 0.6, 0)
    toggleBtn.Position = UDim2.new(0.75, 0, 0.2, 0)
    toggleBtn.BackgroundColor3 = ACCENT_OFF
    toggleBtn.Text = ""
    local btnCorner = Instance.new("UICorner", toggleBtn); btnCorner.CornerRadius = UDim.new(0, 20)

    local toggleCircle = Instance.new("Frame", toggleBtn)
    toggleCircle.Size = UDim2.new(0, 20, 1, 0)
    toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleCircle.Position = UDim2.new(0, 0, 0, 0)
    local circleCorner = Instance.new("UICorner", toggleCircle); circleCorner.CornerRadius = UDim.new(0, 20)

    local function updateToggle()
        local state = getgenv().HNk[prop]
        toggleBtn.BackgroundColor3 = state and ACCENT_ON or ACCENT_OFF
        toggleCircle.Position = state and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)
        toggleStroke.Color = state and ACCENT_ON or ACCENT_OFF
    end

    toggleBtn.MouseButton1Click:Connect(function()
        getgenv().HNk[prop] = not getgenv().HNk[prop]
        updateToggle()
        HandleToggleLogic(prop)
    end)

    updateToggle()
    toggleFrame.Parent = scroll
end

-- Função para criar slider moderno (para FOV)
local function createSlider(name, prop, min, max, icon)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    sliderFrame.BackgroundColor3 = DARK_BG
    local sliderCorner = Instance.new("UICorner", sliderFrame); sliderCorner.CornerRadius = UDim.new(0, 8)
    local sliderStroke = Instance.new("UIStroke", sliderFrame); sliderStroke.Color = ACCENT_OFF; sliderStroke.Transparency = 0.8

    local sliderLabel = Instance.new("TextLabel", sliderFrame)
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = icon .. " " .. name .. " [" .. getgenv().HNk[prop] .. "]"
    sliderLabel.TextColor3 = Color3.new(1, 1, 1)
    sliderLabel.Font = Enum.Font.GothamSemibold
    sliderLabel.TextSize = 14
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBar = Instance.new("Frame", sliderFrame)
    sliderBar.Size = UDim2.new(0.9, 0, 0.15, 0)
    sliderBar.Position = UDim2.new(0.05, 0, 0.6, 0)
    sliderBar.BackgroundColor3 = ACCENT_OFF
    local barCorner = Instance.new("UICorner", sliderBar); barCorner.CornerRadius = UDim.new(0, 4)

    local sliderFill = Instance.new("Frame", sliderBar)
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = ACCENT_ON
    local fillCorner = Instance.new("UICorner", sliderFill); fillCorner.CornerRadius = UDim.new(0, 4)

    local sliderButton = Instance.new("TextButton", sliderBar)
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    sliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    sliderButton.Text = ""
    local btnCorner = Instance.new("UICorner", sliderButton); btnCorner.CornerRadius = UDim.new(0, 8)
    local isDragging = false

    local function updateSliderValue(newValue)
        getgenv().HNk[prop] = newValue
        SaveConfig()
        local ratio = (newValue - min) / (max - min)
        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        sliderButton.Position = UDim2.new(ratio, 0, 0.5, 0)
        sliderLabel.Text = icon .. " " .. name .. " [" .. newValue .. "]"
        if prop == "FOV" then
            Camera.FieldOfView = newValue
        end
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)

    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            local newValue = math.floor(min + relativeX * (max - min))
            updateSliderValue(newValue)
        end
    end)

    -- Inicializa o slider com valor atual
    updateSliderValue(getgenv().HNk[prop])

    sliderFrame.Parent = scroll
end

-- Cria os elementos da GUI agrupados por seções (sem tabs, mas com labels de seção para organização)
local function createSectionLabel(text)
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(1, 0, 0, 25)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = text:upper()
    sectionLabel.TextColor3 = ACCENT_ON -- Vermelho
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextSize = 12
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = scroll
end

-- Seção Shadow Core
createSectionLabel("Shadow Core")
createToggle("Train", "Train", "⚔️")
createToggle("AntiAFK", "AntiAFK", "⏳")
createToggle("AntiFall", "AntiFall", "💀")

-- Seção Visuals
createSectionLabel("Visuals")
createToggle("ESP", "ESP", "👁️‍🗨️")
createToggle("PerformanceOverlay", "PerformanceOverlay", "📊")
createToggle("FOVMouseControl", "FOVMouseControl", "🖱️")
createToggle("MinimalMode", "MinimalMode", "🔲")
createSlider("FOV", "FOV", 70, 120, "🔭")

-- Seção Player
createSectionLabel("Player")
createToggle("God", "God", "🛡️")
createToggle("GodExtreme", "GodExtreme", "🦾")
createToggle("Speed", "Speed", "🏃‍♂️")
createToggle("Jump", "Jump", "⬆️")
createToggle("Invisible", "Invisible", "👻")

-- Atualiza o CanvasSize após adicionar todos os elementos
scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)

-- ===================================
-- 6. MAIN LOOPS (Mantido + Overlay FPS/PING)
-- ===================================

local ESP_Players = {}
local ESP_Power_Cache = {}
local ESP_Rep_Cache = {}

task.spawn(function()
    local displayGui = Instance.new("ScreenGui"); displayGui.Name = "HNkPerformanceOverlay"; displayGui.Parent = CoreGui; displayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("TextLabel", displayGui)
    frame.Size = UDim2.new(0, 150, 0, 40)
    frame.Position = UDim2.new(1, -160, 0, 10)
    frame.BackgroundTransparency = 0.8
    frame.BackgroundColor3 = PRIMARY_BG 
    frame.TextColor3 = ACCENT_ON
    frame.Font = Enum.Font.SourceSansBold
    frame.TextSize = 14
    frame.TextXAlignment = Enum.TextXAlignment.Left
    frame.TextYAlignment = Enum.TextYAlignment.Top
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
    
    performanceOverlayLabel = frame
    performanceOverlayLabel.Visible = getgenv().HNk.PerformanceOverlay

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

    while task.wait(0.3) do
        if getgenv().HNk.PerformanceOverlay and performanceOverlayLabel and performanceOverlayLabel.Visible then
            local pingMs = 0
            local ok, pingVal = pcall(function() return Players.LocalPlayer and Players.LocalPlayer:GetNetworkPing() end)
            if ok and type(pingVal) == "number" then
                pingMs = math.floor(pingVal * 1000 + 0.5)
            else
                pingMs = 0
            end
            performanceOverlayLabel.Text = string.format("FPS: %d\nPING: %d ms", fps, pingMs)
        end
    end

    if renderConn then
        pcall(function() renderConn:Disconnect() end)
    end
end)

task.spawn(function()
    print("[ESP Cache Loop] Starting...")
    while task.wait(0.5) do
        if getgenv().HNk.ESP then
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
            ESP_Power_Cache[player] = myPowerText
            
            local playerCount = #Players:GetPlayers()
            for _, p in Players:GetPlayers() do
                if p ~= player then
                    local val = findEnemyPower(p)
                    ESP_Power_Cache[p] = val and formatNumber(val) or "?"
                end
                -- Atualiza cache de reputation usando getRespectValue()
                local repVal = getRespectValue(p)
                ESP_Rep_Cache[p] = repVal or 0
            end
            print("[ESP Cache] Updated for " .. playerCount .. " players, ESP enabled: " .. tostring(getgenv().HNk.ESP))
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not getgenv().HNk.FOVMouseControl then return end
    if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
    if Camera.CameraType == Enum.CameraType.Scriptable then return end
    
    local delta = input.Position.Z
    local fovChange = -delta * 5 

    local currentFOV = getgenv().HNk.FOV
    local newFOV = math.floor(math.clamp(currentFOV + fovChange, 70, 120) + 0.5)
    
    if newFOV ~= currentFOV then
        getgenv().HNk.FOV = newFOV
        SaveConfig()
        
        Camera.FieldOfView = newFOV
    end
end)

RunService.Heartbeat:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        hum.WalkSpeed = getgenv().HNk.Speed and 120 or 16
        hum.JumpPower = getgenv().HNk.Jump and 150 or 50

        if getgenv().HNk.God then
            hum.BreakJointsOnDeath = false
        else
            if getgenv().HNk.AntiFall then hum.BreakJointsOnDeath = false else hum.BreakJointsOnDeath = true end
        end
    end
    if getgenv().HNk.Train or getgenv().HNk.Speed then try(speedRemote.FireServer, speedRemote, 9999) end
    
    if Camera and getgenv().HNk.FOV then
        if Camera.FieldOfView ~= getgenv().HNk.FOV then
             if Camera.CameraType ~= Enum.CameraType.Custom and Camera.CameraType ~= Enum.CameraType.Watch then
                 Camera.CameraType = Enum.CameraType.Custom
             end
             Camera.FieldOfView = getgenv().HNk.FOV
        end
    end
end)

RunService.Heartbeat:Connect(function()
    pcall(function()
        if not getgenv().HNk.ESP then
            for _, data in pairs(ESP_Players) do 
                if data and data.billboard then 
                    pcall(function() data.billboard:Destroy() end)
                end 
            end
            ESP_Players = {}
            return
        end
        
        -- RGB Hue cycling para REP elite
        local hue = (tick() % 5) / 5
        local rgbColor = Color3.fromHSV(hue, 1, 1)
        
        for _, p in Players:GetPlayers() do
            if p == player and getgenv().HNk.Invisible then
                if ESP_Players[p] and ESP_Players[p].billboard then 
                    pcall(function() ESP_Players[p].billboard:Destroy() end)
                end
                ESP_Players[p] = nil
                continue
            end

            if not p.Character or not p.Character:FindFirstChild("Head") then
                if ESP_Players[p] and ESP_Players[p].billboard then 
                    pcall(function() ESP_Players[p].billboard:Destroy() end)
                end
                ESP_Players[p] = nil
                continue
            end
            
            local data = ESP_Players[p]
            if not data then
                pcall(function()
                    local head = p.Character.Head
                    local bill = Instance.new("BillboardGui")
                    bill.Parent = head
                    bill.Name = "HNkESP"
                    bill.Size = UDim2.new(0, 200, 0, 70)
                    bill.StudsOffset = Vector3.new(0, 3, 0)
                    bill.AlwaysOnTop = true
                    bill.MaxDistance = math.huge
                    
                    local name = Instance.new("TextLabel")
                    name.Parent = bill
                    name.Size = UDim2.new(1, 0, 0.5, 0)
                    name.Position = UDim2.new(0, 0, 0, 0)
                    name.BackgroundTransparency = 1
                    name.Text = p.DisplayName
                    name.TextColor3 = Color3.new(1, 1, 1)
                    name.Font = Enum.Font.GothamBold
                    name.TextSize = 16
                    name.TextStrokeTransparency = 0
                    name.TextStrokeColor3 = Color3.new(0, 0, 0)
                    
                    local power = Instance.new("TextLabel")
                    power.Parent = bill
                    power.Size = UDim2.new(1, 0, 0.5, 0)
                    power.Position = UDim2.new(0, 0, 0.5, 0)
                    power.BackgroundTransparency = 1
                    power.Text = "?"
                    power.TextColor3 = Color3.fromRGB(255, 100, 100)
                    power.Font = Enum.Font.GothamBold
                    power.TextSize = 18
                    
                    ESP_Players[p] = {billboard = bill, power = power, name = name}
                    if not ESP_Power_Cache[p] then ESP_Power_Cache[p] = "?" end
                    data = ESP_Players[p]
                    
                    print("[ESP Created] BillboardGui for " .. p.DisplayName)
                end)
            end
            
            if data then
                pcall(function()
                    -- Busca reputação com parsing robusto
                    local playerReputation = getRespectValue(p)
                    local repNum = playerReputation
                    
                    -- Debug print
                    if not ESP_Players[p]._debugPrinted then
                        print("[ESP DEBUG] Player: " .. p.DisplayName .. ", Raw Rep: " .. tostring(playerReputation) .. ", Type: " .. type(playerReputation))
                        ESP_Players[p]._debugPrinted = true
                    end
                    
                    -- Normaliza para número
                    if type(repNum) ~= "number" then 
                        repNum = parseHumanNumber(repNum) or tonumber(repNum) 
                    end
                    if repNum then 
                        repNum = math.abs(repNum) 
                    else
                        repNum = 0
                    end
                    
                    print("[ESP] Checking " .. p.DisplayName .. ": repNum=" .. tostring(repNum) .. ", threshold=" .. tostring(TARGET_REP_THRESHOLD) .. ", isElite=" .. tostring(repNum >= TARGET_REP_THRESHOLD))
                    
                    -- Se REP >= TARGET_REP_THRESHOLD -> modo REP RGB elite
                    if repNum and repNum >= TARGET_REP_THRESHOLD then
                        print("[ESP ELITE] " .. p.DisplayName .. " é ELITE! REP: " .. tostring(repNum))
                        
                        -- Oculta nome
                        data.name.Visible = false
                        data.name.Text = ""
                        
                        -- Mostra apenas "REP" em RGB (reduzido para metade)
                        data.power.Visible = true
                        data.power.Text = "REP"
                        data.power.TextColor3 = rgbColor
                        data.power.TextSize = 14  -- metade do tamanho
                        data.power.Position = UDim2.new(0, 0, 0.25, 0)
                    else
                        -- Modo normal: nome + poder formatado
                        local nameColor = getReputationColor(p, repNum or 0)
                        
                        data.name.Visible = true
                        data.name.Text = p.DisplayName
                        data.name.TextColor3 = nameColor
                        data.name.TextSize = 16

                        -- Exibe REP formatado
                        local repDisplay = ""
                        if type(repNum) == "number" and repNum > 0 then
                            repDisplay = "REP: " .. formatNumber(repNum)
                        else
                            repDisplay = ESP_Power_Cache[p] or "?"
                        end
                        data.power.Visible = true
                        data.power.Text = repDisplay
                        data.power.TextColor3 = (repNum and repNum >= 1e18) and Color3.fromRGB(255, 0, 0) or Color3.new(1,1,1)
                        data.power.TextSize = 16
                        data.power.Position = UDim2.new(0, 0, 0.5, 0)
                    end
                end)
            end
        end
    end)
end)

print("HNk TTF HUB v9.4.3 FINAL ACTIVE! GUI fully initialized and stable.")
