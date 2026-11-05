# Infraestrutura como Codigo: Provisionamento de Servidor Web Apache

Projeto pratico de IaC em **Bash** para instalar e configurar o servidor **Apache2**, publicar uma pagina HTML e verificar a entrega via HTTP no Ubuntu/Debian. Desenvolvido como projeto de portfolio para o desafio da DIO; implementacao original e independente do repositorio de referencia do curso.

## Funcionalidades

- Instala `apache2` e `curl` usando `apt-get`.
- Cria o diretorio `/var/www/iac-dio-web` e publica `site/index.html`.
- Cria e habilita um VirtualHost na porta 80 com `DocumentRoot` dedicado.
- Desativa o site default (`000-default.conf`) para exibir a pagina do projeto.
- Valida sintaxe do Apache e inicia/reinicia o servico, inclusive em WSL sem systemd.
- Disponibiliza modo `--dry-run`, teste estatico e verificacao de resposta HTTP 200.

## Estrutura

```text
linux-iac-servidor-web-apache/
├── .github/workflows/validate.yml
├── .gitignore
├── README.md
├── docs/
│   ├── entrega-dio.md
│   └── roteiro.md
├── scripts/
│   ├── provisionar.sh
│   └── verificar.sh
├── site/index.html
└── tests/teste_estatico.sh
```

## Pre-requisitos

- Ubuntu ou Debian com `apt-get` e acesso a internet para instalar pacotes.
- Usuario com `sudo` para provisionamento real.
- Porta **80/TCP** livre. Se outra aplicacao estiver utilizando a porta, ajuste o ambiente de laboratorio antes de executar.
- Recomendado: VM ou WSL 2 de laboratorio. O script modifica a configuracao do Apache e desabilita o site padrao.

## Uso

```bash
# Na raiz do projeto
bash tests/teste_estatico.sh
bash scripts/provisionar.sh --dry-run
sudo bash scripts/provisionar.sh
bash scripts/verificar.sh
```

Abra `http://localhost/` no navegador do Windows caso esteja utilizando WSL 2. Se o encaminhamento de localhost nao funcionar, consulte `docs/roteiro.md`.

## Seguranca e observacoes

- Execute apenas em ambiente de laboratorio ou revise antes de aplicar em servidores existentes.
- Nao abre portas de firewall automaticamente; libere 80/TCP apenas conforme a necessidade. Na nuvem, ajuste tambem o Security Group.
- O Apache disponibiliza HTTP sem criptografia. Para uso publico, configure HTTPS/TLS e politicas de acesso.
- Reexecutar o script reescreve o VirtualHost do projeto e copia novamente a pagina HTML. Nao cria contas nem armazena senhas.
- O teste automatizado do GitHub valida os scripts sem instalar Apache no runner.

## Licenca

MIT. Veja `LICENSE`.
