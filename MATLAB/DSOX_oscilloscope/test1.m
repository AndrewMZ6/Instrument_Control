clearvars; close all; clc;
connID = 'USB0::0x0957::0x179B::MY52447296::0::INSTR';
[data, pre_struct] = DSOX.read_data(connID, 1);
ma = max(data)
mi = min(data)

figure; plot(data)