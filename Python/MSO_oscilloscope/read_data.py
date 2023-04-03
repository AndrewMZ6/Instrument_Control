import pyvisa
from matplotlib import pyplot as plt
from time import sleep
import sys

rm = pyvisa.ResourceManager()
T = rm.list_resources()

for index, name in enumerate(T):
    print(index, name)
    


osci = rm.open_resource(T[5])
print(osci.query("*IDN?"))
print(osci.query("*IDN?"))
print(osci.query("*IDN?"))
print(osci.query("*IDN?"))


# osci.close()
# sys.exit()

#osci.write(':WAV:SOUR CHAN1');
#osci.write(':WAV:MODE NORM');

osci.write(':WAV:FORM ASCii');


# data9 = osci.query(':WAV:PRE?');
data10 = osci.query(':WAV:DATA?');


# osci.write('*WAI');

# idn_after = osci.query('*IDN?');
# opc = osci.query('*OPC?');

# while not opc:
#     opc = osci.query('*OPC?');

osci.close()

osci.open()
print(osci.query("*IDN?"))
osci.close()

ss = data10[11:]

ss_split = ss.split(',')

qq = map(lambda x: float(x), ss_split[:-1])
qql = list(qq)

plt.plot(qql)
plt.grid()

plt.show()