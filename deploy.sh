#!/bin/bash
# deploy.sh — Executar na VPS para atualizar o app
# Uso: bash deploy.sh

set -e

APP_DIR="/opt/lab_app"           # Diretório onde o repositório foi clonado na VPS
STACK_NAME="lab_app"
IMAGE_NAME="lab_app:latest"

echo "🔄 [1/4] Atualizando código via git pull..."
cd "$APP_DIR"
git pull origin main

echo "🏗️  [2/4] Construindo imagem Docker..."
docker build -t "$IMAGE_NAME" .

echo "🚀 [3/4] Fazendo deploy da stack no Swarm..."
docker stack deploy -c docker-stack.yml "$STACK_NAME" --with-registry-auth

echo "✅ [4/4] Deploy concluído!"
echo ""
echo "Verifique os serviços com:"
echo "  docker service ls"
echo "  docker service logs ${STACK_NAME}_web --follow"
