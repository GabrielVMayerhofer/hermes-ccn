#!/bin/bash
set -e

echo "[Hermes] Configurando OpenCode Free..."

hermes config set model.default deepseek-v4-flash-free
hermes config set model.provider opencode-free
hermes config set model.base_url https://opencode.ai/zen/v1
hermes config set model.api_mode chat_completions

echo "[Hermes] Modelo configurado:"
hermes config get model --json

exec hermes gateway run