#!/bin/bash

add() {
  grep -Fq "$1" mycron || echo "$1" >> mycron
}

#add '0 18 * * 1-5 cd /home/pi/util/backupy && /usr/bin/python3 main.py > /tmp/output.log queue:work'
add '0 18 * * 1-5 cd /home/pi/util/backupy && sudo ./main.bin > /tmp/output.log queue:work'
