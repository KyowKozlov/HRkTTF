# ❓ FAQ - Perguntas Frequentes

## Básico

### P: Qual é a diferença entre os loaders?
**R:** Cada loader carrega uma combinação diferente:
- `gui_only` = Só interface (você controla tudo manualmente)
- `esp_only` = Só ESP (visualiza inimigos)
- `god_only` = Só God Mode (imortalidade)
- `train_only` = Só Auto Train (treino automático)
- `full` = **Tudo junto** (GUI + todas features) ⭐

**Recomendado:** Use `full.lua` para ter tudo.

---

### P: Como eu ativo/desativo features depois de carregar?
**R:** Use a API de State:

```lua
local State = require(game:GetService("ReplicatedStorage"):WaitForChild("HNkHub"):WaitForChild("core"):WaitForChild("state"))

State.set("God", true)   -- Ativa God
State.set("ESP", false)  -- Desativa ESP
```

---

### P: As configurações são salvas?
**R:** Sim! Automaticamente em `HNkTTF_config.json` quando:
- Você ativa/desativa uma feature
- Muda um slider (FOV)
- Fecha o jogo (se suportado)

Próxima vez que carregar, as configs são restauradas.

---

### P: Posso usar múltiplos loaders ao mesmo tempo?
**R:** Não é recomendado - pode causar conflitos. Use apenas um loader (preferencialmente `full.lua`) e controle features via GUI ou API.

---

## Troubleshooting

### P: A GUI não aparece
**R:** Possíveis causas:
1. **CoreGui bloqueada** - Alguns jogos bloqueiam GUI
2. **Script morreu** - Verifique o console para erros (F9)
3. **Carregamento incompleto** - Espere alguns segundos

**Solução:** Tente usar `esp_only.lua` ou `god_only.lua` para testar se o problema é só GUI.

---

### P: ESP não mostra inimigos
**R:** Verifique:
1. **Inimigos têm Head?** - ESP só funciona se player.Character.Head existe
2. **Longe demais?** - Inimigos muito distantes podem não aparecer
3. **ESP ativado?** - Verifique se `State.get("ESP")` retorna `true`

**Debug:** 
```lua
local State = require(...)
if State.get("ESP") then
    print("ESP está ativado")
else
    print("ESP está desativado")
    State.set("ESP", true)
end
```

---

### P: God Mode não funciona
**R:** Causas comuns:
1. **Remotes diferentes do esperado** - Cada jogo tem nomes diferentes
2. **Server atualizado** - Script pode estar desatualizado
3. **Não é invencível**? - Tente `GodExtreme` (requer admin remote)

**Debug:**
```lua
-- Teste se o heartbeat está rodando
local char = game.Players.LocalPlayer.Character
if char then
    local hum = char:FindFirstChild("Humanoid")
    print("Health: " .. (hum and hum.Health or "N/A"))
end
```

---

### P: Train não treina
**R:** Verificar:
1. **Remotes existem?** - Precise existir em ReplicatedStorage
   - `TrainEquipment/Remote/ApplyTakeUpStationaryTrainEquipment`
   - `TrainSystem/Remote/TrainSpeedHasChanged`
2. **Jogo atualizado?** - Nomes de remotes mudam frequentemente

