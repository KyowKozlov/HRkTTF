# 🚀 COMO USAR - HNk Hub v9.4.3 (CORRIGIDO)

## ⚡ USO RÁPIDO

### Opção 1: Hub Completo (Recomendado)
Cole isto no console do Roblox (F9):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/KyowKozlov/HRkTTF/main/loaders/full.lua"))()
```

**O que você verá:**
- ✅ GUI aparece no canto direito
- ✅ Todos os botões funcionam
- ✅ FPS/PING aparecem no topo direito

---

## 🎮 CONTROLES

### Na GUI
- **Clique nos botões** para ativar/desativar features
- **Arraste a GUI** pela barra de título
- **"-"** para minimizar/expandir
- **"X"** para fechar

### Atalhos de Teclado
- **Scroll do Mouse** quando `FOVMouseControl` está ativado = Mudar FOV

---

## 📋 FEATURES E O QUE FAZEM

### Shadow Core
- ⚔️ **Train** - Treina automaticamente
- ⏳ **AntiAFK** - Previne disconnect por inatividade ✅ **CORRIGIDO**
- 💀 **AntiFall** - Evita morrer ao cair

### Visuals
- 👁️ **ESP** - Mostra informações de outros jogadores
- 📊 **PerformanceOverlay** - Mostra FPS e PING ✅ **CORRIGIDO**
- 🖱️ **FOVMouseControl** - Controlar FOV com scroll
- 🔲 **MinimalMode** - Interface compacta
- 🔭 **FOV Slider** - Ajustar campo de visão (70-120)

### Player
- 🛡️ **God** - Imortalidade ✅ **FUNCIONANDO**
- 🦾 **GodExtreme** - Imortalidade extrema ✅ **CORRIGIDO**
- 🏃 **Speed** - Velocidade 120 (normal é 16)
- ⬆️ **Jump** - Pulo forte (150 power)
- 👻 **Invisible** - Ficar invisível ✅ **CORRIGIDO**

---

## 💻 USO PROGRAMÁTICO

### Depois de carregar, você pode fazer:

```lua
local State = getgenv().HNkState

-- ATIVAR/DESATIVAR FEATURES
State.set("God", true)          -- Ativa God Mode
State.set("ESP", true)          -- Ativa ESP
State.set("Train", true)        -- Ativa Train
State.set("Speed", true)        -- Ativa Speed (120)
State.set("Jump", true)         -- Ativa Jump (150)
State.set("AntiAFK", true)      -- Ativa Anti-AFK ✅
State.set("AntiFall", true)     -- Ativa Anti-Fall
State.set("Invisible", true)    -- Ativa Invisibilidade ✅

-- DESATIVAR
State.set("God", false)         -- Desativa God Mode
State.set("ESP", false)         -- Desativa ESP

-- VERIFICAR STATUS
if State.get("God") then
    print("God Mode está ATIVADO")
end

-- MUDAR FOV (Camera Zoom)
State.set("FOV", 100)           -- FOV de 100 graus

-- OUVIR MUDANÇAS
State.onChange("God", function(enabled)
    if enabled then
        print("💪 God Mode ATIVADO!")
    else
        print("❌ God Mode DESATIVADO!")
    end
end)
```

---

## 🔧 TROUBLESHOOTING

### Problema: GUI não aparece
**Solução:** Verifique se você carregou o script corretamente
```lua
-- Verifique no console (F9)
print(getgenv().HNkState)  -- Deve retorhing algo, não nil
```

### Problema: Botão não funciona
**Solução:** Verifique os logs
```lua
-- Deve aparecer algo como:
-- [Hooks]: Ativando God Mode loop
-- Se não aparecer, há um erro
```

### Problema: Script diz que Admin Remote não encontrado
**Solução:** Algumas features precisam do servidor ter um admin remote
- Verifique se `HNkAdminRemote` existe em `ReplicatedStorage`
- Se não existir, essas features não funcionarão:
  - GodExtreme
  - Invisible

---

## 📊 CONFIGURAÇÕES PADRÃO

```lua
-- Essas features começam ATIVADAS:
ESP = true
God = true
GodExtreme = true
AntiAFK = true
AntiFall = true
PerformanceOverlay = true
Invisible = true

