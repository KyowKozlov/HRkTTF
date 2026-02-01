# HNk TTF HUB v9.4.3 - Estrutura Modular

## 📁 Estrutura de Pastas

```
HRkTTF/
├── main.lua                          # Script principal (orquestrador)
├── modules/
│   ├── config/                       # Configurações
│   │   ├── Constants.lua             # Constantes do projeto
│   │   ├── Themes.lua                # Sistema de temas
│   │   ├── ModulesData.lua           # Dados dos módulos (abas/funcionalidades)
│   │   └── Defaults.lua              # Valores padrão
│   │
│   ├── utils/                        # Utilidades e helpers
│   │   ├── Helpers.lua               # Funções auxiliares (formatação, busca de stats)
│   │   ├── Colors.lua                # Sistema de cores (reputação, alianças)
│   │   ├── Persistence.lua           # Sistema de save/load (JSON)
│   │   └── StateManager.lua          # Gerenciador de estado global
│   │
│   ├── systems/                      # Sistemas principais
│   │   ├── Remotes.lua               # Gerenciador de remotes do jogo
│   │   ├── Toggles.lua               # Sistema de toggles (Train, AntiAFK, AntiFall)
│   │   ├── PlayerFeatures.lua        # Recursos do jogador (God, Speed, Jump)
│   │   ├── CameraSystem.lua          # Controle de câmera e FOV
│   │   ├── ESP.lua                   # Sistema ESP (billboards, poderes)
│   │   └── PerformanceOverlay.lua    # Overlay de FPS/PING
│   │
│   └── ui/                           # Interface do usuário
│       ├── GUIBuilder.lua            # Construtor da GUI (frames, botões)
│       ├── GUIElements.lua           # Elementos (toggles, sliders, labels)
│       ├── GUIThemes.lua             # Gerenciador de temas da UI
│       └── GUIInit.lua               # Inicialização completa da interface
```

## 🎯 Fluxo de Execução

1. **main.lua** carrega todos os módulos
2. **StateManager** gerencia o estado global (config, toggles)
3. **Persistence** carrega/salva configurações
4. **Themes** define cores da interface
5. **GUIInit** constrói toda a interface
6. **Event Listeners** conectam mudanças de estado à lógica do jogo
7. **Main Loops** (Heartbeat) executam lógica principal

## 🔧 Como Usar

### Adicionar novo Toggle

1. Edite `modules/config/ModulesData.lua`:
```lua
{name = "MeuToggle", type = "Toggle", text = "MEU TEXTO", icon = "✨"},
```

2. Crie a lógica em `modules/systems/YourSystem.lua`

3. Adicione o listener em `main.lua`:
```lua
state:OnChange("MeuToggle", function(newValue)
    -- sua lógica aqui
end)
```

### Adicionar novo Tema

1. Edite `modules/config/Themes.lua`:
```lua
["MeuTema"] = {
    ACCENT_ON = Color3.fromRGB(255, 60, 60),
    ACCENT_OFF = Color3.fromRGB(80, 80, 80),
    PRIMARY_BG = Color3.fromRGB(15, 15, 15),
    DARK_BG = Color3.fromRGB(25, 25, 25),
}
```

### Acessar/Modificar Estado

```lua
local state = require(modulesPath.utils.StateManager).new(defaults)

-- Obter valor
local espEnabled = state:Get("ESP")

-- Definir valor
state:Set("ESP", true)

-- Ouvir mudanças
state:OnChange("ESP", function(newValue, oldValue, key)
    print("ESP mudou de " .. tostring(oldValue) .. " para " .. tostring(newValue))
end)
```

## 📦 Módulos Principais

### StateManager
Gerencia todo o estado da aplicação com suporte a listeners:
```lua
local state = StateManager.new(defaults)
state:Set("ESP", true)
state:OnChange("ESP", callback)
```

### Persistence
Carrega e salva configurações em JSON:
```lua
Persistence:SaveConfig("config.json", state:GetAll())
local loaded = Persistence:LoadConfig("config.json", defaults)
```

### Helpers
Funções utilitárias:
```lua
Helpers:FormatNumber(1000000)  -- "1.00 M"
Helpers:FindEnemyPower(player)
Helpers:GetDisplayLabelText(module)  -- Evita duplicação de emojis
```

### ESP
Sistema de visualização:
```lua
espSystem:UpdateCache()
espSystem:Render()
espSystem:Cleanup()
```

### Toggles
Gerencia conexões e lógica de toggles:
```lua
toggleSystem:HandleToggleLogic("Train", true)
toggleSystem:DisconnectAll()
```

## 🎨 Customização

### Mudar Dimensões da GUI
Edite `modules/config/Constants.lua`:
```lua
Constants.INITIAL_WIDTH = 450
Constants.INITIAL_HEIGHT = 380
```

### Mudar Cores Padrão
Edite `modules/config/Themes.lua`:
```lua
["Shadowcore"] = {
    ACCENT_ON = Color3.fromRGB(255, 60, 60),
    ...
}
```

### Adicionar Nova Aba
Edite `modules/config/ModulesData.lua`:
```lua
["MinhaAba"] = {
    {name = "Feature1", type = "Toggle", text = "Minha Feature", icon = "🎯"},
}
```

## 🚀 Vantagens da Estrutura Modular

✅ **Separação de Responsabilidades** - Cada módulo faz uma coisa bem  
✅ **Reutilização** - Módulos podem ser usados em outros projetos  
✅ **Manutenção** - Fácil encontrar e corrigir bugs  
✅ **Escalabilidade** - Adicionar novas features sem quebrar o existente  
✅ **Testabilidade** - Cada módulo pode ser testado isoladamente  
✅ **Organização** - Código limpo e estruturado  

## 📝 Notas

- Todo o estado é centralizado no **StateManager**
- Configurações são salvas automaticamente em JSON
- Temas podem ser criados dinamicamente
- O sistema é totalmente sem callbacks em cadeia (usa listeners)
- Emoji duplicados são evitados automaticamente

---

**Versão:** 9.4.3  
**Autor:** KOZLOV  
**Data:** 31 de Janeiro de 2026
