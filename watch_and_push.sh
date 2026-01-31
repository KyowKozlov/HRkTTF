#!/bin/bash

# ===================================
# WATCH AND PUSH - Monitora mudanças e faz push automático
# ===================================

REPO_PATH="/workspaces/HRkTTF"
PUSH_SCRIPT="$REPO_PATH/auto_push.sh"
WATCH_LOG="$REPO_PATH/watch.log"
COOLDOWN=5  # Aguardar 5 segundos após mudança antes de fazer push

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$WATCH_LOG"
}

# Tornar scripts executáveis
chmod +x "$PUSH_SCRIPT" 2>/dev/null

log "🔍 WATCH AND PUSH INICIADO"
log "Monitorando: $REPO_PATH"
log "Script de push: $PUSH_SCRIPT"
log "Cooldown: ${COOLDOWN}s"
log ""

# Se inotify-tools está disponível, usar inotifywait (mais eficiente)
if command -v inotifywait &> /dev/null; then
    log "✅ inotifywait detectado - usando monitoramento eficiente"
    
    while true; do
        # Aguardar por mudanças em arquivos Lua, MD, TXT, JSON
        inotifywait -r -e modify,create,delete \
            --exclude '\.git|node_modules|__pycache__|\.swp|\.lock' \
            -q "$REPO_PATH" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            log "📝 Mudanças detectadas, aguardando ${COOLDOWN}s..."
            sleep "$COOLDOWN"
            
            log "🚀 Executando auto_push.sh..."
            bash "$PUSH_SCRIPT"
            
            if [ $? -eq 0 ]; then
                log "✅ Push concluído com sucesso"
            else
                log "❌ Erro no push, tente novamente manualmente"
            fi
        fi
    done
else
    log "⚠️  inotifywait não encontrado, usando polling (menos eficiente)"
    log "Dica: instale inotify-tools para melhor performance"
    
    last_hash=""
    poll_interval=10
    
    while true; do
        sleep "$poll_interval"
        
        # Hash dos arquivos modificados recentemente
        current_hash=$(find "$REPO_PATH" -type f \
            -not -path '*/\.git/*' \
            -not -path '*node_modules*' \
            -newer "$WATCH_LOG" 2>/dev/null | \
            sort | md5sum | cut -d' ' -f1)
        
        if [ "$current_hash" != "$last_hash" ] && [ -n "$current_hash" ]; then
            log "📝 Mudanças detectadas, aguardando ${COOLDOWN}s..."
            sleep "$COOLDOWN"
            
            log "🚀 Executando auto_push.sh..."
            bash "$PUSH_SCRIPT"
            
            if [ $? -eq 0 ]; then
                log "✅ Push concluído com sucesso"
            else
                log "❌ Erro no push, tente novamente manualmente"
            fi
            
            last_hash="$current_hash"
        fi
    done
fi
