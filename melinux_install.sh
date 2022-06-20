#!/bin/bash 
set -a 
echo 'Iniciando Intalação do Sistema...'

sudo apt update & sudo apt list --upgradable & sudo apt upgrade -y 
echo 'Instalando libs extra...'

sudo apt install libhdf5-dev -y 
sudo apt install libpq-dev -y 
sudo apt install libssl-dev zlib1g-dev gcc g++ make -y 
#sudo apt install wkhtmltopdf -y
sudo apt install cups -y 
sudo apt install build-essential cmake libcups2-dev libcupsimage2-dev system-config-printer -y 
sudo apt install cups-bsd -y 
sudo apt install mutt -y 
sudo apt install ssh -y 
sudo apt install putty -y 
sudo apt install net-tools -y 
sudo apt install samba -y 
sudo apt install apache2 php php-cli libapache2-mod-php curl -y 
curl -sS https://getcomposer.org/installer | php 
sudo mv composer.phar /usr/local/bin/composer 
sudo apt install git php-gd php-xml php-xmlrpc php-curl php-soap php-zip php-mbstring libphp-embed -y 
sudo apt install bison flex xmlsec1 libxml2-utils openssl rename putty-tools smbclient -y 
sudo apt install ttf-mscorefonts-installer -y 
sudo apt install printer-driver-all -y

. /etc/os-release

#sudo wget 'https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.'$VERSION_CODENAME'_amd64.deb'
sudo wget 'https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.'$VERSION_CODENAME'_amd64.deb -O wkhtmltox_0.12.6-1.focal_amd64.deb'
sudo apt install -y './wkhtmltox_0.12.6-1.'$VERSION_CODENAME'_amd64.deb'
sudo mv /usr/local/bin/wkhtmltopdf /usr/bin

echo 'Criando usuário melinux'
if [ $(id -u) -eq 0 ]; then 
	username='melinux' 
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

echo 'Definindo senha root...' 
password_root='@HBD1601$y$@dm1n' 
echo "root:$password_root" | sudo chpasswd

echo 'Adicionando usuário ao sudoers'
#echo "" >> /etc/sudoers
#echo "melinux    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
#sudo sed -i '$d' /etc/sudoers
sudo sh -c "echo 'melinux    ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"

echo 'Dando permissões ao usuário melinux' 
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

echo 'Instalando arquivo de configuração de Rede...' 
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/00-installer-config.yaml -O /etc/netplan/00-installer-config.yaml 
sudo chmod 777 /etc/netplan/00-installer-config.yaml 
sudo rm /etc/netplan/01-network-manager-all.yaml

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

echo 'Instalando arquivo de configuração do Putty' 
sudo mkdir -p /home/$SUDO_USER/.putty/sessions/ 
sudo chmod 777 /home/$SUDO_USER/.putty 
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/melinux -O /home/$SUDO_USER/.putty/sessions/melinux 
sudo chmod 777 /home/$SUDO_USER/.putty/sessions/melinux

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

echo 'Instalando Anydesk...' 
sudo wget https://download.anydesk.com/linux/anydesk_6.1.0-1_amd64.deb -O anydesk.deb 
sudo chmod 777 ./anydesk.deb 
sudo apt install -y ./anydesk.deb 
sudo rm ./anydesk.deb

echo 'Instalando Google Chrome...' 
sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 
sudo chmod 777 ./google-chrome-stable_current_amd64.deb 
sudo apt install -y ./google-chrome-stable_current_amd64.deb 
sudo rm ./google-chrome-stable_current_amd64.deb 
sudo apt autoremove -y

echo 'Instalando base do sistema melinux...' 
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/melinux.zip -O melinux.zip 
sudo chmod 777 ./melinux.zip
sudo rm -r /home/melinux
sudo unzip -o melinux.zip -d /home
sudo mv /home/melinux/base_melinux/* /home/melinux
sudo rm -r /home/melinux/base_melinux 
sudo chmod 777 -R /home/melinux
chown -R melinux:melinux /home/melinux 
sudo rm ./melinux.zip

echo 'Adicionando executável ao ~/.bashrc'
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/.bashrc -O /home/melinux/.bashrc
#echo -e "./melinux" >> /home/melinux/.bashrc

echo "Criando atalhos do sistema..." 
sudo ln -sf /home/melinux/01/relatorios /home/$SUDO_USER/'Área de Trabalho'/RELATÓRIOS
sudo ln -sf /home/melinux/01/nfe/xmls /home/$SUDO_USER/'Área de Trabalho'/XMLS
sudo ln -sf /home/melinux/01/governo /home/$SUDO_USER/'Área de Trabalho'/GOVERNO
sudo ln -sf /home/melinux/01/nfe/danfes /home/$SUDO_USER/'Área de Trabalho'/DANFES
sudo cp /usr/share/applications/google-chrome.desktop /home/$SUDO_USER/'Área de Trabalho' 
sudo chmod 755 /home/$SUDO_USER/'Área de Trabalho'/google-chrome.desktop
sudo cp /usr/share/applications/anydesk.desktop /home/$SUDO_USER/'Área de Trabalho' 
sudo chmod 755 /home/$SUDO_USER/'Área de Trabalho'/anydesk.desktop
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/MELINUX.desktop -O /home/$SUDO_USER/'Área de Trabalho'/MELINUX.desktop
sudo chmod 755 /home/$SUDO_USER/'Área de Trabalho'/MELINUX.desktop

echo 'Instalação Concluída...'
exit
