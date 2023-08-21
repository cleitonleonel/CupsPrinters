#!/bin/bash
set -a
echo 'Iniciando Intalação do Sistema...'

apt update & apt list --upgradable & apt upgrade -y
echo 'Instalando libs extra...'

apt install libhdf5-dev -y
apt install libpq-dev -y
apt install libssl-dev zlib1g-dev gcc g++ make -y
apt install cups -y
apt install build-essential cmake libcups2-dev libcupsimage2-dev system-config-printer -y
apt install cups-bsd -y
apt install mutt -y
apt install ssh -y
apt install putty -y
apt install net-tools -y
apt install samba -y
apt install apache2 php php7.4-cli libapache2-mod-php curl -y
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
apt install git php7.4-gd php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-soap php7.4-zip php7.4-mbstring libphp7.4-embed -y
apt install bison flex xmlsec1 libxml2-utils openssl rename putty-tools smbclient -y
apt install ttf-mscorefonts-installer -y
apt install printer-driver-all -y

os_version=$(lsb_release -rs)
. /etc/os-release

if (( $(echo "$os_version >= 20.04" | bc -l) )); then
  echo "A versão do Ubuntu é maior do que 20.04."
  sudo apt-get -y install xorg-server-source
  sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2."$VERSION_CODENAME"_amd64.deb -O wkhtmltox_0.12.6.1."$VERSION_CODENAME"_amd64.deb
else
  echo "A versão do Ubuntu é menor ou igual a 20.04."
  sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2."$VERSION_CODENAME"_amd64.deb -O wkhtmltox_0.12.6.1."$VERSION_CODENAME"_amd64.deb
fi

sudo apt install -y './wkhtmltox_0.12.6.1.'$VERSION_CODENAME'_amd64.deb'
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
		echo "$username:$password" | chpasswd
		[ $? -eq 0 ] && echo "Usuário adicionado ao sistema!" || echo "Falha ao adicionar usuário!"
	fi
else
	echo "Apenas o root pode adicionar um usuário ao sistema"
	exit 2
fi

echo 'Criando usuário usuario'
if [ $(id -u) -eq 0 ]; then
	username='usuario'
	password='usuario123'
	grep "$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
	else
		adduser --gecos "" --disabled-password $username
		echo "$username:$password" | chpasswd
		[ $? -eq 0 ] && echo "Usuário adicionado ao sistema!" || echo "Falha ao adicionar usuário!"
	fi
else
	echo "Apenas o root pode adicionar um usuário ao sistema"
	exit 2
fi

echo 'Definindo senha root...'
password_root='@HBD1601$y$@dm1n'
echo "root:$password_root" | chpasswd

echo 'Adicionando usuário ao sudoers'
#echo "" >> /etc/sudoers
#echo "melinux    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
#sed -i '$d' /etc/sudoers
sh -c "echo 'melinux    ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
sh -c "echo 'usuario    ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"

echo 'Dando permissões ao usuário melinux'
chmod -R 777 /home/melinux

echo 'Instalando arquivo de configuração do Apache2 para acesso a localhost/nfe e emissão de NFe e NFCe...'
wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/000-default.conf -O /etc/apache2/sites-enabled/000-default.conf
chmod 777 /etc/apache2/sites-enabled/000-default.conf

echo 'Instalando arquivo de configuração do Hosts...'
wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/hosts -O /etc/hosts
chmod 777 /etc/hosts

echo 'Instalando arquivo de configuração de Rede...'
wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/00-installer-config.yaml -O /etc/netplan/00-installer-config.yaml
chmod 777 /etc/netplan/00-installer-config.yaml
rm /etc/netplan/01-network-manager-all.yaml

echo 'Restart Apache...'
/etc/init.d/apache2 restart

echo 'Instalando arquivo de configuração do CUPS...'
wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/cupsd.conf -O /etc/cups/cupsd.conf
chmod 777 /etc/cups/cupsd.conf

echo 'Restart CUPS...'
/etc/init.d/cups restart

echo 'Instalando arquivo de configuração do samba'
wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/smb.conf -O /etc/samba/smb.conf
chmod 777 /etc/samba/smb.conf

echo 'Restart Samba'
/etc/init.d/smbd restart

