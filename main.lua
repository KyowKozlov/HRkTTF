-- =============================================
-- HNk TTF HUB v9.4.3 - MAIN SCRIPT (Orquestrador)
-- =============================================
-- Este é o script principal que carrega e coordena todos os módulos

loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-GJ-PRO-Emotes-83556"))()

print("HNk TTF HUB v9.4.3 loading: Fixed duplicated emojis in tab labels.")

-- ===================================
-- 1. LOAD MODULES
-- ===================================

local modulesPath = script.Parent:WaitForChild("modules")

-- Config
local Constants = require(modulesPath.config.Constants)
local Themes = require(modulesPath.config.Themes)
local ModulesData = require(modulesPath.config.ModulesData)
local Defaults = require(modulesPath.config.Defaults)

-- Utils
local Helpers = require(modulesPath.utils.Helpers)
local Colors = require(modulesPath.utils.Colors)
local Persistence = require(modulesPath.utils.Persistence)
local StateManager = require(modulesPath.utils.StateManager)

-- Systems
local Remotes = require(modulesPath.systems.Remotes)
local Toggles = require(modulesPath.systems.Toggles)
local PlayerFeatures = require(modulesPath.systems.PlayerFeatures)
local CameraSystem = require(modulesPath.systems.CameraSystem)
local ESP = require(modulesPath.systems.ESP)
local PerformanceOverlay = require(modulesPath.systems.PerformanceOverlay)

-- UI
local GUIBuilder = require(modulesPath.ui.GUIBuilder)
local GUIElements = require(modulesPath.ui.GUIElements)
local GUIThemes = require(modulesPath.ui.GUIThemes)
local GUIInit = require(modulesPath.ui.GUIInit)

-- ===================================
-- 2. INITIALIZE SERVICES
-- ===================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ===================================
-- 3. SETUP STATE MANAGER
-- ===================================

local defaults = Defaults:GetDefaults()
local state = StateManager.new(defaults)

-- Carregar configurações persistidas
local loadedConfig = Persistence:LoadConfig(Constants.FILE_NAME, defaults)
for key, value in pairs(loadedConfig) do
    state:Set(key, value)
end

-- ===================================
-- 4. INITIALIZE COLORS
-- ===================================

local currentThemeData = Themes:GetTheme(state:Get("CurrentTheme"))
local colors = {
    ACCENT_ON = currentThemeData.ACCENT_ON,
    ACCENT_OFF = currentThemeData.ACCENT_OFF,
    PRIMARY_BG = currentThemeData.PRIMARY_BG,
    DARK_BG = currentThemeData.DARK_BG,
}

-- Listener para mudanças de tema
state:OnChange("CurrentTheme", function(newTheme)
    local themeData = Themes:GetTheme(newTheme)
    colors.ACCENT_ON = themeData.ACCENT_ON
    colors.ACCENT_OFF = themeData.ACCENT_OFF
    colors.PRIMARY_BG = themeData.PRIMARY_BG
    colors.DARK_BG = themeData.DARK_BG
    Persistence:SaveConfig(Constants.FILE_NAME, state:GetAll())
end)

-- ===================================
-- 5. INITIALIZE SYSTEMS
-- ===================================

-- Remotes
local remotes = Remotes:Initialize()

-- Toggles
local toggleSystem = Toggles.new(state, remotes)

-- Player Features
local playerFeatures = PlayerFeatures:Initialize(state, remotes)

-- ESP
local espSystem = ESP:Initialize(state, Helpers, Colors)
espSystem:Initialize(state, Helpers, Colors)

-- ===================================
-- 6. CREATE GUI
-- ===================================

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "HNkTTF_V9_Shadowcore_Tabbed"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiElements = GUIInit:Initialize(screenGui, state, colors, Helpers, ModulesData, Constants)

-- Criar Performance Overlay
local performanceGui = Instance.new("ScreenGui", CoreGui)
performanceGui.Name = "HNkPerformanceOverlay"
performanceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local performanceOverlay = PerformanceOverlay:Create(performanceGui, state, colors)

