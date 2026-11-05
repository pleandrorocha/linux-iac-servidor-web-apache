#!/usr/bin/env bash
set -Eeuo pipefail

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) echo "Uso: sudo bash scripts/provisionar.sh [--dry-run]"; exit 0 ;;
    *) echo "Argumento desconhecido: $arg" >&2; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname -- "$SCRIPT_DIR")"
SITE_SOURCE="$PROJECT_DIR/site/index.html"
WEB_ROOT="/var/www/iac-dio-web"
CONF_FILE="/etc/apache2/sites-available/iac-dio-web.conf"
SITE_NAME="iac-dio-web.conf"

log() { printf '[IaC Web] %s\n' "$*"; }
run() {
  if (( DRY_RUN )); then
    printf '[SIMULACAO]'; printf ' %q' "$@"; printf '\n'
  else
    "$@"
  fi
}

[[ -f "$SITE_SOURCE" ]] || { echo "Pagina nao encontrada: $SITE_SOURCE" >&2; exit 1; }
if (( ! DRY_RUN )) && (( EUID != 0 )); then
  echo 'Execute como root: sudo bash scripts/provisionar.sh' >&2
  exit 1
fi

if [[ ! -f /etc/os-release ]] || ! grep -qi 'debian' /etc/os-release && ! grep -qi 'ubuntu' /etc/os-release; then
  echo 'Este projeto foi desenvolvido para Ubuntu/Debian.' >&2
  exit 1
fi

log 'Instalando Apache e ferramentas de teste (se necessario)'
run apt-get update
run env DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 curl

log 'Criando diretorio e publicando pagina do projeto'
run install -d -m 0755 "$WEB_ROOT"
run install -m 0644 "$SITE_SOURCE" "$WEB_ROOT/index.html"

log 'Configurando VirtualHost na porta 80'
if (( DRY_RUN )); then
  printf '[SIMULACAO] escrever configuracao em %s\n' "$CONF_FILE"
else
  cat > "$CONF_FILE" <<CONF
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot $WEB_ROOT

    <Directory $WEB_ROOT>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/iac-dio-web-error.log
    CustomLog \${APACHE_LOG_DIR}/iac-dio-web-access.log combined
</VirtualHost>
CONF
fi

log 'Habilitando site, desabilitando pagina padrao e validando configuracao'
run a2dissite 000-default.conf
run a2ensite "$SITE_NAME"
run apache2ctl configtest

log 'Iniciando/recarregando Apache'
if (( DRY_RUN )); then
  log '[SIMULACAO] iniciar ou recarregar Apache com systemctl ou apache2ctl'
elif command -v systemctl >/dev/null 2>&1 && [[ "$(ps -p 1 -o comm= 2>/dev/null || true)" == systemd ]]; then
  systemctl enable apache2
  systemctl restart apache2
else
  # WSL e containers podem nao executar systemd como PID 1.
  apache2ctl -k restart || apache2ctl -k start
fi

if (( DRY_RUN )); then
  log 'Simulacao concluida: nenhuma alteracao realizada.'
else
  log 'Provisionamento concluido. Valide com: bash scripts/verificar.sh'
fi
