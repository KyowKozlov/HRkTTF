# 📋 Índice de Arquivos - HNk Hub v9.4.3 Modular

## 📚 Documentação

| Arquivo | Descrição |
|---------|-----------|
| [README.md](README.md) | Visão geral do projeto |
| [USAGE.md](USAGE.md) | Guia completo de uso |
| [QUICK_START.lua](QUICK_START.lua) | Exemplos rápidos de código |
| [SETUP_REPLICATEDSTORAGE.md](SETUP_REPLICATEDSTORAGE.md) | Como organizar em um jogo |
| [INDEX.md](INDEX.md) | Este arquivo |

## 🔧 Core (Núcleo)

`core/` - Módulos compartilhados por todas as features

| Arquivo | Funções | Descrição |
|---------|---------|-----------|
| [config.lua](core/config.lua) | `Config.DEFAULTS`, `Config.UNITS`, `Config.ACCENT_ON` | Configurações globais (cores, temas) |
| [state.lua](core/state.lua) | `State.set()`, `State.get()`, `State.onChange()` | Gerenciador de estado global com listeners |
| [utils.lua](core/utils.lua) | `Utils.formatNumber()`, `Utils.findEnemyPower()` | Funções utilitárias comuns |

## 🎮 Features (Funcionalidades)

`features/` - Módulos de features independentes

| Arquivo | Funções | Descrição |
|---------|---------|-----------|
| [gui.lua](features/gui.lua) | `GUI.create()`, `GUI.createToggle()`, `GUI.createSlider()` | Interface gráfica com toggles e sliders |
| [esp.lua](features/esp.lua) | `ESP.enable()`, `ESP.disable()`, `ESP.toggle()` | Visualização de inimigos com reputação |
| [god.lua](features/god.lua) | `God.enable()`, `God.disable()`, `God.toggle()` | Imortalidade básica |
| [train.lua](features/train.lua) | `Train.enable()`, `Train.disable()`, `Train.toggle()` | Auto-treino automático |
| [player.lua](features/player.lua) | `Player.enable()`, `Player.disable()` | Speed, Jump, Movement |

## 🚀 Loaders (Pontos de Entrada)

`loaders/` - Scripts executáveis para carregar features

| Arquivo | O que carrega | Tamanho | Uso |
|---------|---------------|--------|-----|
| [gui_only.lua](loaders/gui_only.lua) | Apenas GUI | ~5 KB | Controle manual via interface |
| [esp_only.lua](loaders/esp_only.lua) | Apenas ESP | ~3 KB | Visualização de inimigos |
| [god_only.lua](loaders/god_only.lua) | Apenas God Mode | ~2 KB | Imortalidade |
| [train_only.lua](loaders/train_only.lua) | Apenas Train | ~2 KB | Auto-treino |
| [full.lua](loaders/full.lua) | GUI + TUDO | ~20 KB | Experiência completa ⭐ |

## 🧪 Testes

| Arquivo | Descrição |
|---------|-----------|
| [test_local.lua](test_local.lua) | Testes básicos de estrutura e formatação |

## 📊 Resumo de Estrutura

```
HNkHub (Total: ~150 KB)
├── core/ (30 KB)
│   ├── config.lua (2 KB)
│   ├── state.lua (3 KB)
│   └── utils.lua (5 KB)
├── features/ (80 KB)
│   ├── gui.lua (25 KB)
│   ├── esp.lua (20 KB)
│   ├── god.lua (8 KB)
│   ├── train.lua (15 KB)
│   └── player.lua (12 KB)
└── loaders/ (20 KB)
    ├── gui_only.lua (1 KB)
    ├── esp_only.lua (1 KB)
    ├── god_only.lua (1 KB)
    ├── train_only.lua (1 KB)
    └── full.lua (3 KB)
```

## 🔗 Referências Rápidas

### Como começar?
→ Leia [QUICK_START.lua](QUICK_START.lua)

### Como funciona tudo?
→ Leia [USAGE.md](USAGE.md)

### Como organizar em um jogo?
→ Leia [SETUP_REPLICATEDSTORAGE.md](SETUP_REPLICATEDSTORAGE.md)

### Como criar uma nova feature?
→ Veja [USAGE.md](USAGE.md) seção "Extensibilidade"

### API Global
```lua
local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))
State.set("God", true)      -- Ativa
State.get("God")            -- Verifica
State.onChange("God", func) -- Ouve mudanças
```

## 🎯 Casos de Uso Comuns

### "Quero carregar tudo com GUI"
```lua
loadstring(game:HttpGet("...loaders/full.lua"))()
```

### "Quero apenas ESP"
```lua
loadstring(game:HttpGet("...loaders/esp_only.lua"))()
```

### "Quero uma combinação customizada"
Veja [QUICK_START.lua](QUICK_START.lua) - Seção SETUP 1/2/3

### "Quero adicionar uma nova feature"
1. Crie `features/minha_feature.lua`
2. Siga o padrão de `features/god.lua`
3. Crie `loaders/minha_feature_only.lua`
4. Use em `full.lua`

## 📞 Suporte Rápido

| Dúvida | Resposta |
|--------|----------|
| Onde começo? | [QUICK_START.lua](QUICK_START.lua) |
| Como usar? | [USAGE.md](USAGE.md) |
| Como montar no jogo? | [SETUP_REPLICATEDSTORAGE.md](SETUP_REPLICATEDSTORAGE.md) |
| Qual loader uso? | Tabela de Loaders acima |
| Como adicionar feature? | [USAGE.md](USAGE.md) - Extensibilidade |

---

**Versão**: 9.4.3 Modular Edition  
**Total de arquivos**: 15 (11 .lua, 4 .md)  
**Última atualização**: 31 de Janeiro de 2026  
**Status**: ✅ Pronto para uso
