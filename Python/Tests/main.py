import sys
from Test_signals import Test_signals as ts
from matplotlib import pyplot as plt 
from time import sleep

dg_path = '..\DG_waveform_generator'
mso_path = '..\MSO_oscilloscope'

if dg_path not in sys.path:
    sys.path.append(dg_path)

if mso_path not in sys.path:
    sys.path.append(mso_path)

import DG5000 as dg
import MSO5000 as mso

sig, f = ts.normalized_ofdm()
sin = ts.normalized_two_sins()



dg_connID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR'
mso_connID = 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR'
pointsNum = 500e3



dg.load_data(dg_connID, sin)

data_raw = mso.read_data_raw(mso_connID, pointsNum)



data_normal = mso.read_data_normal(mso_connID)



plt.plot(data_raw)