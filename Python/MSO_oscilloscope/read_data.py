import pyvisa
from matplotlib import pyplot as plt
from time import sleep
import sys
import numpy as np

rm = pyvisa.ResourceManager()
T = rm.list_resources()

for index, name in enumerate(T):
    print(index, name)
    

def find_indexes(data: np.ndarray, sign: str, yref: int) -> np.ndarray:
    
    indexes = np.array([], dtype=int)
    
    if sign == '>':
        for index, element in enumerate(data):
            if element > yref:
                indexes = np.append(indexes, index)
    elif sign == '<':
        for index, element in enumerate(data):
            if element < yref:
                indexes = np.append(indexes, index)
    else:
        raise ValueError("Sign must be '>' or '<'")
    
    return indexes
                
                
osci = rm.open_resource(T[1])
print(osci.query("*IDN?"))
print(osci.query("*IDN?"))
print(osci.query("*IDN?"))
print(osci.query("*IDN?"))


osci.timeout = 10000
osci.write(':STOP')

osci.write(':WAV:SOUR CHAN1')
osci.write(':WAV:MODE RAW')

osci.write(':WAV:FORM BYTE')
osci.write(':WAV:POINts 160000')


pre = list(map(lambda x: float(x), osci.query(':WAV:PRE?').split(',')))

data = osci.query_binary_values(':WAV:DATA?', datatype='B', container=np.ndarray)

err = osci.query(':SYST:ERR?')
osci.close()
data = np.array(data, dtype=int)




yincrement = pre[7]
yref = int(pre[9])
xincrement = pre[4]


revived_sig = np.zeros(len(data), dtype=float)
ypositive_indexes = find_indexes(data, '>', yref)
ynegative_indexes = find_indexes(data, '<', yref)

positive_data = (data[ypositive_indexes] - yref)*yincrement
negative_data = (data[ynegative_indexes] - yref)*yincrement

revived_sig[ypositive_indexes] = positive_data
revived_sig[ynegative_indexes] = negative_data


fs = 25e6
fc = 5e6
interpolated_size = 1024*20
freqline = np.arange(0, fs - 1, fs/interpolated_size)
t = np.arange(0, len(revived_sig)*(1/fs), 1/fs)
        
Q_carr = -np.sin(2*np.pi*fc*t)
I_carr = np.cos(2*np.pi*fc*t)

real_part = np.multiply(revived_sig, I_carr)
imag_part = np.multiply(revived_sig, Q_carr)


plt.plot(np.abs(np.fft.fft(real_part)))
plt.grid()
