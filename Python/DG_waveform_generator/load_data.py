import sys
import pyvisa
import numpy as np
sys.path.append(r'F:\Git\My_repos\Instrument_Control\Python\Test_signals')
import Test_signals

gen_sins = Test_signals.Test_signals.two_sins

s = gen_sins()
s /= np.max(s)

rm = pyvisa.ResourceManager()
T = rm.list_resources()

for index, name in enumerate(T):
    print(index, name)
    
    
gen = rm.open_resource(T[4])
print(gen.query("*IDN?"))

load_d = ','.join(list(map(lambda r: str(r), s)))

gen.write(f':DATA VOLATILE,{load_d}')
gen.write('*WAI')
gen.write(':DIGI:RATE 20e6')

gen.write(':OUTPut ON')

gen.close()