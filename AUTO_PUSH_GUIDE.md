# 📤 GUIA DE AUTO-PUSH - HNk Hub v9.4.3

## 🚀 Como Usar

### Opção 1: Push Manual Rápido (Recomendado para testes)
```bash
cd /workspaces/HRkTTF
./push.sh "Descrição da mudança"
```

### Opção 2: Auto-Push com Monitoramento Contínuo
```bash
cd /workspaces/HRkTTF
./watch_and_push.sh
```

Este comando:
- ✅ Monitora mudanças em tempo real
- ✅ Faz commit automático
- ✅ Faz push para GitHub
- ✅ Registra tudo em `watch.log`

### Opção 3: Script de Auto-Push Único
```bash
cd /workspaces/HRkTTF
./auto_push.sh
```

---

## 📋 Exemplos de Uso

### Push com mensagem customizada
```bash
./push.sh "ESP: Corrigido cache de poder"
```

### Push com mensagem padrão
```bash
./push.sh
```

### Monitoramento contínuo (ideal para desenvolvimento)
```bash
./watch_and_push.sh &
# Agora qualquer mudança em arquivo será automaticamente commitada e pusheada
```

---

## 📝 O que cada script faz

| Script | Função | Uso |
|--------|--------|-----|
| `push.sh` | Push simples e rápido | Manual, quando você quiser controlar |
| `auto_push.sh` | Push único com logging | Automação, chamado por watch_and_push.sh |
| `watch_and_push.sh` | Monitora e faz push contínuo | Background, desenvolvimento ativo |

---

## 🔧 Configuração

### Usar em Background (nunca parar de monitora)
```bash
nohup ./watch_and_push.sh > /dev/null 2>&1 &
echo $! > watch_and_push.pid
```

### Parar o monitoramento
```bash
kill $(cat watch_and_push.pid)
rm watch_and_push.pid
```

### Ver logs
```bash
tail -f watch.log
tail -f auto_push.log
```

---

## ✅ Configuração Automática já Feita

Git está configurado com:
- ✅ Repositório: `KyowKozlov/HRkTTF`
- ✅ Branch: `main`
- ✅ Remote: `origin`

---

## 🎯 Próximos Passos

1. **Modo Manual (Agora):**
   ```bash
   ./push.sh "Mensagem da mudança"
   ```

2. **Modo Automático (Para desenvolvimento contínuo):**
   ```bash
   nohup ./watch_and_push.sh > /dev/null 2>&1 &
   ```

3. **Verificar no GitHub:**
   - Abra https://github.com/KyowKozlov/HRkTTF
   - As mudanças devem aparecer em alguns segundos

---

## 📊 Logs Disponíveis

- `auto_push.log` - Log do último auto_push.sh
- `watch.log` - Log do watch_and_push.sh

---

**Status:** ✅ Sistema de auto-push configurado e pronto!
