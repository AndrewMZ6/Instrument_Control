import pyvisa

def load_data(connID, data):

    data_as_string = ','.join(list(map(lambda r: str(round(r, ndigits=5)), data)))
    message = f':DATA VOLATILE,{data_as_string}'
    
    rm = pyvisa.ResourceManager()
    
            
    gen = rm.open_resource(connID)
    gen.timeout = 10000
    
    instrument_name = gen.query("*IDN?")
    print(f'DG -> connected to {instrument_name}')
    
    gen.write(message)
    gen.write('*WAI')
    gen.write(':DATA:POIN:INT OFF')
    
    
    gen.write(':OUTPut ON')
    err = gen.query('SYST:ERR?')
    
    gen.close()
    print('DG -> connection closed')
    print(f'DG -> errors: {err}')