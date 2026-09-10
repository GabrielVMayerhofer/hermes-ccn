#!/bin/bash
set -e

# ============================================================
# Hermes - OpenCode Free
# ============================================================

echo "[Hermes] Configurando OpenCode Free..."

hermes config set model.default nemotron-3.5-lightning-free
hermes config set model.provider opencode-free
hermes config set model.base_url https://opencode.ai/zen/v1
hermes config set model.api_mode chat_completions

echo "[Hermes] Modelo configurado:"
hermes config get model --json


# ============================================================
# GitHub
# ============================================================

if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "[GitHub] ERRO: GITHUB_TOKEN não configurado."
    exit 1
fi

echo "[GitHub] Verificando autenticação..."

GITHUB_USER=$(gh api user --jq '.login')

echo "[GitHub] Autenticado como: $GITHUB_USER"


# Identidade dos commits
git config --global user.name "$GITHUB_USER"
git config --global user.email "${GITHUB_USER}@users.noreply.github.com"


# Autenticação HTTPS do Git
git config --global credential.helper \
    '!f() {
        echo "username=x-access-token";
        echo "password=$GITHUB_TOKEN";
    }; f'


# ============================================================
# Repositório
# ============================================================

PROJECT_DIR="/opt/data/criacomp"

FORK_URL="https://github.com/GabrielVMayerhofer/criacomp.git"
UPSTREAM_URL="https://github.com/filipecalegario/criacomp.git"


if [ ! -d "$PROJECT_DIR/.git" ]; then

    echo "[Git] Repositório não encontrado."
    echo "[Git] Clonando fork..."

    git clone "$FORK_URL" "$PROJECT_DIR"

    cd "$PROJECT_DIR"

    echo "[Git] Adicionando upstream..."

    git remote add upstream "$UPSTREAM_URL"

else

    echo "[Git] Repositório já existe."

    cd "$PROJECT_DIR"

    echo "[Git] Atualizando origin..."

    git fetch origin

    echo "[Git] Atualizando upstream..."

    # Garante que o upstream existe
    if git remote get-url upstream >/dev/null 2>&1; then
        git fetch upstream
    else
        echo "[Git] Upstream não encontrado. Adicionando..."

        git remote add upstream "$UPSTREAM_URL"

        git fetch upstream
    fi

fi


# ============================================================
# Verificação dos remotes
# ============================================================

echo ""
echo "[Git] ========================================"
echo "[Git] Remotes configurados:"
git remote -v
echo "[Git] ========================================"
echo ""


# ============================================================
# Configuração do diretório de trabalho do Hermes
# ============================================================

echo "[Hermes] Configurando diretório de trabalho..."

hermes config set terminal.cwd "$PROJECT_DIR"

echo "[Hermes] Diretório de trabalho:"
hermes config get terminal.cwd


# ============================================================
# Informações do repositório
# ============================================================

echo ""
echo "[Git] Diretório:"
pwd

echo "[Git] Branch atual:"
git branch --show-current

echo "[Git] Status:"
git status --short


# ============================================================
# Inicia Hermes Gateway
# ============================================================

echo ""
echo "[Hermes] Iniciando Gateway..."

exec hermes gateway run