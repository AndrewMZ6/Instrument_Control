clc; close all; clearvars;
addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\');
s = Test_signals.normalized_two_sins;


connectionID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR';
DG.load_data_visadev(connectionID, s);


%% Oscilloscope and MSO file
clc; close all; clearvars;



d = MSO.get_data_normal('USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR');


figure; plot(d); grid on;