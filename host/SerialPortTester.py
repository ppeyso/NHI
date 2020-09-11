#!/usr/bin/env python3
"""
Copyright 2020 Nasim Hamrah Industries

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

import serial
import random
import os
import time

print("In the Name of ALLAH")
print("Universal Asynchronous Receiver Transmitter UART Tester:")

def LoopBackCounterTest(port, baudrate):
    error=0
    ser=serial.Serial()
    ser.port = port
    ser.baudrate = baudrate
    ser.open()
    # Up Counter
    i=0
    while ( i < 256 ) :
        si=(i).to_bytes(1, byteorder='big')
        ser.write(si)
        ri = ser.read()
        ii = int.from_bytes(ri, byteorder='big')
        if ( ii != i ) :
            error = error + 1
        i=i+1
    # Down Counter
    i=255
    while ( i > -1 ) :
        si=(i).to_bytes(1, byteorder='big')
        ser.write(si)
        ri = ser.read()
        ii = int.from_bytes(ri, byteorder='big')
        if ( ii != i ) :
            error = error + 1
        i=i-1
    ser.close()
    return error
    
def StreamUpCounterTest(port, baudrate):
    ser=serial.Serial()
    ser.port = port
    ser.baudrate = baudrate
    ser.open()
    # Up Counter
    i=0
    while ( i < 256 ) :
        si=(i).to_bytes(1, byteorder='big')
        ser.write(si)
        i=i+1
    ser.close()
    return True

def StreamDownCounterTest(port, baudrate):
    ser=serial.Serial()
    ser.port = port
    ser.baudrate = baudrate
    ser.open()
    # Down Counter
    i=255
    while ( i > -1 ) :
        si=(i).to_bytes(1, byteorder='big')
        ser.write(si)
        i=i-1
    ser.close()
    return True

def LoopBackRandomTest(port, baudrate):
    error=0
    ser=serial.Serial()
    ser.port = port
    ser.baudrate = baudrate
    ser.open()
    j=0
    while ( j < 1001 ) :
        i=random.randrange(255)
        si=(i).to_bytes(1, byteorder='big')
        ser.write(si)
        ri = ser.read()
        ii = int.from_bytes(ri, byteorder='big')
        if ( ii != i ) :
            error = error + 1
        j=j+1
    ser.close()
    return error

'''def TextFileTest(port, baudrate):
    i=0
    error=0
    ser=serial.Serial()
    ser.port = port
    ser.baudrate = baudrate
    tempFile = open('./../LGPL3','r')
    tempFileContent = tempFile.read()
    print(tempFileContent)
    tempFile.close()
    receivedFile = open("./LGPL3", "a")
    receivedFile.write(tempFileContent)
    receivedFile.close()
    ser.close()
    return error'''

portName='/dev/ttyUSB0'
baudrateValue = 80000
print("Number of Errors in Loop Back Counter Test : ", LoopBackCounterTest(portName, baudrateValue))
print("Number of Errors in Loop Back Random Test : ", LoopBackRandomTest(portName, baudrateValue))
