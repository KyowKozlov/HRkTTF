-- =============================================
-- EXEMPLO DE USO - Como estender a estrutura
-- =============================================

--[[ 
    Este arquivo demonstra como adicionar novas funcionalidades
    à estrutura modular do HNk TTF HUB v9.4.3
--]]

-- ===================================
-- EXEMPLO 1: Adicionar novo Toggle
-- ===================================

--[[
1. Edite modules/config/ModulesData.lua e adicione:

["Shadow Core"] = {
    ...
    {name = "NovaFeature", type = "Toggle", text = "MINHA NOVA FEATURE", icon = "🆕"},
}

2. Crie modules/systems/MinhaFeature.lua:
]]

local MinhaFeature = {}

function MinhaFeature:Initialize(state, remotes)
    self.state = state
    self.remotes = remotes
    self.connection = nil
    return self
end

function MinhaFeature:Start()
    if self.connection then self.connection:Disconnect() end
    
    local RunService = game:GetService("RunService")
    self.connection = RunService.Heartbeat:Connect(function()
        -- sua lógica aqui
        print("Minha feature está ativa!")
    end)
end

function MinhaFeature:Stop()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
end

--[[
3. Em main.lua, adicione:

local MinhaFeature = require(modulesPath.systems.MinhaFeature)
local minhaFeature = MinhaFeature:Initialize(state, remotes)

state:OnChange("NovaFeature", function(enabled)
    if enabled then
        minhaFeature:Start()
    else
        minhaFeature:Stop()
    end
end)
]]

-- ===================================
-- EXEMPLO 2: Adicionar novo Tema
-- ===================================

--[[
Em modules/config/Themes.lua, adicione:
]]

Themes.CONFIG["MeuTemaCustom"] = {
    ACCENT_ON = Color3.fromRGB(138, 43, 226),    -- Azul Roxo
    ACCENT_OFF = Color3.fromRGB(75, 0, 130),     -- Índigo
    PRIMARY_BG = Color3.fromRGB(20, 10, 40),     -- Fundo escuro roxo
    DARK_BG = Color3.fromRGB(40, 20, 60),        -- Painel roxo
}

-- ===================================
-- EXEMPLO 3: Usar StateManager
-- ===================================

--[[
Para acessar/modificar o estado global:
]]

-- Em qualquer módulo:
function MeuModulo:AoCarregar(state)
    -- Obter valor
    local espAtivo = state:Get("ESP")
    
    -- Definir valor
    state:Set("ESP", false)
    
    -- Ouvir mudanças
    state:OnChange("ESP", function(novoValor, valorAnterior, chave)
        print("ESP foi " .. (novoValor and "ativado" or "desativado"))
    end)
end

-- ===================================
-- EXEMPLO 4: Adicionar Helper/Utilitário
-- ===================================

--[[
Em modules/utils/Helpers.lua, adicione:
]]

function Helpers:CalcularDano(poder1, poder2)
    return math.abs(poder1 - poder2) * 1.5
end

function Helpers:EhInimigo(player, targetPlayer)
    local dn = targetPlayer.DisplayName:upper()
    return (targetPlayer ~= player) and 
           not string.find(dn, "KOZLOV") and 
           not string.find(dn, "NOTORIOUS")
end

-- ===================================
-- EXEMPLO 5: Persistir Dados Custom
-- ===================================

--[[
Para salvar dados customizados:
]]

local function SalvarDadosCustom(dados)
    local Persistence = require(modulesPath.utils.Persistence)
    Persistence:SaveConfig("dados_custom.json", dados)
end

local function CarregarDadosCustom(defaults)
    local Persistence = require(modulesPath.utils.Persistence)
    return Persistence:LoadConfig("dados_custom.json", defaults)
end

-- ===================================
-- EXEMPLO 6: Estender Colors
-- ===================================

--[[
Em modules/utils/Colors.lua, adicione:
]]

function Colors:GetMeuTemaCustomColor(player, targetPlayer)
    local dn = targetPlayer.DisplayName:upper()
    
    if string.find(dn, "ADMIN") then
        return Color3.fromRGB(255, 215, 0)  -- Ouro para admins
    elseif string.find(dn, "MODERATOR") then
        return Color3.fromRGB(173, 255, 47)  -- Verde-limão para mods
    else
        return Color3.new(1, 1, 1)
    end
end

-- ===================================
-- EXEMPLO 7: Criar Slider Customizado
-- ===================================

--[[
Em modules/config/ModulesData.lua, adicione à aba desejada:
]]

{
    name = "MeuSlider", 
    type = "Slider", 
    text = "VELOCIDADE CUSTOMIZADA", 
    min = 50, 
    max = 200, 
    default = 100, 
    icon = "⚡"
}

-- Depois em main.lua:
state:OnChange("MeuSlider", function(newValue)
    print("Novo valor do slider: " .. newValue)
    -- aplicar mudança
end)

-- ===================================
-- EXEMPLO 8: Modificar GUI em Runtime
-- ===================================

--[[
Para modificar a GUI após inicialização:
]]

function MeuModulo:AlterarGUI(guiElements, colors)
    if guiElements.MainFrame then
        guiElements.MainFrame.BackgroundColor3 = colors.PRIMARY_BG
    end
    
    for name, element in pairs(guiElements.ToggleElements) do
        if element.TextLabel then
            element.TextLabel.TextColor3 = colors.ACCENT_ON
        end
    end
end

-- ===================================
-- EXEMPLO 9: Debug e Logging
-- ===================================

--[[
Para debugging, use:
]]

local function DebugState(state)
    print("=== STATE DEBUG ===")
    for key, value in pairs(state:GetAll()) do
        print(key .. " = " .. tostring(value))
    end
    print("===================")
end

-- ===================================
-- EXEMPLO 10: Cleanup/Destruição
-- ===================================

--[[
Para limpar recursos ao fechar:
]]

local function LimparTudo()
    -- Desconectar todos os toggles
    toggleSystem:DisconnectAll()
    
    -- Limpar ESP
    espSystem:Cleanup()
    
    -- Limpar performance overlay
    performanceOverlay:Cleanup()
    
    -- Destruir GUI
    screenGui:Destroy()
    performanceGui:Destroy()
    
    print("Todos os recursos foram limpos!")
end

return {
    DebugState = DebugState,
    LimparTudo = LimparTudo,
}
