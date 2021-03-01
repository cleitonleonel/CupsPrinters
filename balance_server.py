import os
import sys
import time
import serial
from serial.tools import list_ports


ports = [tuple(p) for p in list(list_ports.comports())]
#  print(ports)

time.sleep(0.5)


def read_weight():
    ser = serial.Serial(
        port='/dev/ttyUSB0',
        baudrate=4800,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
        timeout=1
    )

    ser.write(b'\x05')

    # line = ser.read_until().decode('ascii').strip()

    line = ser.readline().decode('utf-8').replace('\x02', '').replace('\x03', '')
    result = line[:-3] + "." + line[-3:]

    if line:
        print(float(result))


if os.path.exists('/dev/ttyUSB0'):
    read_weight()
else:
    sys.exit()
