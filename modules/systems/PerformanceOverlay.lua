-- =============================================
-- HNk TTF HUB v9.4.3 - PERFORMANCE OVERLAY MODULE
-- =============================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PerformanceOverlay = {}

function PerformanceOverlay:Create(screenGui, state, colors)
    self.state = state
    self.colors = colors
    self.screenGui = screenGui

    local frame = Instance.new("TextLabel", screenGui)
    frame.Size = UDim2.new(0, 150, 0, 40)
    frame.Position = UDim2.new(1, -160, 0, 10)
    frame.BackgroundTransparency = 0.8
    frame.BackgroundColor3 = colors.PRIMARY_BG
    frame.TextColor3 = colors.ACCENT_ON
    frame.Font = Enum.Font.SourceSansBold
    frame.TextSize = 14
    frame.TextXAlignment = Enum.TextXAlignment.Left
    frame.TextYAlignment = Enum.TextYAlignment.Top
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

    frame.Visible = state:Get("PerformanceOverlay")
    self.label = frame

    self:_StartLoop()
    self:_StartRenderLoop()

    return frame
end

function PerformanceOverlay:_StartRenderLoop()
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

    self.renderConn = renderConn
    self.fps = fps
end

function PerformanceOverlay:_StartLoop()
    task.spawn(function()
        while task.wait(0.3) do
            if self.state:Get("PerformanceOverlay") and self.label then
                self:_UpdateDisplay()
            end
        end
    end)
end

function PerformanceOverlay:_UpdateDisplay()
    local pingMs = 0
    local ok, pingVal = pcall(function() return Players.LocalPlayer and Players.LocalPlayer:GetNetworkPing() end)
    if ok and type(pingVal) == "number" then
        pingMs = math.floor(pingVal * 1000 + 0.5)
    end

    if self.label and self.fps then
        self.label.Text = string.format("FPS: %d\nPING: %d ms", self.fps, pingMs)
    end
end

function PerformanceOverlay:SetVisible(visible)
    if self.label then
        self.label.Visible = visible
    end
end

function PerformanceOverlay:UpdateColors(primaryBg, accentOn)
    if self.label then
        self.label.BackgroundColor3 = primaryBg
        self.label.TextColor3 = accentOn
    end
end

function PerformanceOverlay:Cleanup()
    if self.renderConn then
        pcall(function() self.renderConn:Disconnect() end)
    end
end

return PerformanceOverlay
