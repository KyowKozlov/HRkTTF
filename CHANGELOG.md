# 📝 Changelog & Versionamento

## v9.4.3 Modular Edition (Current)

### ✨ Novo
- ✅ Arquitetura completamente modularizada
- ✅ 5 loaders independentes (gui_only, esp_only, god_only, train_only, full)
- ✅ Sistema de State com listeners
- ✅ API global para scripting
- ✅ Documentação completa (8 arquivos .md/.txt)
- ✅ 10 exemplos avançados
- ✅ FAQ com 20+ perguntas
- ✅ Setup guide para ReplicatedStorage

### 🔧 Melhorias
- Código reorganizado em módulos reutilizáveis
- Remotes agora centralizados em Train module
- Utils com funções comuns (format, find, etc)
- Config centralizado para temas e defaults
- Listeners para todas as mudanças de estado
- Persistência automática de configurações

### 🎯 Features
- GUI com toggles e sliders modernos
- ESP com cores de reputação
- God Mode básico e extremo
- Auto Train com remotes
- Speed/Jump/Movement
- Anti-AFK e Anti-Fall
- Invisible e FOV Control
- Performance Overlay

### 📊 Estrutura
```
15 arquivos total
11 arquivos .lua (módulos + loaders)
4 arquivos .md (documentação)
1 arquivo .txt (setup)
~150 KB total
```

### 🐛 Correções
- Remotes agora tratados com try-catch
- Estado global inicializado corretamente
- Listeners não causam loops infinitos
- GUI não duplica elementos

### 📋 Conhecidos Limitações
- Admin remote pode não existir em todos servidores
- Remotes mudam nome frequentemente entre updates
- Anti-cheat forte pode bloquear

---

## v9.4.2 (Anterior)

### Descrição
Script monolítico original com todas features em um arquivo.

### Problemas
- ❌ 1 arquivo gigante (~2000 linhas)
- ❌ Tudo carregado de uma vez
- ❌ Difícil de modificar
- ❌ Sem modularização

---

## Roadmap Futuro

### v9.5.0 (Planejado)
- [ ] Sistema de presets salváveis
- [ ] Dashboard de estatísticas
- [ ] Hotkeys customizáveis via GUI
- [ ] Auto-update de remotes
- [ ] Suporte a múltiplos perfis
- [ ] Log system com histórico

### v10.0.0 (Futuro)
- [ ] Reescrita completa com TypeScript
- [ ] Compilação para Lua via build tool
- [ ] Sistema de plugins
- [ ] Dashboard web para config
- [ ] Cloud sync de profiles

---

## Matriz de Compatibilidade

| Feature | v9.4.3 | Compatibilidade |
|---------|--------|-----------------|
| GUI | ✅ | Todos os jogos |
| ESP | ✅ | Maioria dos jogos |
| God Mode | ✅ | Maioria dos jogos |
| God Extreme | ⚠️ | Requer admin remote |
| Train | ⚠️ | Depende do jogo |
| Speed | ✅ | Todos os jogos |
| Jump | ✅ | Todos os jogos |
| Anti-AFK | ✅ | Todos os jogos |
| Anti-Fall | ✅ | Todos os jogos |
| Invisible | ⚠️ | Requer admin remote |
| FOV Control | ✅ | Todos os jogos |

---

## Histórico de Mudanças por Feature

### GUI
- v9.4.2: Interface básica com buttons
- v9.4.3: Redesign moderno com tema preto/vermelho, toggles animados, sliders

### ESP
- v9.4.2: Apenas nome e poder
- v9.4.3: Cores de reputação, cache otimizado, billboards dinâmicos

### God Mode
- v9.4.2: Apenas health restore
- v9.4.3: Separado em God + GodExtreme, com remote admin

### Train
- v9.4.2: Remotes diretos
- v9.4.3: Centralizado em module, try-catch, inicialização lazy

### Speed/Jump
- v9.4.2: Heartbeat direto
- v9.4.3: Módulo player.lua com gerenciamento centralizado

---

## Notas Técnicas

### Por que Modularizar?

**Problema Original:**
```
script_gigante.lua (2000+ linhas)
├─ Config
├─ Utils
├─ GUI
├─ ESP
├─ God
├─ Train
├─ Player
└─ Main loops
```

Impossível de manter, estender ou debugar.

**Solução:**
```
15 arquivos focados
├─ core/ (núcleo compartilhado)
├─ features/ (cada feature é um módulo)
└─ loaders/ (pontos de entrada)
```

Cada arquivo ~100-200 linhas, responsabilidade única.

### Design Patterns Usados

1. **Module Pattern** - Cada feature é um módulo isolado
2. **Observer Pattern** - State.onChange() para listeners
3. **Factory Pattern** - GUI.create() cria elementos
4. **Lazy Loading** - Features carregam sob demanda
5. **Dependency Injection** - Modules requerem dependências

### Decisões de Arquitetura

1. **Por que ReplicatedStorage?**
   - Acessível de LocalScripts
   - Sincroniza com clientes
   - Padrão Roblox

2. **Por que ModuleScript?**
   - Reutilizável
   - Cache automático
   - Sem delay de carregamento

3. **Por que State.onChange()?**
   - Desacoplamento de features
   - Múltiplos listeners
   - Reatividade

4. **Por que 5 loaders?**
   - Cada caso de uso tem um loader
   - Não carregue o que não precisa
   - Lighter than full by default

---

## Estatísticas do Projeto

| Métrica | Valor |
|---------|-------|
| Arquivos .lua | 11 |
| Arquivos .md | 4 |
| Linhas de código | ~2500 |
| Linhas de docs | ~1500 |
| Tamanho total | ~150 KB |
| Features | 11 |
| Modules | 8 |
| Loaders | 5 |
| Exemplos | 10 |
| Perguntas FAQ | 20+ |

---

## Suporte & Manutenção

### Como reportar bugs?
1. Reproduza o problema
2. Verifique se está em FAQ.md
3. Se não está, documente tudo:
   - Jogo que estava usando
   - Steps para reproduzir
   - Output do console
   - Features ativadas

### Como sugerir melhorias?
1. Descreva a ideia
2. Explique o benefício
3. Sugira implementação
4. Coloque em "Roadmap Futuro"

### Como contribuir?
1. Fork o projeto
2. Crie um branch (feature/xyz)
3. Implemente mudanças
4. Teste tudo
5. Faça commit com mensagem clara
6. Abra PR com descrição

---

## Versioning

Seguimos **Semantic Versioning**:
- **MAJOR** (9.x → 10.x): Breaking changes, reescrita
- **MINOR** (9.4 → 9.5): Novas features
- **PATCH** (9.4.2 → 9.4.3): Bugfixes

---

## Data de Lançamento

- **v9.4.3 Modular**: 31 de Janeiro de 2026
- **Última atualização**: 31 de Janeiro de 2026

---

## Créditos

Desenvolvido com ❤️ para a comunidade Roblox.

Baseado no original "HNk TTF AUTO-TRAIN + POWER ESP HUB v9.4.3"

Refatorado e modularizado em Janeiro/2026.

---

## Licença

Para uso pessoal em Roblox.
Não redistribuir sem permissão.

---

**Fim do Changelog**
