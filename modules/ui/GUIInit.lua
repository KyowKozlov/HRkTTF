-- =============================================
-- HNk TTF HUB v9.4.3 - MAIN INIT MODULE (Full GUI)
-- =============================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local GUIInit = {}

function GUIInit:Initialize(parent, state, colors, helpers, moduleData, constants)
    -- Cache de elementos
    local toggleElements = {}
    local fovSliderElement = nil
    local performanceOverlayLabel = nil

    local GUIBuilder = require(script.Parent:WaitForChild("GUIBuilder"))
    local GUIElements = require(script.Parent:WaitForChild("GUIElements"))
    local GUIThemes = require(script.Parent:WaitForChild("GUIThemes"))

    -- Criar frame principal
    local fr = GUIBuilder:CreateMainFrame(parent, colors, constants)

    -- Criar barra de título
    local title, titleText, titleAccent = GUIBuilder:CreateTitleBar(fr, colors, constants, state:Get("CurrentTheme"))
    local close = GUIBuilder:CreateCloseButton(title, colors)
    local minimize = GUIBuilder:CreateMinimizeButton(title, colors)

    -- Criar navegação e conteúdo
    local navFrame, navLayout = GUIBuilder:CreateNavFrame(fr, colors, constants)
    local contentFrame = GUIBuilder:CreateContentFrame(fr, colors, constants)

    local tabContents = {}
    local isMinimized = false

    -- Função para trocar de aba
    local function switchTab(tabName, tabButton)
        for _, btn in navFrame:GetChildren() do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = colors.DARK_BG
                btn.BackgroundTransparency = 0.5
                btn.TextColor3 = colors.ACCENT_OFF
                local stroke = btn:FindFirstChild("UIStroke")
                if stroke then stroke:Destroy() end
            end
        end

        for name, frame in pairs(tabContents) do
            frame.Visible = (name == tabName)
        end

        if tabButton then
            tabButton.BackgroundColor3 = colors.ACCENT_ON
            tabButton.BackgroundTransparency = 0.8
            tabButton.TextColor3 = colors.PRIMARY_BG
            local stroke = tabButton:FindFirstChild("UIStroke") or Instance.new("UIStroke", tabButton)
            stroke.Color = colors.ACCENT_ON
            stroke.Thickness = 1
            stroke.Transparency = 0
        end
    end

    -- Handlers
    close.MouseButton1Click:Connect(function()
        parent:Destroy()
    end)

    minimize.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            fr.Size = UDim2.new(0, constants.INITIAL_WIDTH, 0, constants.MINIMIZED_HEIGHT)
            navFrame.Visible = false
            contentFrame.Visible = false
            minimize.Text = "+"
        else
            fr.Size = UDim2.new(0, constants.INITIAL_WIDTH, 0, constants.INITIAL_HEIGHT)
            navFrame.Visible = true
            contentFrame.Visible = true
            minimize.Text = "—"
        end
    end)

    -- Construir abas
    local tabOrder = moduleData:GetTabOrder()
    local structure = moduleData:GetStructure()

    for order, tabName in ipairs(tabOrder) do
        local modules = structure[tabName]

        local tabFrame, tabLayout = GUIBuilder:CreateTabFrame(contentFrame, tabName)
        tabContents[tabName] = tabFrame

        local tabButton = GUIBuilder:CreateTabButton(navFrame, colors, tabName, order)

        if tabName == "Themas" then
            -- Aba de temas
            local createContainer, createBtn = GUIThemes:CreateCustomThemeButton(tabFrame, function()
                local newTheme = GUIThemes:GenerateRandomTheme()
                local idx = 1
                while structure["CustomTheme" .. idx] do idx = idx + 1 end
                local themeName = "CustomTheme" .. idx
                local themesModule = require(script.Parent:WaitForChild("GUIThemes"))
                -- Adicionar tema dinamicamente
                GUIThemes:CreateThemeButton(tabFrame, themeName, newTheme, state:Get("CurrentTheme"), function(name)
                    state:Set("CurrentTheme", name)
                end)
            end)

            for themeName, themeColors in pairs(require(script.Parent.Parent.Parent:WaitForChild("config"):WaitForChild("Themes")).CONFIG) do
                GUIThemes:CreateThemeButton(tabFrame, themeName, themeColors, state:Get("CurrentTheme"), function(name)
                    colors.ACCENT_ON = themeColors.ACCENT_ON
                    colors.ACCENT_OFF = themeColors.ACCENT_OFF
                    colors.PRIMARY_BG = themeColors.PRIMARY_BG
                    colors.DARK_BG = themeColors.DARK_BG
                    state:Set("CurrentTheme", name)
                end)
            end
        else
            -- Abas normais
            for _, module in ipairs(modules) do
                if module.type == "Toggle" then
                    local element = GUIElements:CreateToggleElement(tabFrame, module, colors, state, constants)
                    toggleElements[module.name] = element

                    element.Button.MouseButton1Click:Connect(function()
                        state:Set(module.name, not state:Get(module.name))
                    end)

                    GUIElements:UpdateToggleVisuals(element, state, colors)
                    state:OnChange(module.name, function()
                        GUIElements:UpdateToggleVisuals(element, state, colors)
                    end)

                elseif module.type == "Slider" then
                    local element = GUIElements:CreateSliderElement(tabFrame, module, colors, state, constants)
                    fovSliderElement = element

                    local minVal = module.min
                    local maxVal = module.max
                    local isDragging = false

                    local function updateSlider(xPos)
                        if not element.Slider or not element.Slider.AbsolutePosition or not element.Slider.AbsoluteSize then return end
                        local relativeX = xPos - element.Slider.AbsolutePosition.X
                        local ratio = math.clamp(relativeX / math.max(1, element.Slider.AbsoluteSize.X), 0, 1)
                        local newValue = math.floor(minVal + ratio * (maxVal - minVal))

                        if state:Get("FOV") ~= newValue then
                            state:Set("FOV", newValue)
                            GUIElements:UpdateSliderVisuals(element, newValue, colors, helpers, module)
                        end
                    end

                    spawn(function()
                        task.wait(0.05)
                        GUIElements:UpdateSliderVisuals(element, state:Get("FOV"), colors, helpers, module)
                    end)

                    element.SliderButton.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            isDragging = true
                        end
                    end)

                    element.SliderButton.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            isDragging = false
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            updateSlider(input.Position.X)
                        end
                    end)
                end
            end

            tabLayout.Parent.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
        end

        tabButton.MouseButton1Click:Connect(function()
            switchTab(tabName, tabButton)
        end)
    end

    -- Mostrar aba padrão
    switchTab("Shadow Core", navFrame:FindFirstChild("ShadowCoreNavBtn"))

    return {
        MainFrame = fr,
        TitleText = titleText,
        TitleAccent = titleAccent,
        NavFrame = navFrame,
        ContentFrame = contentFrame,
        TabContents = tabContents,
        ToggleElements = toggleElements,
        FovSliderElement = fovSliderElement,
    }
end

return GUIInit
