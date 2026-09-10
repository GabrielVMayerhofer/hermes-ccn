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
    echo "[GitHub] GITHUB_TOKEN encontrado."

    echo "[GitHub] Usuário autenticado:"
    gh api user --jq '.login'

    # Permite que o Git use o token para clone/pull/push
    git config --global credential.helper \
        '!f() { echo "username=x-access-token"; echo "password=$GITHUB_TOKEN"; }; f'
else
    echo "[GitHub] GITHUB_TOKEN não configurado"
fi


# =========================
# Configuração do projeto
# =========================

PROJECT_DIR="/opt/data/criacompmain"

if [ ! -d "$PROJECT_DIR/.git" ]; then

    echo "[Git] Clonando fork..."

    git clone \
        "https://github.com/GabrielVMayerhofer/criacomp.git" \
        "$PROJECT_DIR"

    cd "$PROJECT_DIR"

    echo "[Git] Adicionando upstream..."

    git remote add upstream \
        "https://github.com/filipecalegario/criacomp.git"

else

    echo "[Git] Repositório já existe."

    cd "$PROJECT_DIR"

    git fetch origin
    git fetch upstream
fi


echo "[Git] Remotes:"
git remote -v


# =========================
# Hermes
# =========================

exec hermes gateway run