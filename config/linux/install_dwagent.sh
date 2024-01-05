#!/bin/bash

# Define o diretório onde os arquivos do Dwagent serão instalados
DIR="$HOME/Downloads"

# Função para instalação do Dwagent
install() {
  # Baixa o script dwagent.sh
  wget https://www.dwservice.net/download/dwagent.sh
  # Dá permissões de execução ao script
  sudo chmod +x ./dwagent.sh
  # Executa o script dwagent.sh
  sudo ./dwagent.sh
}

# Verifica se o diretório não existe
if [ ! -d "$DIR" ]; then
  echo "Installing files in ${DIR}..."
  install
fi

# Para e desativa o serviço dwagent.service
sudo systemctl stop dwagent.service
sudo systemctl disable dwagent.service

# Diretório de configuração para o usuário
cd "$HOME" || exit
# Cria o diretório se ele não existir
sudo mkdir -p .config/systemd/user
cd .config/systemd/user/ || exit

# Move o arquivo de serviço para o diretório de configuração do usuário
sudo mv /etc/systemd/system/dwagent.service .
# Altera as permissões do arquivo para o usuário atual
sudo chown "$USER:$USER" dwagent.service

# Modifica o arquivo de serviço para usar default.target
sed -i 's/WantedBy=multi-user.target/WantedBy=default.target/' ~/.config/systemd/user/dwagent.service

# Define as permissões do diretório do Dwagent
sudo chown -R "$USER:$USER" /usr/share/dwagent
# Habilita o login do usuário no sistema
sudo loginctl enable-linger "$USER"

# Ativa e inicia o serviço dwagent.service para o usuário
sudo systemctl --user enable dwagent.service
sudo systemctl --user start dwagent.service

# Descomente as linhas abaixo para ativar o serviço usando XDG_RUNTIME_DIR
XDG_RUNTIME_DIR=/run/user/$UID systemctl --user enable dwagent.service
XDG_RUNTIME_DIR=/run/user/$UID systemctl --user start dwagent.service
