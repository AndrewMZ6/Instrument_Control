clc; close all; clearvars;
addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\', '..\TF_waveform_generator');

% Create data to load. Currently there are two signals available in
% Test_signals class:
%       normalized_two_sins
%       normalized_ofdm
[data_to_load, freq] = Test_signals.normalized_ofdm;
% data_to_load = Test_signals.normalized_two_sins;

[sins, f] = Test_signals.normalized_two_sins();
figure;
plot(f, abs(fft(sins)));
grid on;


figure;
plot(freq, abs(fft(data_to_load)));
grid on;


dg_conn_ID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR';

% load data
DG.load_data(dg_conn_ID, data_to_load);




%%  Testing function as argument
% clearvars; close all; clc;
% 
% 
% 
% r = Test2(@my_mult, 10, 10);
% 
% 
% 
% 
% function result = my_sum(x, y)
% 
%     result = x + y;
% 
% end
% 
% 
% function result = my_mult(x, y)
% 
%     result = x*y;
% 
% end





%% TF WG test



clc; close all; clearvars;
% data_to_load = Test_signals.normalized_sin;

[sins, f, t] = Test_signals.normalized_sin();

figure;
    plot(sins,'-');
    grid on;


% load data
connectionID = 'USB0::0x0957::0x2807::MY57401328::0::INSTR';
data = sins;
chNum = 1;
fs = 25e6;
ArbFileName = 'LOL';
WG.load_data(connectionID, data, chNum, fs, ArbFileName);

return;
figure;
plot(f, abs(fft(sins)));
grid on;



%% Load data to generator 

clc; close all; clearvars;
addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\', '..\TF_waveform_generator');

% signal = Test_signals.normalized_sin();
signal = Test_signals.normalized_ofdm(1024, 12800, 100, 15e6, 125e6, 128);

figure;
    plot(signal.freqline, abs(fft(signal.data)));
    grid on;
    title('Generated signal');



dg_conn_ID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR';
data_to_load = signal.data;


% load data
DG.load_data(dg_conn_ID, data_to_load);



%% Oscilloscope and MSO file
clc; close all; 
% clearvars;
osci_conn_ID = 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR';

channel_num = 2;


% read data in raw mode. The mode allows max of internal instrument memory depth points to load
[~] = MSO.read_data_raw(osci_conn_ID, channel_num, 100e3);


[d_max, p_max] = MSO.read_data_max(osci_conn_ID, channel_num);



s = Test_signals.process_ofdm(d_max, signal.data, signal.modulation_order);
scatterplot(s.modulated_data)

[er, errate] = biterr(signal.bits, s.bits);
er 
errate

return


fs = 125e6;
Ts = 1/fs;
fc = 15e6;
t = 0:Ts:(length(cut_data1) -1)*Ts;
freqline = 0:fs/length(cut_data1):fs - 1;


Q_carr = -sin(2*pi*fc*t);
I_carr = cos(2*pi*fc*t);

Q_cut_data1 = cut_data1.*Q_carr;
I_cut_data1 = cut_data1.*I_carr;

xx=fft(complex(I_cut_data1,Q_cut_data1));



figure;
    plot(abs((fft(complex(I_cut_data1,Q_cut_data1)))))




restored = [xx(end-511:end), xx(1:512)];
% restored = complex(Q_data, I_data);
central_zero_sample = 513;
cut_restored = [restored(central_zero_sample - 412:central_zero_sample - 1), restored(central_zero_sample + 1:central_zero_sample + 412)];


figure;
    plot(abs((cut_restored)));
    
scatterplot(cut_restored);



rx_bits5 = qamdemod((3*cut_restored./std(cut_restored)).', MORDER, 'OutputType','bit').';
er5 = biterr(rx_bits5,signal.bits)