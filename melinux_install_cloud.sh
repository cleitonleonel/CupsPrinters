#!/bin/bash
set -a
echo 'Iniciando Intalação do Sistema...'

sudo apt update & sudo apt list --upgradable & sudo apt upgrade -y
echo 'Instalando libs extra...'

sudo apt install libhdf5-dev -y
sudo apt install libpq-dev -y
sudo apt install libssl-dev zlib1g-dev gcc g++ make -y
sudo apt install cups -y
sudo apt install build-essential cmake libcups2-dev libcupsimage2-dev system-config-printer -y
sudo apt install cups-bsd -y
sudo apt install mutt -y
sudo apt install ssh -y
sudo apt install putty -y
sudo apt install net-tools -y
sudo apt install samba -y
sudo apt install apache2 php php7.4-cli libapache2-mod-php curl -y
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo apt install git php7.4-gd php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-soap php7.4-zip php7.4-mbstring libphp7.4-embed -y
sudo apt install bison flex xmlsec1 libxml2-utils openssl rename putty-tools smbclient -y
sudo apt install ttf-mscorefonts-installer -y
sudo apt install printer-driver-all -y
sudo apt install dialog -y

os_version=$(lsb_release -rs)
. /etc/os-release

if (( $(echo "$os_version >= 20.04" | bc -l) )); then
  echo "A versão do Ubuntu é maior do que 20.04."
  sudo apt-get -y install xorg-server-source
  sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2."$VERSION_CODENAME"_amd64.deb -O wkhtmltox_0.12.6.1."$VERSION_CODENAME"_amd64.deb
else
  echo "A versão do Ubuntu é menor ou igual a 20.04."
  sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1."$VERSION_CODENAME"_amd64.deb -O wkhtmltox_0.12.6.1."$VERSION_CODENAME"_amd64.deb
fi

sudo apt install -y './wkhtmltox_0.12.6.1.'$VERSION_CODENAME'_amd64.deb'
sudo mv /usr/local/bin/wkhtmltopdf /usr/bin

echo 'Criando usuário otma'
if [ $(id -u) -eq 0 ]; then
	username='otma'
	password='melinux'
	grep "$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
	else
		adduser --gecos "" --disabled-password $username
		echo "$username:$password" | sudo chpasswd
		[ $? -eq 0 ] && echo "Usuário adicionado ao sistema!" || echo "Falha ao adicionar usuário!"
	fi
else
	echo "Apenas o root pode adicionar um usuário ao sistema"
	exit 2
fi

echo 'Adicionando usuário otma ao sudoers'
sudo sh -c "echo 'otma    ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"

echo 'Dando permissões ao usuário otma'
chmod -R 777 /home/melinux

echo 'Instalando arquivo de configuração do Apache2 para acesso a localhost/nfe e emissão de NFe e NFCe...'
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/000-default.conf -O /etc/apache2/sites-enabled/000-default.conf
sudo chmod 777 /etc/apache2/sites-enabled/000-default.conf

echo 'Instalando arquivo de configuração do Hosts...'
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/hosts -O /etc/hosts
sudo chmod 777 /etc/hosts

echo 'Instalando DBU, gerenciador de base de dados dbf...'
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/config/linux/ubuntu/dbu -O /usr/bin/dbu
sudo chmod 777 /usr/bin/dbu

echo 'Restart Apache...'
/etc/init.d/apache2 restart

echo 'Instalando arquivo de configuração do CUPS...'
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/cupsd.conf -O /etc/cups/cupsd.conf
sudo chmod 777 /etc/cups/cupsd.conf

echo 'Restart CUPS...'
sudo /etc/init.d/cups restart

echo 'Instalando arquivo de configuração do samba'
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/smb.conf -O /etc/samba/smb.conf
sudo chmod 777 /etc/samba/smb.conf

echo 'Restart Samba'
sudo /etc/init.d/smbd restart

echo 'Correção necessária para possíveis erros de ssh'
sudo rm /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server

echo 'Instalando libsnfe4...'
#sudo chmod +x ./gdrivedl.sh
#./gdrivedl https://drive.google.com/file/d/1KO9mFpou2dy3fbCln8t4FQe4fWC9WZLl/view?usp=sharing libs-nfe4.zip

#export fileid=1KO9mFpou2dy3fbCln8t4FQe4fWC9WZLl
#export filename=libs-nfe4.zip
gdrive_download () {
	fileid=$1
	filename=$2
	wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- | sed -rn "s/.*confirm=([0-9A-Za-z_]+).*/\\1/p" > confirm.txt
	value=`cat confirm.txt`
	wget --load-cookies cookies.txt -O $filename 'https://docs.google.com/uc?-export=download&id='$fileid'&confirm='$value
}

gdrive_download 1KO9mFpou2dy3fbCln8t4FQe4fWC9WZLl libs-nfe4.zip
sudo rm ./confirm.txt
sudo rm ./cookies.txt

echo 'Extraindo arquivos na raíz...'
sudo unzip -o libs-nfe4.zip -d /
sudo rm ./libs-nfe4.zip

echo 'Instalando dependências de libsnfe...'
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/Danfce.php -O /var/www/melinux/nfe/libs/Extras/Danfce.php
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/img.zip -O img.zip
sudo unzip img.zip -d /var/www/melinux/
sudo rm ./img.zip
sudo chown -R www-data:www-data -R /var/www/melinux
sudo chmod 777 -R /var/www/melinux

echo 'Dando permissão a www-data...'
sudo chown -R www-data:www-data -R /var/www/melinux
sudo chmod 777 -R /var/www/melinux

echo 'Visualisando permissões do diretório base...'
sudo ls -ltr /var/www/melinux

echo 'Instalação Concluída...'
exit
