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
                
                
with rm.open_resource(T[1]) as osci:
    print(osci.query("*IDN?"))


    osci.timeout = 10000
    osci.write(':STOP')

    osci.write(':WAV:SOUR CHAN1')
    osci.write(':WAV:MODE RAW')

    osci.write(':WAV:FORM BYTE')
    osci.write(':WAV:POINts 3000000')


    pre = list(map(lambda x: float(x), osci.query(':WAV:PRE?').split(',')))
    print(f'{pre=}')

    try:

        data = osci.query_binary_values(':WAV:DATA?', datatype='B', container=np.ndarray)
        print(data[:10])

    except e:
        print(e)

    err = osci.query(':SYST:ERR?')
    osci.write(':RUN')
    #osci.close()
    data = np.array(data, dtype=int)
    print(f'{len(data) = }')



plt.plot(data)
plt.grid()
plt.show()