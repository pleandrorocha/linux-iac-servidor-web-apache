#!/usr/bin/env bash
set -Eeuo pipefail

printf '%s\n' '=== Validacao do Apache ==='
command -v apache2 >/dev/null || { echo 'Apache nao instalado' >&2; exit 1; }
apache2ctl configtest
printf '%s\n' '=== Arquivos publicados ==='
test -s /var/www/iac-dio-web/index.html || { echo 'index.html ausente' >&2; exit 1; }
test -f /etc/apache2/sites-enabled/iac-dio-web.conf || { echo 'VirtualHost nao habilitado' >&2; exit 1; }
printf '%s\n' '=== Resposta HTTP ==='
status="$(curl --silent --output /dev/null --write-out '%{http_code}' --max-time 10 http://127.0.0.1/)"
echo "HTTP $status"
[[ "$status" == '200' ]] || { echo 'Falha no teste HTTP' >&2; exit 1; }
curl --fail --silent --show-error http://127.0.0.1/ | grep -q 'Servidor Web Provisionado' || {
  echo 'Pagina esperada nao localizada na resposta HTTP' >&2; exit 1;
}
printf '%s\n' 'VALIDACAO: OK'
