#!/bin/bash

log_file="mobile_log.txt"
limit=1024 # 1 MB em kilobytes
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')

if [ ! -e "$log_file" ]; then
  touch "$log_file"
fi

check_process() {
  check_log
  ps -C mobile >/dev/null
}

check_log() {
  tamanho=$(du -k "$log_file" | cut -f1)

  if [ "$tamanho" -gt "$limit" ]; then
    echo -n >"$log_file"
  fi
}

check_process

if [ $? -ne 0 ]; then
  mensagem="${current_datetime} [INFO] : O processo 'mobile' não está em execução."
  echo "$mensagem" >>"$log_file"
  mobile >>"$log_file" 2>&1 &
else
  mensagem="${current_datetime} [INFO] : O processo 'mobile' está em execução."
  echo "$mensagem" >>"$log_file"
fi
