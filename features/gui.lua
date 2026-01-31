-- ===================================
-- GUI MODULE
-- ===================================

local Config
if getgenv().HNkConfig then
    Config = getgenv().HNkConfig
else
    Config = require(script.Parent.Parent:WaitForChild("core"):WaitForChild("config"))
end

local State
if getgenv().HNkState then
    State = getgenv().HNkState
else
    State = require(script.Parent.Parent:WaitForChild("core"):WaitForChild("state"))
end

local UserInputService = game:GetService("UserInputService")

local GUI = {}

function GUI.createToggle(name, prop, icon, scroll)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundColor3 = Config.DARK_BG
    local toggleCorner = Instance.new("UICorner", toggleFrame)
    toggleCorner.CornerRadius = UDim.new(0, 8)
    local toggleStroke = Instance.new("UIStroke", toggleFrame)
    toggleStroke.Color = Config.ACCENT_OFF
    toggleStroke.Transparency = 0.8

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
    toggleBtn.BackgroundColor3 = Config.ACCENT_OFF
    toggleBtn.Text = ""
    local btnCorner = Instance.new("UICorner", toggleBtn)
    btnCorner.CornerRadius = UDim.new(0, 20)

    local toggleCircle = Instance.new("Frame", toggleBtn)
    toggleCircle.Size = UDim2.new(0, 20, 1, 0)
    toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleCircle.Position = UDim2.new(0, 0, 0, 0)
    local circleCorner = Instance.new("UICorner", toggleCircle)
    circleCorner.CornerRadius = UDim.new(0, 20)

    local function updateToggle()
        local state = State.get(prop)
        toggleBtn.BackgroundColor3 = state and Config.ACCENT_ON or Config.ACCENT_OFF
        toggleCircle.Position = state and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)
        toggleStroke.Color = state and Config.ACCENT_ON or Config.ACCENT_OFF
    end

    toggleBtn.MouseButton1Click:Connect(function()
        State.set(prop, not State.get(prop))
        updateToggle()
    end)

    -- Listener para mudanças externas
    State.onChange(prop, function()
        updateToggle()
    end)

    updateToggle()
    toggleFrame.Parent = scroll
end

function GUI.createSlider(name, prop, min, max, icon, scroll)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    sliderFrame.BackgroundColor3 = Config.DARK_BG
    local sliderCorner = Instance.new("UICorner", sliderFrame)
    sliderCorner.CornerRadius = UDim.new(0, 8)
    local sliderStroke = Instance.new("UIStroke", sliderFrame)
    sliderStroke.Color = Config.ACCENT_OFF
    sliderStroke.Transparency = 0.8

    local sliderLabel = Instance.new("TextLabel", sliderFrame)
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = icon .. " " .. name .. " [" .. State.get(prop) .. "]"
    sliderLabel.TextColor3 = Color3.new(1, 1, 1)
    sliderLabel.Font = Enum.Font.GothamSemibold
    sliderLabel.TextSize = 14
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBar = Instance.new("Frame", sliderFrame)
    sliderBar.Size = UDim2.new(0.9, 0, 0.15, 0)
    sliderBar.Position = UDim2.new(0.05, 0, 0.6, 0)
    sliderBar.BackgroundColor3 = Config.ACCENT_OFF
    local barCorner = Instance.new("UICorner", sliderBar)
    barCorner.CornerRadius = UDim.new(0, 4)

    local sliderFill = Instance.new("Frame", sliderBar)
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = Config.ACCENT_ON
    local fillCorner = Instance.new("UICorner", sliderFill)
    fillCorner.CornerRadius = UDim.new(0, 4)

    local sliderButton = Instance.new("TextButton", sliderBar)
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    sliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    sliderButton.Text = ""
    local btnCorner = Instance.new("UICorner", sliderButton)
    btnCorner.CornerRadius = UDim.new(0, 8)
    local isDragging = false

    local function updateSliderValue(newValue)
        State.set(prop, newValue)
        local ratio = (newValue - min) / (max - min)
        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        sliderButton.Position = UDim2.new(ratio, 0, 0.5, 0)
        sliderLabel.Text = icon .. " " .. name .. " [" .. newValue .. "]"
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

    updateSliderValue(State.get(prop))
    sliderFrame.Parent = scroll
end

function GUI.createSectionLabel(text, scroll)
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(1, 0, 0, 25)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = text:upper()
    sectionLabel.TextColor3 = Config.ACCENT_ON
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextSize = 12
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = scroll
end

function GUI.create()
    local CoreGui = game:GetService("CoreGui")
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "HNkHubModern"
    sg.Parent = CoreGui
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 250, 0, 400)
    main.Position = UDim2.new(1, -500, 0, 10)
    main.BackgroundColor3 = Config.PRIMARY_BG
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Config.ACCENT_ON
    stroke.Transparency = 0.5
    stroke.Thickness = 1.5

    local titleFrame = Instance.new("Frame", main)
    titleFrame.Size = UDim2.new(1, 0, 0, 50)
    titleFrame.BackgroundColor3 = Config.DARK_BG
    local titleCorner = Instance.new("UICorner", titleFrame)
    titleCorner.CornerRadius = UDim.new(0, 12)
    local titleStroke = Instance.new("UIStroke", titleFrame)
    titleStroke.Color = Config.ACCENT_ON
    titleStroke.Transparency = 0.7

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
    closeBtn.BackgroundColor3 = Config.ACCENT_ON
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    local closeCorner = Instance.new("UICorner", closeBtn)
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    local minBtn = Instance.new("TextButton", titleFrame)
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -80, 0.5, -15)
    minBtn.BackgroundColor3 = Config.ACCENT_ON
    minBtn.Text = "-"
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 16
    local minCorner = Instance.new("UICorner", minBtn)
    minCorner.CornerRadius = UDim.new(0, 6)

    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -20, 1, -70)
    scroll.Position = UDim2.new(0, 10, 0, 60)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Config.ACCENT_ON
    scroll.ScrollBarImageTransparency = 0.5

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

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

    -- Seções
    GUI.createSectionLabel("Shadow Core", scroll)
    GUI.createToggle("Train", "Train", "⚔️", scroll)
    GUI.createToggle("AntiAFK", "AntiAFK", "⏳", scroll)
    GUI.createToggle("AntiFall", "AntiFall", "💀", scroll)

    GUI.createSectionLabel("Visuals", scroll)
    GUI.createToggle("ESP", "ESP", "👁️‍🗨️", scroll)
    GUI.createToggle("PerformanceOverlay", "PerformanceOverlay", "📊", scroll)
    GUI.createToggle("FOVMouseControl", "FOVMouseControl", "🖱️", scroll)
    GUI.createToggle("MinimalMode", "MinimalMode", "🔲", scroll)
    GUI.createSlider("FOV", "FOV", 70, 120, "🔭", scroll)

    GUI.createSectionLabel("Player", scroll)
    GUI.createToggle("God", "God", "🛡️", scroll)
    GUI.createToggle("GodExtreme", "GodExtreme", "🦾", scroll)
    GUI.createToggle("Speed", "Speed", "🏃‍♂️", scroll)
    GUI.createToggle("Jump", "Jump", "⬆️", scroll)
    GUI.createToggle("Invisible", "Invisible", "👻", scroll)

    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)

    print("[GUI]: Interface criada com sucesso")
    return sg
end

return GUI
