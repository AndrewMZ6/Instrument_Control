%% Load data to generator 

clc; close all; clearvars;
addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\', '..\TF_waveform_generator');

% signal = Test_signals.normalized_sin();
signal = Test_signals.normalized_ofdm();

figure;
    plot(signal.freqline, abs(fft(signal.data)));
    grid on;
    title('Generated signal');



dg_conn_ID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR';
data_to_load = signal.data;


% load data
amp = .7;
DG.load_data(dg_conn_ID, data_to_load, signal.Fs, amp);



%% Oscilloscope and MSO file
clc; close all; 
% clearvars;
osci_conn_ID = 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR';

channel_num = 2;


% read data in raw mode. The mode allows max of internal instrument memory depth points to load
[~] = MSO.read_data_raw(osci_conn_ID, channel_num, 100e3);
[d_max, p_max] = MSO.read_data_max(osci_conn_ID, channel_num);

s = Test_signals.process_ofdm(d_max, signal.data, signal.modulation_order);

scatterplot(s.modulated_data);
    grid on;

[er, errate] = biterr(signal.bits, s.bits);
er 
errate
