#!/bin/bash
set -e

echo "[Hermes] Configurando OpenCode Free..."

hermes config set model.default nemotron-3.5-lightning-free
hermes config set model.provider opencode-free
hermes config set model.base_url https://opencode.ai/zen/v1
hermes config set model.api_mode chat_completions

echo "[Hermes] Modelo configurado:"
hermes config get model --json


# =========================
# GitHub
# =========================

if [ -n "${GITHUB_TOKEN:-}" ]; then
    echo "[GitHub] Configurando autenticação..."

    printf '%s\n' "$GITHUB_TOKEN" | gh auth login \
        --hostname github.com \
        --with-token

    gh auth setup-git

    echo "[GitHub] Usuário autenticado:"
    gh api user --jq '.login'
else
    echo "[GitHub] GITHUB_TOKEN não configurado"
fi


# =========================
# Hermes
# =========================

exec hermes gateway run