-- =============================================
-- HNk TTF HUB v9.4.3 - GUI ELEMENTS MODULE (Toggles e Sliders)
-- =============================================

local TweenService = game:GetService("TweenService")
local GUIElements = {}

function GUIElements:CreateToggleElement(parent, module, colors, state, constants)
    local frame = Instance.new("Frame", parent)
    frame.Name = "ToggleContainer"
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and parent:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y or 0)

    local textLabel = Instance.new("TextLabel", frame)
    textLabel.Name = "TextLabel"
    textLabel.Size = UDim2.new(1, -60, 0, 40)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = colors.ACCENT_OFF
    textLabel.Font = Enum.Font.SourceSansSemibold
    textLabel.TextSize = 16
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Text = module.icon .. " " .. module.text

    local btn = Instance.new("TextButton", frame)
    btn.Name = "ToggleBtn"
    btn.Size = UDim2.new(0, 50, 0, 20)
    btn.Position = UDim2.new(1, -55, 0.5, -10)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local toggleBar = Instance.new("Frame", btn)
    toggleBar.Name = "ToggleBar"
    toggleBar.Size = UDim2.new(1, 0, 1, 0)
    toggleBar.BackgroundColor3 = colors.DARK_BG
    toggleBar.BorderSizePixel = 0
    Instance.new("UICorner", toggleBar).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", toggleBar).Color = colors.ACCENT_ON

    local toggleCircle = Instance.new("Frame", btn)
    toggleCircle.Name = "ToggleCircle"
    toggleCircle.Size = UDim2.new(0, 20, 1, 0)
    toggleCircle.BackgroundColor3 = colors.ACCENT_OFF
    toggleCircle.BorderSizePixel = 0
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(0, 10)

    local element = {
        Frame = frame,
        TextLabel = textLabel,
        ToggleBar = toggleBar,
        ToggleCircle = toggleCircle,
        Button = btn,
        Module = module,
    }

    return element
end

function GUIElements:CreateSliderElement(parent, module, colors, state, constants)
    local frame = Instance.new("Frame", parent)
    frame.Name = "SliderContainer"
    frame.Size = UDim2.new(1, -10, 0, 60)
    frame.BackgroundTransparency = 1

    local textLabel = Instance.new("TextLabel", frame)
    textLabel.Name = "TextLabel"
    textLabel.Size = UDim2.new(1, -60, 0, 20)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = colors.ACCENT_OFF
    textLabel.Font = Enum.Font.SourceSansSemibold
    textLabel.TextSize = 16
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Text = module.icon .. " " .. module.text .. " [" .. tostring(state:Get("FOV")) .. "]"

    local slider = Instance.new("Frame", frame)
    slider.Name = "SliderBar"
    slider.Size = UDim2.new(1, -60, 0, 10)
    slider.Position = UDim2.new(0.5, -30, 0.5, 20)
    slider.AnchorPoint = Vector2.new(0.5, 0.5)
    slider.BackgroundColor3 = colors.DARK_BG
    slider.BorderSizePixel = 0
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", slider).Color = colors.ACCENT_OFF

    local sliderFill = Instance.new("Frame", slider)
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = colors.ACCENT_ON
    sliderFill.BorderSizePixel = 0

    local sliderButton = Instance.new("TextButton", slider)
    sliderButton.Name = "SliderButton"
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = UDim2.new(0.5, -10, 0.5, 0)
    sliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderButton.BackgroundColor3 = colors.ACCENT_ON
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    Instance.new("UICorner", sliderButton).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", sliderButton).Color = colors.PRIMARY_BG

    local element = {
        Frame = frame,
        TextLabel = textLabel,
        Slider = slider,
        SliderFill = sliderFill,
        SliderButton = sliderButton,
        Module = module,
    }

    return element
end

function GUIElements:UpdateToggleVisuals(element, state, colors)
    local moduleName = element.Module.name
    local enabled = state:Get(moduleName)
    local primaryColor = enabled and colors.ACCENT_ON or colors.ACCENT_OFF

    element.TextLabel.TextColor3 = primaryColor
    element.ToggleBar.BackgroundColor3 = enabled and colors.ACCENT_ON or colors.DARK_BG

    element.ToggleCircle.BackgroundColor3 = enabled and colors.DARK_BG or colors.ACCENT_OFF
    pcall(function()
        TweenService:Create(element.ToggleCircle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = enabled and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)
        }):Play()
    end)

    local stroke = element.Frame and element.Frame:FindFirstChild("UIStroke")
    if not stroke and element.Frame then
        stroke = Instance.new("UIStroke", element.Frame)
    end
    if stroke then
        stroke.Color = primaryColor
        stroke.Thickness = enabled and 1 or 0.5
        stroke.Transparency = 0.3
    end
end

function GUIElements:UpdateSliderVisuals(element, value, colors, helpers, module)
    local minVal = module.min
    local maxVal = module.max
    local ratio = math.clamp((value - minVal) / (maxVal - minVal), 0, 1)

    element.SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    pcall(function()
        element.SliderButton.Position = UDim2.new(ratio, -element.SliderButton.Size.X.Offset/2, 0.5, -element.SliderButton.Size.Y.Offset/2)
    end)
    element.TextLabel.Text = helpers:GetDisplayLabelText(module) .. " [" .. tostring(math.floor(value)) .. "]"
    element.TextLabel.TextColor3 = colors.ACCENT_ON
    element.SliderFill.BackgroundColor3 = colors.ACCENT_ON
    if element.SliderButton.ImageColor3 then element.SliderButton.ImageColor3 = colors.ACCENT_ON end
end

return GUIElements
