-- =============================================
-- HNk TTF HUB v9.4.3 - THEMES UI MODULE
-- =============================================

local GUIThemes = {}

function GUIThemes:CreateThemeButton(parent, themeName, themeColors, currentTheme, onClicked)
    local frame = Instance.new("Frame", parent)
    frame.Name = themeName .. "Container"
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = #parent:GetChildren() + 1

    local btn = Instance.new("TextButton", frame)
    btn.Name = "TextButton"
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = "🎨 " .. themeName
    btn.BackgroundColor3 = (themeName == currentTheme) and themeColors.ACCENT_ON or Color3.fromRGB(25, 25, 25)
    btn.BackgroundTransparency = 0.5
    btn.TextColor3 = (themeName == currentTheme) and themeColors.PRIMARY_BG or Color3.fromRGB(80, 80, 80)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 16
    Instance.new("UIStroke", btn).Color = themeColors.ACCENT_ON

    btn.MouseButton1Click:Connect(function()
        onClicked(themeName)
    end)

    return frame, btn
end

function GUIThemes:CreateCustomThemeButton(parent, onClicked)
    local createContainer = Instance.new("Frame", parent)
    createContainer.Size = UDim2.new(1, -10, 0, 40)
    createContainer.BackgroundTransparency = 1
    createContainer.LayoutOrder = 1

    local createBtn = Instance.new("TextButton", createContainer)
    createBtn.Size = UDim2.new(1, 0, 1, 0)
    createBtn.Text = "➕ Create Custom Theme"
    createBtn.Font = Enum.Font.SourceSansBold
    createBtn.TextSize = 16
    createBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    createBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", createBtn).CornerRadius = UDim.new(0, 5)
    createBtn.MouseButton1Click:Connect(function()
        onClicked()
    end)

    return createContainer, createBtn
end

function GUIThemes:GenerateRandomTheme()
    local function rnd() return math.random(60, 230) end
    local accent = Color3.fromRGB(rnd(), rnd(), rnd())
    local accentOff = Color3.fromRGB(
        math.clamp(math.floor(accent.R*255*0.4), 30, 200),
        math.clamp(math.floor(accent.G*255*0.4), 30, 200),
        math.clamp(math.floor(accent.B*255*0.4), 30, 200)
    )
    local primary = Color3.fromRGB(math.random(5, 60), math.random(5, 60), math.random(5, 60))
    local dark = Color3.fromRGB(
        math.clamp(math.floor(primary.R*255*1.5%255), 10, 120),
        math.clamp(math.floor(primary.G*255*1.5%255), 10, 120),
        math.clamp(math.floor(primary.B*255*1.5%255), 10, 120)
    )

    return {
        ACCENT_ON = accent,
        ACCENT_OFF = accentOff,
        PRIMARY_BG = primary,
        DARK_BG = dark,
    }
end

return GUIThemes
