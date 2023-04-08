import sys
from pathlib import Path
from matplotlib import pyplot as plt 
from time import sleep



# Path shenanigans
parent = Path(__file__).parents[1]

ts_path = Path(parent, 'Test_signals')
dg_path = Path(parent, 'DG_waveform_generator')
mso_path = Path(parent, 'MSO_oscilloscope')

    
for path in [ts_path, dg_path, mso_path]:
    sys.path.append('/'.join(list(map(lambda x: x.capitalize(), path.absolute().as_posix().split('/')))))
    

import DG5000 as dg
import MSO5000 as mso
from Test_signals import Test_signals as ts


# creating signal to load to waveform generator
sig, f = ts.normalized_ofdm()
sin = ts.normalized_two_sins()


# set connection IDs
dg_connID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR'
mso_connID = 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR'


# loading data
dg.load_data(dg_connID, sin)


# getting data from oscilloscope
data_normal = mso.read_data_normal(mso_connID)
data_raw = mso.read_data_raw(mso_connID, 500e3)
data_max = mso.read_data_max(mso_connID)



# plotting acquired data
fig1, ax1 = plt.subplots()
fig2, ax2 = plt.subplots()
fig3, ax3 = plt.subplots()

ax1.plot(data_normal)
ax1.grid()
ax1.set_title('Normal')

ax2.plot(data_raw)
ax2.grid()
ax2.set_title('Raw')


ax3.plot(data_max)
ax3.grid()
ax3.set_title('Max')

