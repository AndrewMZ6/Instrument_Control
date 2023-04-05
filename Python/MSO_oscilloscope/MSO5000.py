import pyvisa
from matplotlib import pyplot as plt
from time import sleep
import sys
import numpy as np



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



def read_data_raw(connID:str, pointsNum:int) -> np.ndarray:

    rm = pyvisa.ResourceManager()
    osci = rm.open_resource(connID)
    
       
    osci.timeout = 5000
    
    instr_name = osci.query('*IDN?')
    print(f'mso -> connected to {instr_name}')
    
    
    osci.write(':STOP')
    
    osci.write(':WAV:SOUR CHAN1')
    osci.write(':WAV:MODE RAW')
    
    osci.write(':WAV:FORM BYTE')
    osci.write(f':WAV:POINts {pointsNum}')
    
    
    pre = list(map(lambda x: float(x), osci.query(':WAV:PRE?').split(',')))
    
    data = osci.query_binary_values(':WAV:DATA?', datatype='B', container=np.ndarray)
    
    err = osci.query(':SYST:ERR?')
    osci.write(':RUN')
    osci.close()
    
    
    

    print(f'mso -> connection with {instr_name} closed')
    print(f'mso -> errors: {err}')
    
    
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
    
    return revived_sig




def read_data_normal(connID:str) -> np.ndarray:

    rm = pyvisa.ResourceManager()
    osci = rm.open_resource(connID)
    
       
    osci.timeout = 5000
    
    instr_name = osci.query('*IDN?')
    print(f'mso -> connected to {instr_name}')
    
    
    osci.write(':STOP')
    
    osci.write(':WAV:SOUR CHAN1')
    osci.write(':WAV:MODE NORMal')
    
    osci.write(':WAV:FORM BYTE')
        
    
    pre = list(map(lambda x: float(x), osci.query(':WAV:PRE?').split(',')))
    
    data = osci.query_binary_values(':WAV:DATA?', datatype='B', container=np.ndarray)
    
    err = osci.query(':SYST:ERR?')
    osci.write(':RUN')
    osci.close()
    
    
    print(f'mso -> connection with {instr_name} closed')
    print(f'mso -> errors: {err}')
    
    
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
    
    return revived_sig