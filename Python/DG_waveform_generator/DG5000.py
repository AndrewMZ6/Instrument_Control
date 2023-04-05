import sys
import pyvisa
import numpy as np
sys.path.append(r'F:\Git\My_repos\Instrument_Control\Python\Test_signals')
import Test_signals

gen_sig = Test_signals.Test_signals.normalized_ofdm
s, f = gen_sig()

def load_data(connID, data):

    data_as_string = ','.join(list(map(lambda r: str(np.round(r, decimals=5)), data)))
    message = f':DATA VOLATILE,{data_as_string}'
    
    rm = pyvisa.ResourceManager()
    
            
    gen = rm.open_resource(connID)
    gen.timeout = 10000
    
    instrument_name = gen.query("*IDN?")
    print(f'DG -> connected to {instrument_name}')
    
    gen.write(message)
    
    
    gen.write(':OUTPut ON')
    err = gen.query('SYST:ERR?')
    
    gen.close()
    print(f'DG -> connection closed')
    print(f'DG -> errors: {err}')