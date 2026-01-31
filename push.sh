#!/bin/bash

# ===================================
# PUSH.SH - Wrapper simples para git push
# ===================================
# Use: ./push.sh "mensagem de commit"

REPO_PATH="/workspaces/HRkTTF"
COMMIT_MSG="${1:-Auto-push: Atualizações automáticas}"
BRANCH="main"

cd "$REPO_PATH" || exit 1

echo "🔄 Git Status:"
git status --short

echo ""
echo "📝 Preparando commit..."
git add .

echo "💾 Comitando mudanças..."
git commit -m "$COMMIT_MSG" --allow-empty

echo "🚀 Enviando para GitHub..."
git push origin $BRANCH

if [ $? -eq 0 ]; then
    echo "✅ Push realizado com sucesso!"
else
    echo "❌ Erro ao fazer push"
    exit 1
fi
