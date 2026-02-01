-- =============================================
-- HNk TTF HUB v9.4.3 - GUI BUILDER MODULE (Parte 1 - Estrutura)
-- =============================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GUIBuilder = {}

function GUIBuilder:CreateMainFrame(parent, colors, constants)
    local fr = Instance.new("Frame", parent)
    fr.Size = UDim2.new(0, constants.INITIAL_WIDTH, 0, constants.INITIAL_HEIGHT)
    fr.Position = UDim2.new(1, -700, 0, 10)
    fr.BackgroundColor3 = colors.PRIMARY_BG
    fr.BackgroundTransparency = 0.9
    fr.BorderSizePixel = 0
    fr.Active = true
    fr.Draggable = true
    
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 5)
    if not fr:FindFirstChildOfClass("UIStroke") then
        local s = Instance.new("UIStroke", fr)
        s.Color = colors.ACCENT_ON
    end

    local glowFrame = Instance.new("Frame", fr)
    glowFrame.Size = UDim2.new(1, 0, 1, 0)
    glowFrame.BackgroundTransparency = 0.8
    glowFrame.BackgroundColor3 = colors.ACCENT_ON
    Instance.new("UICorner", glowFrame).CornerRadius = UDim.new(0, 5)

    local innerFrame = Instance.new("Frame", fr)
    innerFrame.Size = UDim2.new(1, -2, 1, -2)
    innerFrame.Position = UDim2.new(0, 1, 0, 1)
    innerFrame.BackgroundColor3 = colors.PRIMARY_BG
    innerFrame.BackgroundTransparency = 0.2
    Instance.new("UICorner", innerFrame).CornerRadius = UDim.new(0, 4)

    return fr
end

function GUIBuilder:CreateTitleBar(parent, colors, constants, themeName)
    local title = Instance.new("Frame", parent)
    title.Size = UDim2.new(1, 0, 0, constants.MINIMIZED_HEIGHT)
    title.BackgroundColor3 = colors.DARK_BG
    title.BackgroundTransparency = 0.1
    title.ClipsDescendants = true

    local titleText = Instance.new("TextLabel", title)
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 5, 0, 0)
    titleText.Text = "HNk | " .. themeName:upper() .. " [V9.4.3]"
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = colors.ACCENT_ON
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left

    local titleAccent = Instance.new("Frame", title)
    titleAccent.Size = UDim2.new(1, 0, 0, 3)
    titleAccent.Position = UDim2.new(0, 0, 1, -3)
    titleAccent.BackgroundColor3 = colors.ACCENT_ON
    titleAccent.BackgroundTransparency = 0.5

    return title, titleText, titleAccent
end

function GUIBuilder:CreateCloseButton(parent, colors)
    local close = Instance.new("TextButton", parent)
    close.Size = UDim2.new(0, 25, 1, 0)
    close.Position = UDim2.new(1, -25, 0, 0)
    close.Text = "X"
    close.BackgroundColor3 = colors.PRIMARY_BG
    close.TextColor3 = colors.ACCENT_ON
    close.BackgroundTransparency = 0.8
    close.Font = Enum.Font.SourceSansBold
    close.TextSize = 16
    Instance.new("UIStroke", close).Color = colors.ACCENT_ON
    Instance.new("UIStroke", close).Thickness = 1

    return close
end

function GUIBuilder:CreateMinimizeButton(parent, colors)
    local minimize = Instance.new("TextButton", parent)
    minimize.Size = UDim2.new(0, 25, 1, 0)
    minimize.Position = UDim2.new(1, -50, 0, 0)
    minimize.Text = "—"
    minimize.BackgroundColor3 = colors.PRIMARY_BG
    minimize.TextColor3 = colors.ACCENT_OFF
    minimize.BackgroundTransparency = 0.8
    minimize.Font = Enum.Font.SourceSansBold
    minimize.TextSize = 16
    Instance.new("UIStroke", minimize).Color = colors.ACCENT_OFF
    Instance.new("UIStroke", minimize).Thickness = 1

    return minimize
end

function GUIBuilder:CreateNavFrame(parent, colors, constants)
    local navFrame = Instance.new("Frame", parent)
    navFrame.Size = UDim2.new(0, constants.TAB_WIDTH, 1, -25)
    navFrame.Position = UDim2.new(0, 0, 0, 25)
    navFrame.BackgroundColor3 = colors.DARK_BG
    navFrame.BackgroundTransparency = 0.1
    navFrame.ClipsDescendants = true
    Instance.new("UIStroke", navFrame).Color = colors.ACCENT_OFF
    Instance.new("UIStroke", navFrame).Thickness = 1
    Instance.new("UIStroke", navFrame).Transparency = 0.5

    local navLayout = Instance.new("UIListLayout", navFrame)
    navLayout.Padding = UDim.new(0, 2)
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder

    return navFrame, navLayout
end

function GUIBuilder:CreateContentFrame(parent, colors, constants)
    local contentFrame = Instance.new("Frame", parent)
    contentFrame.Size = UDim2.new(1, -(constants.TAB_WIDTH + 5), 1, -35)
    contentFrame.Position = UDim2.new(0, constants.TAB_WIDTH + 5, 0, 30)
    contentFrame.BackgroundColor3 = colors.PRIMARY_BG
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true

    return contentFrame
end

function GUIBuilder:CreateTabButton(parent, colors, tabName, order)
    local tabButton = Instance.new("TextButton", parent)
    tabButton.Name = tabName:gsub(" ", "") .. "NavBtn"
    tabButton.LayoutOrder = order
    tabButton.Size = UDim2.new(1, -10, 0, 30)
    tabButton.Position = UDim2.new(0, 5, 0, 0)
    tabButton.Text = tabName:upper()
    tabButton.BackgroundColor3 = colors.DARK_BG
    tabButton.BackgroundTransparency = 0.5
    tabButton.TextColor3 = colors.ACCENT_OFF
    tabButton.Font = Enum.Font.SourceSansBold
    tabButton.TextSize = 16
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 5)

    return tabButton
end

function GUIBuilder:CreateTabFrame(parent, tabName)
    local tabFrame = Instance.new("ScrollingFrame", parent)
    tabFrame.Name = tabName:gsub(" ", "") .. "Tab"
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.ScrollBarThickness = 5
    tabFrame.Visible = false
    tabFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 100)

    local tabLayout = Instance.new("UIListLayout", tabFrame)
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    return tabFrame, tabLayout
end

return GUIBuilder