-- Essas começam DESATIVADAS:
Speed = false
Jump = false
Train = false
FOVMouseControl = false
MinimalMode = false

-- Esses são valores:
FOV = 90  -- Campo de visão padrão
```

---

## 🛠️ OPÇÕES DE CARREGAMENTO

### Full (Recomendado)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/KyowKozlov/HRkTTF/main/loaders/full.lua"))()
```
Carrega: GUI + todas as features

### Apenas GUI
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/KyowKozlov/HRkTTF/main/loaders/gui_only.lua"))()
```
Carrega: Apenas interface, você controla via Estado

### Apenas ESP
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/KyowKozlov/HRkTTF/main/loaders/esp_only.lua"))()
```

### Apenas God
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/KyowKozlov/HRkTTF/main/loaders/god_only.lua"))()
```

### Apenas Train
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/KyowKozlov/HRkTTF/main/loaders/train_only.lua"))()
```

---

## 📈 INFORMAÇÕES DE DEBUG

Se tiver problemas, execute isto no console (F9):

```lua
-- Ver estado de tudo
print("=== HNk Hub Status ===")
print("Config:", getgenv().HNkConfig ~= nil)
print("Utils:", getgenv().HNkUtils ~= nil)
print("State:", getgenv().HNkState ~= nil)
print("Hooks:", getgenv().HNkHooks ~= nil)
print("God:", getgenv().HNkState.get("God"))
print("ESP:", getgenv().HNkState.get("ESP"))
print("Train:", getgenv().HNkState.get("Train"))
print("AntiAFK:", getgenv().HNkState.get("AntiAFK"))
print("GodExtreme:", getgenv().HNkState.get("GodExtreme"))
print("Invisible:", getgenv().HNkState.get("Invisible"))
```

---

## ✨ NOVIDADES DESTA VERSÃO

**v9.4.3 - FIX BUILD 1**

- ✅ **AntiAFK agora funciona** (estava sem listener)
- ✅ **GodExtreme agora funciona** (estava sem listener)
- ✅ **Invisible agora funciona** (estava sem listener)
- ✅ **PerformanceOverlay mostra FPS/PING** (foi implementado)
- ✅ Todos os buttons da GUI agora executam ações
- ✅ Sem erros de sintaxe

---

## 📝 GUIA RÁPIDO

| Ação | Código |
|------|--------|
| Ativar God | `getgenv().HNkState.set("God", true)` |
| Desativar God | `getgenv().HNkState.set("God", false)` |
| Ver status God | `getgenv().HNkState.get("God")` |
| Ativar ESP | `getgenv().HNkState.set("ESP", true)` |
| Ativar Train | `getgenv().HNkState.set("Train", true)` |
| Ativar Speed | `getgenv().HNkState.set("Speed", true)` |
| Mudar FOV | `getgenv().HNkState.set("FOV", 100)` |

---

## 🎯 RESULTADO ESPERADO

Após carregar o script você deve ver:

```
HNk Hub v9.4.3 - Iniciando carregamento completo...
[Loader] Etapa 1: Carregando modules CORE...
[Loader] Carregando: core/config.lua
[Loader] Carregando: core/utils.lua
[Loader] Etapa 2: Carregando STATE...
[Loader] Carregando: core/state.lua
[Loader] Etapa 3: Carregando HOOKS...
[Loader] Carregando: core/hooks.lua
[Loader] Etapa 4: Carregando GUI...
[Loader] Carregando: features/gui.lua
[Loader] Etapa 5: Inicializando sistema...
[GUI]: Interface criada com sucesso
[Loader] Etapa 6: Ativando listeners e loops...
[Hooks]: Inicializando listeners e loops...
[Hooks]: ✅ Hooks inicializados com sucesso!
✅ HNk Hub v9.4.3 COMPLETO ATIVADO COM SUCESSO!
📊 GUI + Todas as features prontas para uso!
```

---

**Última atualização:** 31/01/2026
**Versão:** v9.4.3 - FIX BUILD 1
**Status:** ✅ Pronto para uso
