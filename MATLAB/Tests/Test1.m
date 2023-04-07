clc; close all; clearvars;
addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\');
data_to_load = Test_signals.normalized_ofdm;


dg_conn_ID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR';
DG.load_data_visadev(dg_conn_ID, data_to_load);


%% Oscilloscope and MSO file
% clc; close all; clearvars;


osci_conn_ID = 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR';
d = MSO.read_data_normal(osci_conn_ID);
figure; plot(d); grid on;
figure; plot(abs(fft(d)));


d_raw = MSO.read_data_raw(osci_conn_ID, 19000e3);
figure; plot(d_raw); grid on;



figure; plot(abs(fft(d_raw)));