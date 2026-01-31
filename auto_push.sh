#!/bin/bash

# ===================================
# AUTO PUSH SCRIPT - HNk Hub v9.4.3
# ===================================
# Este script faz commit e push automático das mudanças para GitHub

REPO_PATH="/workspaces/HRkTTF"
LOG_FILE="$REPO_PATH/auto_push.log"
BRANCH="main"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função de log
log() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${BLUE}[$timestamp]${NC} $1" | tee -a "$LOG_FILE"
}

# Função de erro
error() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${RED}[$timestamp] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

# Função de sucesso
success() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${GREEN}[$timestamp] SUCCESS:${NC} $1" | tee -a "$LOG_FILE"
}

# Verificar se estamos no diretório correto
if [ ! -d "$REPO_PATH/.git" ]; then
    error "Não é um repositório Git válido: $REPO_PATH"
    exit 1
fi

cd "$REPO_PATH" || exit 1

log "Iniciando auto-push de mudanças..."
log "Repositório: $(git config --get remote.origin.url)"

# Verificar se há mudanças
if ! git status --quiet; then
    log "Mudanças detectadas, processando..."
    
    # Adicionar todos os arquivos
    git add . 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -ne 0 ]; then
        error "Falha ao executar git add"
        exit 1
    fi
    
    # Criar mensagem de commit com timestamp
    local commit_time=$(date "+%d/%m/%Y %H:%M:%S")
    local commit_msg="Auto-push: Atualizações automáticas - $commit_time"
    
    # Fazer commit
    git commit -m "$commit_msg" 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -ne 0 ]; then
        error "Falha ao executar git commit"
        exit 1
    fi
    
    # Fazer push
    git push origin $BRANCH 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        success "Push realizado com sucesso!"
        success "Commit: $commit_msg"
        log "Mudanças enviadas para GitHub"
    else
        error "Falha ao executar git push"
        exit 1
    fi
else
    log "Nenhuma mudança detectada"
fi

log "Auto-push concluído"
exit 0
