#!/bin/bash
echo 'Iniciando Intalação do Sistema...'
sudo apt update & sudo apt list --upgradable & sudo apt upgrade -y

echo 'Instalando arquivo de dependências...'
wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/install-dep.sh -O dependencies.sh

echo 'Dando permissão ao arquivo...'
chmod +x ./dependencies.sh

echo 'Executando setup de dependências...'
./dependencies.sh

echo 'Instalando libs extra...'
sudo apt install libhdf5-dev -y
sudo apt install -y libpq-dev -y
sudo apt install -y libssl-dev zlib1g-dev gcc g++ make
sudo apt-get install wkhtmltopdf -y
sudo apt install cups -y
sudo apt install build-essential cmake libcups2-dev libcupsimage2-dev system-config-printer -y
sudo apt install cups-bsd -y

echo 'Instalando libsnfe4...'
wget https://github.com/cleitonleonel/CupsPrinters/raw/master/libsnfe4.zip -O libs-nfe4.zip

echo 'Extraindo arquivos na raíz...'
sudo unzip -o libs-nfe4.zip -d /

echo 'Dando permissão a pasta www-data...'
sudo chown -R www-data:www-data -R /var/www/melinux
sudo chmod 777 -R /var/www/melinux

echo 'Visualisando permissões do diretório base...'
sudo ls -ltr /var/www/melinux