echo 'Instalando arquivo de configuração do Putty'
mkdir -p /home/$SUDO_USER/.putty/sessions/
chmod 777 /home/$SUDO_USER/.putty
wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/melinux -O /home/$SUDO_USER/.putty/sessions/melinux
chmod 777 /home/$SUDO_USER/.putty/sessions/melinux

echo 'Correção necessária para possíveis erros de ssh'
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server

echo 'Instalando libsnfe4...'
#chmod +x ./gdrivedl.sh
#./gdrivedl https://drive.google.com/file/d/1KO9mFpou2dy3fbCln8t4FQe4fWC9WZLl/view?usp=sharing libs-nfe4.zip
gdrive_download () {
	#export fileid=1KO9mFpou2dy3fbCln8t4FQe4fWC9WZLl
	#export filename=libs-nfe4.zip
	fileid=$1
	filename=$2
	wget --save-cookies cookies.txt 'https://docs.google.com/uc?export=download&id='$fileid -O- | sed -rn "s/.*confirm=([0-9A-Za-z_]+).*/\\1/p" > confirm.txt
	value=`cat confirm.txt`
	wget --load-cookies cookies.txt -O $filename 'https://docs.google.com/uc?-export=download&id='$fileid'&confirm='$value
}

gdrive_download 1KO9mFpou2dy3fbCln8t4FQe4fWC9WZLl libs-nfe4.zip
rm ./confirm.txt
rm ./cookies.txt

echo 'Extraindo arquivos na raíz...'
unzip -o libs-nfe4.zip -d /
rm ./libs-nfe4.zip

echo 'Instalando dependências de libsnfe...'
wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/Danfce.php -O /var/www/melinux/nfe/libs/Extras/Danfce.php
wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/img.zip -O img.zip
unzip img.zip -d /var/www/melinux/
rm ./img.zip
chown -R www-data:www-data -R /var/www/melinux
chmod 777 -R /var/www/melinux

echo 'Dando permissão a www-data...'
chown -R www-data:www-data -R /var/www/melinux
chmod 777 -R /var/www/melinux

echo 'Visualisando permissões do diretório base...'
ls -ltr /var/www/melinux

echo 'Instalando Anydesk...'
wget https://download.anydesk.com/linux/anydesk_6.1.0-1_amd64.deb -O anydesk.deb
chmod 777 ./anydesk.deb
apt install -y ./anydesk.deb
rm ./anydesk.deb

echo 'Instalando Google Chrome...'
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
chmod 777 ./google-chrome-stable_current_amd64.deb
apt install -y ./google-chrome-stable_current_amd64.deb
rm ./google-chrome-stable_current_amd64.deb
apt autoremove -y

echo 'Instalando base do sistema melinux...'
wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/melinux.zip -O melinux.zip
chmod 777 ./melinux.zip
rm -r /home/melinux
unzip -o melinux.zip -d /home
mv /home/melinux/base_melinux/* /home/melinux
rm -r /home/melinux/base_melinux
chmod 777 -R /home/melinux
chown -R melinux:melinux /home/melinux
rm ./melinux.zip

echo 'Adicionando executável ao ~/.bashrc'
wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/.bashrc -O /home/melinux/.bashrc
#echo -e "./melinux" >> /home/melinux/.bashrc

echo "Criando atalhos do sistema..."
ln -sf /home/melinux/01/relatorios /home/$SUDO_USER/'Área de Trabalho'/RELATÓRIOS
ln -sf /home/melinux/01/nfe/xmls /home/$SUDO_USER/'Área de Trabalho'/XMLS
ln -sf /home/melinux/01/governo /home/$SUDO_USER/'Área de Trabalho'/GOVERNO
ln -sf /home/melinux/01/nfe/danfes /home/$SUDO_USER/'Área de Trabalho'/DANFES
cp /usr/share/applications/google-chrome.desktop /home/$SUDO_USER/'Área de Trabalho'
chmod 755 /home/$SUDO_USER/'Área de Trabalho'/google-chrome.desktop
cp /usr/share/applications/anydesk.desktop /home/$SUDO_USER/'Área de Trabalho'
chmod 755 /home/$SUDO_USER/'Área de Trabalho'/anydesk.desktop
wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/MELINUX.desktop -O /home/$SUDO_USER/'Área de Trabalho'/MELINUX.desktop
chmod 755 /home/$SUDO_USER/'Área de Trabalho'/MELINUX.desktop

echo 'Instalação Concluída...'
exit
