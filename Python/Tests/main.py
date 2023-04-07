import sys

from matplotlib import pyplot as plt 
from time import sleep

ts_path = '..\Test_signals'
dg_path = '..\DG_waveform_generator'
mso_path = '..\MSO_oscilloscope'

if ts_path not in sys.path:
    sys.path.append(ts_path)

if dg_path not in sys.path:
    sys.path.append(dg_path)

if mso_path not in sys.path:
    sys.path.append(mso_path)

import DG5000 as dg
import MSO5000 as mso
from Test_signals import Test_signals as ts

sig, f = ts.normalized_ofdm()
sin = ts.normalized_two_sins()



dg_connID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR'
mso_connID = 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR'
pointsNum = 50e3



dg.load_data(dg_connID, sig)

data_raw = mso.read_data_raw(mso_connID, pointsNum)



data_normal = mso.read_data_normal(mso_connID)


fig1, ax1 = plt.subplots()
fig2, ax2 = plt.subplots()


ax1.plot(data_normal)
ax1.grid()
ax1.set_title('Normal')

ax2.plot(data_raw)
ax2.grid()
ax2.set_title('Raw')