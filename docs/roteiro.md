# Roteiro de execucao e testes

## 1. Preparacao no WSL 2

No Ubuntu, trabalhe de preferencia no sistema de arquivos Linux, evitando problemas de permissao do Git em `/mnt/c`:

```bash
mkdir -p ~/projetos
cp -a /mnt/c/Users/SEU_USUARIO/Downloads/linux-iac-servidor-web-apache ~/projetos/
cd ~/projetos/linux-iac-servidor-web-apache
```

Se o projeto ja estiver em `~/projetos`, nao e necessario copiar novamente.

## 2. Validacao sem alterar o computador

```bash
bash tests/teste_estatico.sh
bash scripts/provisionar.sh --dry-run
```

## 3. Provisionamento real (laboratorio)

```bash
sudo bash scripts/provisionar.sh
bash scripts/verificar.sh
curl -I http://127.0.0.1/
```

Abra no navegador do Windows: <http://localhost/>. Em WSL 2, o encaminhamento de `localhost` normalmente funciona. Se nao funcionar, verifique a configuracao de rede do WSL e se outro servidor ocupa a porta 80.

## 4. Comandos de diagnostico

```bash
sudo apache2ctl configtest
sudo apache2ctl -S
sudo ss -lntp | grep ':80'
ls -l /etc/apache2/sites-enabled/
ls -l /var/www/iac-dio-web/
```

Se systemd estiver ativo: `systemctl status apache2`. Sem systemd, use `sudo apache2ctl -k restart`.

## 5. Git e GitHub

Crie antes um repositorio publico **vazio**, sem README automatico, chamado `linux-iac-servidor-web-apache`. Na pasta do projeto:

```bash
git init
git branch -M main
git add .
git commit -m "feat: provisiona servidor web Apache com Bash"
git remote add origin https://github.com/SEU_USUARIO/linux-iac-servidor-web-apache.git
# Se ja autenticou no GitHub CLI anteriormente: gh auth status && gh auth setup-git
git push -u origin main
```

Configure `git config --global user.name` e `git config --global user.email` com dados reais antes do commit. Nunca use token de acesso pessoal nos arquivos do projeto.