-- ===================================
-- 7. HANDLE STATE CHANGES
-- ===================================

-- Atualizar visuals quando tema muda
state:OnChange("CurrentTheme", function()
    if guiElements.TitleText then
        guiElements.TitleText.Text = "HNk | " .. state:Get("CurrentTheme"):upper() .. " [V" .. Constants.VERSION .. "]"
    end
end)

-- Toggle para MinimalMode
state:OnChange("MinimalMode", function(enabled)
    if enabled then
        pcall(function()
            guiElements.MainFrame.Size = UDim2.new(0, 320, 0, Constants.MINIMIZED_HEIGHT)
            guiElements.NavFrame.Visible = false
            guiElements.ContentFrame.Visible = false
        end)
    else
        pcall(function()
            guiElements.MainFrame.Size = UDim2.new(0, Constants.INITIAL_WIDTH, 0, Constants.INITIAL_HEIGHT)
            guiElements.NavFrame.Visible = true
            guiElements.ContentFrame.Visible = true
        end)
    end
end)

-- Toggle para PerformanceOverlay
state:OnChange("PerformanceOverlay", function(enabled)
    performanceOverlay:SetVisible(enabled)
end)

-- Listeners para todos os toggles
for toggleName, _ in pairs(defaults) do
    if type(defaults[toggleName]) == "boolean" then
        state:OnChange(toggleName, function(newValue)
            toggleSystem:HandleToggleLogic(toggleName, newValue)
            Persistence:SaveConfig(Constants.FILE_NAME, state:GetAll())
        end)
    end
end

-- Listener para FOV
state:OnChange("FOV", function(newValue)
    CameraSystem:SetFieldOfView(newValue)
    Persistence:SaveConfig(Constants.FILE_NAME, state:GetAll())
    
    -- Atualizar slider visuals se existir
    if guiElements.FovSliderElement and guiElements.FovSliderElement.Module then
        GUIElements:UpdateSliderVisuals(guiElements.FovSliderElement, newValue, colors, Helpers, guiElements.FovSliderElement.Module)
    end
end)

-- ===================================
-- 8. FOV MOUSE CONTROL
-- ===================================

UserInputService.InputChanged:Connect(function(input)
    if not state:Get("FOVMOUSECONTROL") then return end
    if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
    if CameraSystem:IsScriptable() then return end

    local delta = input.Position.Z
    local fovChange = -delta * 5

    local currentFOV = state:Get("FOV")
    local newFOV = math.floor(math.clamp(currentFOV + fovChange, 70, 120) + 0.5)

    if newFOV ~= currentFOV then
        state:Set("FOV", newFOV)
    end
end)

-- ===================================
-- 9. MAIN LOOPS
-- ===================================

-- Heartbeat - Player Features Update
RunService.Heartbeat:Connect(function()
    playerFeatures:Update()
    CameraSystem:Update(state)
end)

-- Heartbeat - ESP Update
RunService.Heartbeat:Connect(function(dt)
    if state:Get("ESP") then
        espSystem:Render()
    else
        espSystem:Cleanup()
    end
end)

-- ESP Cache Update
task.spawn(function()
    while task.wait(0.3) do
        espSystem:UpdateCache()
    end
end)

-- Memory Cleanup
task.spawn(function()
    while task.wait(60) do
        collectgarbage("collect")
    end
end)

-- ===================================
-- 10. INITIALIZE INITIAL TOGGLES
-- ===================================

for toggleName, initialValue in pairs(defaults) do
    if type(initialValue) == "boolean" then
        if state:Get(toggleName) then
            toggleSystem:HandleToggleLogic(toggleName, true)
        end
    end
end

-- ===================================
-- STARTUP MESSAGE
-- ===================================

print("HNk TTF HUB v" .. Constants.VERSION .. " FINAL ACTIVE!")
print("GUI fully initialized and stable.")
print("Theme: " .. state:Get("CurrentTheme"))
