# Setup em ReplicatedStorage

Para usar este script modularizado em um jogo Roblox, você precisa colocar os arquivos em **ReplicatedStorage**.

## Estrutura Esperada no Jogo

```
ReplicatedStorage/
└── HNkHub/
    ├── core/
    │   ├── config.lua
    │   ├── state.lua
    │   └── utils.lua
    ├── features/
    │   ├── gui.lua
    │   ├── esp.lua
    │   ├── god.lua
    │   ├── train.lua
    │   └── player.lua
    └── loaders/
        ├── gui_only.lua
        ├── esp_only.lua
        ├── god_only.lua
        ├── train_only.lua
        └── full.lua
```

## Passo a Passo

### 1. Preparar Arquivos

Você tem 3 opções:

#### Opção A: Upload Manual no Studio
1. Abra o jogo no Roblox Studio
2. Na aba Explorer, encontre `ReplicatedStorage`
3. Clique direito → Insert Object → Folder
4. Nomeie como `HNkHub`
5. Para cada arquivo `.lua`:
   - Clique direito na pasta → Insert Object → LocalScript
   - Renomeie para o nome do arquivo (sem `.lua`)
   - Copie o conteúdo do arquivo para dentro

#### Opção B: Via Script (Automático)
Cole isto em um Script do ServerScriptService:

```lua
-- Criar estrutura automaticamente
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function createModule(parent, name, content)
    local module = Instance.new("ModuleScript", parent)
    module.Name = name
    module.Source = content
end

local function createFolder(parent, name)
    local folder = Instance.new("Folder", parent)
    folder.Name = name
    return folder
end

-- Cria pasta HNkHub
local hnkHub = createFolder(ReplicatedStorage, "HNkHub")

-- Cria subpastas
local core = createFolder(hnkHub, "core")
local features = createFolder(hnkHub, "features")
local loaders = createFolder(hnkHub, "loaders")

print("✅ Estrutura de pastas criada!")
print("Agora copie o conteúdo dos arquivos .lua para cada módulo")
```

#### Opção C: Asset String (Para Servidores)
Se o seu servidor suporta `loadstring` com HTTP, você pode fazer:

```lua
-- Em um LocalScript no Player
loadstring(game:HttpGet("https://seu-servidor.com/loaders/full.lua"))()
```

### 2. Organizar Módulos

Após criar a estrutura, copie o conteúdo de cada arquivo:

**Core Modules:**
- `ReplicatedStorage/HNkHub/core/config` ← conteúdo de `core/config.lua`
- `ReplicatedStorage/HNkHub/core/state` ← conteúdo de `core/state.lua`
- `ReplicatedStorage/HNkHub/core/utils` ← conteúdo de `core/utils.lua`

**Features:**
- `ReplicatedStorage/HNkHub/features/gui` ← conteúdo de `features/gui.lua`
- `ReplicatedStorage/HNkHub/features/esp` ← conteúdo de `features/esp.lua`
- `ReplicatedStorage/HNkHub/features/god` ← conteúdo de `features/god.lua`
- `ReplicatedStorage/HNkHub/features/train` ← conteúdo de `features/train.lua`
- `ReplicatedStorage/HNkHub/features/player` ← conteúdo de `features/player.lua`

**Loaders (LocalScripts):**
- `ReplicatedStorage/HNkHub/loaders/gui_only` ← conteúdo de `loaders/gui_only.lua`
- `ReplicatedStorage/HNkHub/loaders/esp_only` ← conteúdo de `loaders/esp_only.lua`
- `ReplicatedStorage/HNkHub/loaders/god_only` ← conteúdo de `loaders/god_only.lua`
- `ReplicatedStorage/HNkHub/loaders/train_only` ← conteúdo de `loaders/train_only.lua`
- `ReplicatedStorage/HNkHub/loaders/full` ← conteúdo de `loaders/full.lua`

### 3. Testar

No console do jogo (F9 em Studio ou execute scripts):

```lua
-- Teste 1: Carregar apenas GUI
local gui = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("features"):WaitForChild("gui"))
gui.create()
print("GUI carregada!")

-- Teste 2: Ativar God Mode
local state = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))
state.set("God", true)
print("God Mode ativado!")

-- Teste 3: Executar loader completo
require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("loaders"):WaitForChild("full"))
print("Loader completo executado!")
```

## Deploy para Servidor

Se você quer que os jogadores usem isto:

### 1. Opção: StarterPlayer
Coloque um LocalScript em `StarterPlayer/StarterCharacterScripts/` que faça:

```lua
wait(1) -- Espera o character carregar
require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("loaders"):WaitForChild("full"))
```

### 2. Opção: Console Command
Dê ao jogador um comando para executar no console:

```lua
require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("loaders"):WaitForChild("full"))
```

### 3. Opção: HTTP Loader
Se hospedar em um servidor:

```lua
loadstring(game:HttpGet("https://seu-site.com/loaders/full.lua"))()
```

## Troubleshooting

| Problema | Solução |
|----------|---------|
| "ModuleScript not found" | Certifique-se que a estrutura de pastas está certa |
| "Infinite yield" | Verifique que todos os módulos existem |
| Features não ativam | Confira que State.lua está carregando corretamente |
| GUI não aparece | Verifique CoreGui não está bloqueada |

## Dicas

✅ Use ModuleScripts para `core/` e `features/`  
✅ Use LocalScripts para `loaders/` (são pontos de entrada)  
✅ Teste localmente no Studio antes de fazer deploy  
✅ Guarde backups dos scripts originais  
✅ Não compartilhe credenciais/tokens nos arquivos  

---

**Versão**: 9.4.3  
**Última atualização**: 31 de Janeiro de 2026
