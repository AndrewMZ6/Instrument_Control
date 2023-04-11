import pyvisa
import numpy as np


def process_data(data: np.ndarray, pre: list) -> np.ndarray:
    
    """
        Converts acquired quantum levels to actual voltage levels 
        according to preambula data
        
        Returns voltage values
    """
    
    data = np.array(data, dtype=int)

    # yincrement is the step value of oscilloscope voltage
    yincrement = pre[7]
    
    # yref is the middle line of the oscillogramm
    yref = int(pre[9])
    
    # container for processed data
    revived_sig = np.zeros(len(data), dtype=float)
    
    # find values that are considered positive or negative in 
    # regards to the reference value "yref"
    ypositive_indexes = np.where(data > yref)
    ynegative_indexes = np.where(data < yref)
    
    
    # make relative pos and neg data actualy pos and neg
    positive_data = (data[ypositive_indexes] - yref)*yincrement
    negative_data = (data[ynegative_indexes] - yref)*yincrement
    
    # place the data in container
    revived_sig[ypositive_indexes] = positive_data
    revived_sig[ynegative_indexes] = negative_data
    
    return revived_sig


# utility functions used in main "read_data" function
def setup_normal(osci):
    osci.write(':WAV:MODE NORMal')
    return osci
    
    
def setup_raw(osci, points):
    osci.write(':WAV:MODE RAW')
    osci.write(f':WAV:POINts {points}')
    return osci
    

def setup_max(osci):
    osci.write(':WAV:MODE MAX')
    return osci
    

# the main function to read data from oscilloscope
def read_data(connID:str, setup_function, points=None) -> np.ndarray:

    rm = pyvisa.ResourceManager()
    osci = rm.open_resource(connID)
    
       
    osci.timeout = 40000
    
    instr_name = osci.query('*IDN?')
    print(f'mso -> connected to {instr_name}')
    

    osci.write(':STOP')
    osci.write(':WAV:SOUR CHAN1')
    
    if points:
        osci = setup_function(osci, points)
    else:
        osci = setup_function(osci)
    

    osci.write(':WAV:FORM BYTE')
    
    pre = list(map(lambda x: float(x), osci.query(':WAV:PRE?').split(',')))
    
    
    
    try:
        data = osci.query_binary_values(':WAV:DATA?', datatype='B', container=np.ndarray)
    except pyvisa.VisaIOError:
        err = osci.query(':SYST:ERR?')
        osci.write(':RUN')
        osci.close()
        return "Holla la la mamma mia!"
    
    err = osci.query(':SYST:ERR?')
    osci.write(':RUN')
    osci.close()
    
    
    print('mso -> connection closed')
    print(f'mso -> errors: {err}')
    
    
    revived_sig = process_data(data, pre)
    
    
    return revived_sig



# decorators for three modes. Each uses different "setup_function".
# setup_functions 
def normal_mode(read_data):
    setup_function = setup_normal
    def wrapper(connID):
        revived_sig = read_data(connID, setup_function)
        return revived_sig
        
    return wrapper


def raw_mode(points):
    setup_function = setup_raw
    def outer_wrapper(read_data):
        
        def wrapper(connID):
            revived_sig = read_data(connID, setup_function, points)
            return revived_sig
            
            
        return wrapper
    return outer_wrapper


def max_mode(read_data):
    setup_function = setup_max
    def wrapper(connID):
        revived_sig = read_data(connID, setup_function)
        return revived_sig
        
        
    return wrapper


# api for outer usage. These functions will me called by user
# internally all these functions use function "read_data" defined earlier
# but with different decorators (also defined earlier)
def read_data_raw(connID:str, pts) -> np.ndarray:
    local_read_data_raw = raw_mode(pts)(read_data)
    revived_sig = local_read_data_raw(connID)
    return revived_sig



def read_data_max(connID:str) -> np.ndarray:
    local_read_data_max = max_mode(read_data)
    revived_sig = local_read_data_max(connID)
    return revived_sig


def read_data_normal(connID:str) -> np.ndarray:
    local_read_data_normal = normal_mode(read_data)
    revived_sig = local_read_data_normal(connID)
    return revived_sig