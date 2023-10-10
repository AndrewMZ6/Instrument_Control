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
    yincrement = pre['yincrement']['value']
    
    # yref is the middle line of the oscillogramm
    yref = int(pre['yreference']['value'])
    
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
    
def process_preambula(preambula:list) -> dict:
    
    preambula_struct = {}
    
    preambula_struct['format'] = {'value': preambula[0]}
    preambula_struct['format'].update({'description':r'<format>: indicates 0 (BYTE), 1 (WORD), or 2 (ASC).'})
    
    
    preambula_struct['type'] = {'value': preambula[1]}
    preambula_struct['type'].update({'description':r'<type>: indicates 0 (NORMal), 1 (MAXimum), or 2 (RAW).'})
    

    preambula_struct['points'] = {'value': preambula[2]}
    preambula_struct['points'].update({'description':r'<points>: After the memory depth option is installed, <points> is an integer ranging from 1 to 200,000,000.'})
    
    
    preambula_struct['count'] = {'value': preambula[3]}
    preambula_struct['count'].update({'description':r'<count>: indicates the number of averages in the average sample mode. The value of <count> parameter is 1 in other modes.'})
    
    
    preambula_struct['xincrement'] = {'value': preambula[4]}
    preambula_struct['xincrement'].update({'description':r'<xincrement>: indicates the time difference between two neighboring points in the X direction.'})
    
    
    preambula_struct['xorigin'] = {'value': preambula[5]}
    preambula_struct['xorigin'].update({'description':r'<xorigin>: indicates the start time of the waveform data in the X direction.'})
    
    
    preambula_struct['xreference'] = {'value': preambula[6]}
    preambula_struct['xreference'].update({'description':r'<xreference>: indicates the reference time of the waveform data in the X direction.'})
    
    
    preambula_struct['yincrement'] = {'value': preambula[7]}
    preambula_struct['yincrement'].update({'description':r'<yincrement>: indicates the step value of the waveforms in the Y direction.'})

    
    preambula_struct['yorigin'] = {'value': preambula[8]}
    preambula_struct['yorigin'].update({'description':r'<yorigin>: indicates the vertical offset relative to the "Vertical Reference Position" in the Y direction.'})
    

    preambula_struct['yreference'] = {'value': preambula[9]}
    preambula_struct['yreference'].update({'description':r'<yreference>: indicates the vertical reference position in the Y direction.'})
    
    return preambula_struct
    
    

# the main function to read data from oscilloscope
def read_data(connID:str, setup_function, points=None, ch_Num=1) -> np.ndarray:
    
    '''
        Returns tuple(acquired data, preambula)
    '''

    rm = pyvisa.ResourceManager()
    osci = rm.open_resource(connID)
    

    osci.timeout = 10_000
    
    instr_name = osci.query('*IDN?')
    print(f'mso -> connected to {instr_name}')
    
    read_success_flag = 0
    
    while not read_success_flag:

        try:
            osci.write(':STOP')
            osci.write(f':WAV:SOUR CHAN{ch_Num}')
            
            if points:
                osci = setup_function(osci, points)
            else:
                osci = setup_function(osci)
            
        
            osci.write(':WAV:FORM BYTE')
            
            pre = list(map(lambda x: float(x), osci.query(':WAV:PRE?').split(',')))
        
               
            data = osci.query_binary_values(':WAV:DATA?', datatype='B', container=np.ndarray)
            
            
            err = osci.query(':SYST:ERR?')
            osci.write(':RUN')
            
            assert data.size == pre[2], 'Length do not match!'
            
            osci.close()
            read_success_flag = 1
            print('mso -> data been read successfully')
        except Exception as erro:
            print(f'mso -> EXCEPTION: {erro}')
            read_success_flag = 0
            
    
    osci.close()
    print('mso -> connection closed')
    print(f'mso -> errors: {err}')
    
    preamb = process_preambula(pre)
    revived_sig = process_data(data, preamb)
    
    
    
    
    return revived_sig, preamb



# decorators for three modes. Each uses different "setup_function".
# setup_functions 
def normal_mode(read_data):
    setup_function = setup_normal
    def wrapper(connID, chan_Num):
        revived_sig = read_data(connID, setup_function, ch_Num=chan_Num)
        return revived_sig
        
    return wrapper


def raw_mode(points):
    setup_function = setup_raw
    def outer_wrapper(read_data):
        
        def wrapper(connID, chan_Num):
            revived_sig = read_data(connID, setup_function, points, ch_Num=chan_Num)
            return revived_sig
            
            
        return wrapper
    return outer_wrapper


def max_mode(read_data):
    setup_function = setup_max
    def wrapper(connID, chan_Num):
        revived_sig = read_data(connID, setup_function, ch_Num=chan_Num)
        return revived_sig
        
        
    return wrapper


# api for outer usage. These functions will me called by user
# internally all these functions use function "read_data" defined earlier
# but with different decorators (also defined earlier)
def read_data_normal(connID:str, channel_Num=1) -> np.ndarray:
    local_read_data_normal = normal_mode(read_data)
    revived_sig = local_read_data_normal(connID, channel_Num)
    return revived_sig


def read_data_raw(connID:str, pts, channel_Num=1) -> np.ndarray:
    local_read_data_raw = raw_mode(pts)(read_data)
    revived_sig = local_read_data_raw(connID, channel_Num)
    return revived_sig


def read_data_max(connID:str, channel_Num=1) -> np.ndarray:
    local_read_data_max = max_mode(read_data)
    revived_sig = local_read_data_max(connID, channel_Num)
    return revived_sig


