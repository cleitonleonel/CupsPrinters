import os
import time
import serial

ip = os.popen("echo $SSH_CLIENT|awk '{print $1}'").read().replace('\n', '')
os.system('mkdir -m 777 -p $PWD/dev')

command = f'socat pty,link=$PWD/dev/ttyV0,waitslave tcp:{ip}:3333,reuseaddr,keepalive'
os.popen(command)
time.sleep(0.5)


def read_weight():
    ser = serial.Serial(
        port='dev/ttyV0',
        baudrate=4800,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
        timeout=1
    )

    ser.write(b'\x05')

    line = ser.readline().decode('utf-8').replace('\x02', '').replace('\x03', '')

    if line != '':
        result = line[:-3] + "." + line[-3:]
        print(float(result))


if os.path.exists('dev/ttyV0'):
    read_weight()
