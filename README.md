# HNk Hub v9.4.3 - Modular Edition

Uma versão **totalmente modularizada** do script HNk TTF Hub para Roblox.

## 🎯 O que é isto?

Um script monolítico transformado em uma arquitetura **modular**, onde cada feature funciona **independentemente**. Você pode carregar apenas o que precisa ou tudo junto!

## 📁 Estrutura

```
HNkHub/
├── core/                 # Núcleo compartilhado
│   ├── config.lua       # Configurações (cores, unidades)
│   ├── state.lua        # Gerenciador de estado
│   └── utils.lua        # Funções utilitárias
├── features/            # Features separadas
│   ├── gui.lua          # Interface gráfica
│   ├── esp.lua          # Visão de inimigos
│   ├── god.lua          # Imortalidade
│   ├── train.lua        # Auto-train
│   └── player.lua       # Speed/Jump
└── loaders/             # Scripts de carregamento
    ├── gui_only.lua
    ├── esp_only.lua
    ├── god_only.lua
    ├── train_only.lua
    └── full.lua
```

## 🚀 Como Usar

**GUI Completa (Recomendado)**
```lua
loadstring(game:HttpGet("https://seu-link/loaders/full.lua"))()
```

**Apenas ESP**
```lua
loadstring(game:HttpGet("https://seu-link/loaders/esp_only.lua"))()
```

**Apenas God Mode**
```lua
loadstring(game:HttpGet("https://seu-link/loaders/god_only.lua"))()
```

**Apenas Train**
```lua
loadstring(game:HttpGet("https://seu-link/loaders/train_only.lua"))()
```

**Apenas Interface (Manual)**
```lua
loadstring(game:HttpGet("https://seu-link/loaders/gui_only.lua"))()
```

## 💻 API Global

```lua
local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))

State.set("God", true)      -- Ativa God
State.set("ESP", false)     -- Desativa ESP
State.get("God")            -- Retorna true/false
State.getAll()              -- Retorna todas as configs
```

## 🎨 Features Disponíveis

- GUI com toggles e sliders
- ESP (visão de inimigos)
- God Mode (imortalidade)
- Auto Train
- Speed/Jump
- Anti-AFK
- Anti-Fall
- Invisible
- FOV Control

## ✨ Benefícios

✅ Modular - cada feature independente  
✅ Leve - carregue só o que precisa  
✅ Flexível - combine features  
✅ Extensível - adicione novas features  
✅ Persistente - salva configurações  

Para guia completo, veja [USAGE.md](USAGE.md)
