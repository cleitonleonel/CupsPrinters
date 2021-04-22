#!/bin/bash
sudo wget https://raw.githubusercontent.com/cleitonleonel/CupsPrinters/master/smb.conf -O /etc/samba/smb.conf
sudo chmod 777 /etc/samba/smb.conf
sudo /etc/init.d/smbd restart