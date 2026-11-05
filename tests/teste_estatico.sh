#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bash -n "$ROOT/scripts/provisionar.sh"
bash -n "$ROOT/scripts/verificar.sh"
test -s "$ROOT/site/index.html"
grep -q 'Servidor Web Provisionado' "$ROOT/site/index.html"
bash "$ROOT/scripts/provisionar.sh" --dry-run >/dev/null
printf '%s\n' 'Testes de sintaxe, HTML e simulacao: OK'
