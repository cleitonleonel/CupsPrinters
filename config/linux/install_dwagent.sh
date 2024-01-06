#!/bin/bash

# Define o diretório onde os arquivos do Dwagent serão instalados
DIR="/usr/share/dwagent/runtime/bin/"

# Função para instalação do Dwagent
install() {
  # Baixa o script dwagent.sh
  if wget https://www.dwservice.net/download/dwagent.sh; then
    # Dá permissões de execução ao script
    chmod +x ./dwagent.sh
    # Executa o script dwagent.sh
    sudo ./dwagent.sh
  else
    echo "Failed to download dwagent.sh. Exiting."
    exit 1
  fi
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
su - "$USER" -c "mkdir -p $HOME/.config/systemd/user"

# Move o arquivo de serviço para o diretório de configuração do usuário
sudo mv /etc/systemd/system/dwagent.service "$HOME/.config/systemd/user/"
# Altera as permissões do arquivo para o usuário atual
sudo chown "$USER:$USER" "$HOME/.config/systemd/user/dwagent.service"

# Modifica o arquivo de serviço para usar default.target
sed -i "s/WantedBy=multi-user.target/WantedBy=default.target/" "$HOME/.config/systemd/user/dwagent.service"

# Define as permissões do diretório do Dwagent
sudo chown -R "$USER:$USER" /usr/share/dwagent

# Habilita o login do usuário no sistema
sudo loginctl enable-linger "$USER"

echo "Intalação efetuada com sucesso, ativando serviços..."

# Ativa e inicia o serviço dwagent.service para o usuário
systemctl --user enable dwagent.service
systemctl --user start dwagent.service

# Descomente as linhas abaixo para ativar o serviço usando XDG_RUNTIME_DIR
# XDG_RUNTIME_DIR=/run/user/$UID systemctl --user enable dwagent.service
# XDG_RUNTIME_DIR=/run/user/$UID systemctl --user start dwagent.service
