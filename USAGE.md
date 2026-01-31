# HNk Hub v9.4.3 - Guia de Uso Modular

## Estrutura do Projeto

```
HNkHub/
├── core/
│   ├── config.lua          # Configurações globais
│   ├── state.lua           # Gerenciador de estado
│   └── utils.lua           # Funções utilitárias
├── features/
│   ├── gui.lua             # Interface gráfica
│   ├── esp.lua             # ESP (visão de inimigos)
│   ├── god.lua             # God Mode
│   ├── train.lua           # Auto Train
│   └── player.lua          # Speed/Jump/Movement
└── loaders/
    ├── gui_only.lua        # Apenas GUI
    ├── esp_only.lua        # Apenas ESP
    ├── god_only.lua        # Apenas God Mode
    ├── train_only.lua      # Apenas Train
    └── full.lua            # Completo (GUI + todas features)
```

## Como Usar

### 1. **Apenas GUI** (Controle manual)
```lua
loadstring(game:HttpGet("...loaders/gui_only.lua"))()
```
Ativa apenas a interface gráfica. Você controla cada feature pela GUI.

### 2. **Apenas ESP**
```lua
loadstring(game:HttpGet("...loaders/esp_only.lua"))()
```
Ativa apenas o sistema de visão de inimigos.

### 3. **Apenas God Mode**
```lua
loadstring(game:HttpGet("...loaders/god_only.lua"))()
```
Ativa apenas imortalidade.

### 4. **Apenas Train**
```lua
loadstring(game:HttpGet("...loaders/train_only.lua"))()
```
Ativa apenas o sistema de treino automático.

### 5. **Tudo Junto (Recomendado)**
```lua
loadstring(game:HttpGet("...loaders/full.lua"))()
```
Carrega GUI + todas as features funcionando.

## API de Estado Global

Você pode usar `State` para controlar tudo via script:

```lua
local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))

-- Ativar God Mode
State.set("God", true)

-- Desativar Speed
State.set("Speed", false)

-- Verificar status
print(State.get("God")) -- true ou false

-- Obter todas as configs
print(State.getAll())

-- Ouvir mudanças
State.onChange("ESP", function(enabled)
    print("ESP foi alterado para: " .. tostring(enabled))
end)
```

## Combinações Personalizadas

Se quiser uma combinação específica, crie um arquivo assim:

```lua
-- Exemplo: ESP + God Mode + GUI
local core = game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core")
local features = game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("features")

local State = require(core:WaitForChild("state"))
local GUI = require(features:WaitForChild("gui"))
local ESP = require(features:WaitForChild("esp"))
local God = require(features:WaitForChild("god"))

-- Cria GUI
GUI.create()

-- Ativa features
State.set("ESP", true)
State.set("God", true)

print("ESP + God Mode + GUI ativados!")
```

## Features Disponíveis

### Core
- **config.lua**: Tema, unidades, defaults
- **state.lua**: Sistema de listeners e persistência
- **utils.lua**: Funções comuns

### Features
- **gui.lua**: Interface completa com toggles e sliders
- **esp.lua**: Visualização de inimigos com reputação
- **god.lua**: Imortalidade
- **train.lua**: Treino automático com remotes
- **player.lua**: Speed, Jump, Movement

## Persistência

Todas as configurações são salvas em `HNkTTF_config.json` automaticamente quando você:
- Ativa/desativa uma feature
- Muda um slider (FOV)

As configs são carregadas na próxima execução.

## Troubleshooting

### "Admin remote não encontrado"
O servidor precisa ter o script admin (`HNkAdminRemote` em ReplicatedStorage).

### ESP não mostra inimigos
- Certifique-se que os inimigos têm uma Head no Character
- Verifique se a reputação deles está sendo lida corretamente

### Train não funciona
Os remotes de treino precisam existir em ReplicatedStorage:
- `TrainEquipment/Remote`
- `TrainSystem/Remote`

## Personalizações

### Trocar Cores do Tema
Edite `core/config.lua`:
```lua
Config.ACCENT_ON = Color3.fromRGB(255, 60, 60)    -- Vermelho (ON)
Config.ACCENT_OFF = Color3.fromRGB(100, 100, 100) -- Cinza (OFF)
Config.PRIMARY_BG = Color3.fromRGB(15, 15, 15)    -- Preto principal
Config.DARK_BG = Color3.fromRGB(25, 25, 25)       -- Preto claro
```

### Adicionar Nova Feature
1. Crie um arquivo em `features/sua_feature.lua`
2. Use `State.onChange()` para listeners
3. Crie um loader em `loaders/sua_feature_only.lua`
4. Exporte funções `enable()`, `disable()`, `toggle()`

## Exemplo Completo de Script Customizado

```lua
-- Seu script personalizado
local core = game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core")
local features = game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("features")

local State = require(core:WaitForChild("state"))
local GUI = require(features:WaitForChild("gui"))
local ESP = require(features:WaitForChild("esp"))
local Train = require(features:WaitForChild("train"))

-- Inicia com GUI
GUI.create()

-- Auto-ativa para farming
State.set("Train", true)
State.set("Speed", true)
State.set("AntiAFK", true)

-- Ouve mudanças de God Mode
State.onChange("God", function(enabled)
    print("God Mode: " .. (enabled and "ON" or "OFF"))
end)

print("Setup de Farming ativado!")
```

---

**Versão**: 9.4.3  
**Autor**: HNk  
**Data**: 2026