**Debug:**
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
print(ReplicatedStorage:FindFirstChild("TrainEquipment"))
print(ReplicatedStorage:FindFirstChild("TrainSystem"))
```

---

### P: "Admin remote não encontrado"
**R:** Significa que você está tentando usar features que requerem admin:
- `Invisible`
- `GodExtreme`

**Solução:** 
- Se o servidor não tem admin remote, esses features não funcionam
- Desative-os em `State.set("Invisible", false)`
- Outras features (God, ESP, Train) funcionam sem admin

---

## Performance

### P: O script está deixando o jogo lento?
**R:** Use `PerformanceOverlay` para ver FPS/PING:

```lua
local State = require(...)
State.set("PerformanceOverlay", true)
```

Se FPS cair muito:
1. **Desative ESP** - Renderiza 50+ billboards
2. **Desative PerformanceOverlay** - Remove overlay
3. **Reduza FOV** - Menos para renderizar

---

### P: Qual loader é mais leve?
**R:** Por ordem:
1. `god_only.lua` - ~20 KB (mais leve)
2. `esp_only.lua` - ~30 KB
3. `train_only.lua` - ~25 KB
4. `gui_only.lua` - ~50 KB
5. `full.lua` - ~150 KB (mais pesado, mas completo)

---

## Customização

### P: Como mudar as cores?
**R:** Edite `core/config.lua`:

```lua
Config.ACCENT_ON = Color3.fromRGB(255, 60, 60)      -- Vermelho (ON)
Config.ACCENT_OFF = Color3.fromRGB(100, 100, 100)   -- Cinza (OFF)
Config.PRIMARY_BG = Color3.fromRGB(15, 15, 15)      -- Preto principal
Config.DARK_BG = Color3.fromRGB(25, 25, 25)         -- Preto claro
```

Depois reload o hub.

---

### P: Como adicionar uma nova feature?
**R:** 3 passos:
1. Crie `features/minha_feature.lua` (copie estrutura de `god.lua`)
2. Use `State.onChange()` para listeners
3. Crie `loaders/minha_feature_only.lua`

Veja [USAGE.md](USAGE.md#criar-nova-feature) para detalhes.

---

### P: Como criar um setup automatizado?
**R:** Veja [EXAMPLES.lua](EXAMPLES.lua) - Exemplo 1 (Presets).

---

## Deployment

### P: Como colocar em um servidor?
**R:** Veja [SETUP_REPLICATEDSTORAGE.md](SETUP_REPLICATEDSTORAGE.md).

Resumidamente:
1. Copie a estrutura para ReplicatedStorage
2. Use um LocalScript que faça `require(...loaders/full)`
3. Pronto!

---

### P: Como hospedar online?
**R:** 
1. Coloque os arquivos `.lua` em um servidor web
2. Use `loadstring(game:HttpGet("seu-url/loaders/full.lua"))()`

**Atenção:** Certifique-se que o servidor está configurado para servir arquivos `.lua` com o header certo.

---

## API & Scripting

### P: Como ouvir mudanças de estado?
**R:** Use `State.onChange()`:

```lua
State.onChange("God", function(enabled)
    if enabled then
        print("God Mode foi ATIVADO")
    else
        print("God Mode foi DESATIVADO")
    end
end)
```

---

### P: Como verificar status de tudo?
**R:**
```lua
local State = require(...)
local all = State.getAll()

for feature, value in pairs(all) do
    print(feature .. " = " .. tostring(value))
end
```

---

### P: Posso usar hotkeys?
**R:** Sim! Veja [EXAMPLES.lua](EXAMPLES.lua) - Exemplo 4 (Hotkeys).

```lua
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F1 then
        State.set("God", not State.get("God"))
    end
end)
```

---

## Segurança

### P: Este script é seguro?
**R:** 
- ✅ Sem injeção dinâmica de código
- ✅ Remotes validados antes de uso
- ✅ Try-catch em operações sensíveis
- ✅ Sem coleta de dados

**Mas:** Use com cuidado em servidores anti-cheat.

---

### P: Posso usar em qualquer jogo?
**R:** Depende:
- **❌ Não funciona em:** Servidores com anti-cheat forte
- **✅ Pode funcionar em:** Servidores casualizados ou com proteção fraca
- **❓ Testa:** Cada jogo é diferente

**Aviso:** Use por sua conta e risco.

---

## Misc

### P: Como resetar tudo para defaults?
**R:**
```lua
local State = require(...)
local Config = require(...)

for k, v in pairs(Config.DEFAULTS) do
    State.set(k, v)
end

print("✅ Resetado para defaults")
```

---

### P: Posso ter múltiplos perfis?
**R:** Sim! Veja [EXAMPLES.lua](EXAMPLES.lua) - Exemplo 5 (Profiles).

---

### P: Como debugar problemas?
**R:** Veja [EXAMPLES.lua](EXAMPLES.lua) - Exemplo 8 (Debug Mode).

---

### P: Onde está o código-fonte?
**R:** 
- [core/](core/) - Núcleo
- [features/](features/) - Features
- [loaders/](loaders/) - Entry points

Tudo é Lua puro, sem obfuscation.

---

### P: Como contribuir?
**R:** 
1. Faça melhorias
2. Crie um loader customizado
3. Compartilhe exemplos
4. Reporte bugs

---

## Suporte Rápido

| Problema | Solução |
|----------|---------|
| GUI não aparece | Verifique console (F9) para erros |
| ESP não funciona | Ative em `State.set("ESP", true)` |
| God não funciona | Remotes podem ter nomes diferentes |
| Train não ativa | Verifique remotes em ReplicatedStorage |
| Lento demais | Desative ESP, reduza FOV |
| Querror salva? | Salva automaticamente em `HNkTTF_config.json` |

---

## Referências

- [README.md](README.md) - Visão geral
- [USAGE.md](USAGE.md) - Guia completo
- [QUICK_START.lua](QUICK_START.lua) - Exemplos rápidos
- [EXAMPLES.lua](EXAMPLES.lua) - Exemplos avançados
- [SETUP_REPLICATEDSTORAGE.md](SETUP_REPLICATEDSTORAGE.md) - Setup em jogo
- [INDEX.md](INDEX.md) - Índice de arquivos

---

**Última atualização:** 31 de Janeiro de 2026  
**Versão:** 9.4.3 Modular
