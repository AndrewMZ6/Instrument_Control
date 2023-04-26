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


%% Oscilloscope and MSO file
% clc; close all; clearvars;
osci_conn_ID = 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR';

channel_num = 3;


% read data in normal mode. The mode allows max of 1000 points to load
[d, p] = MSO.read_data_normal(osci_conn_ID, channel_num);

% read data in raw mode. The mode allows max of internal instrument memory depth points to load
[d_raw, p_raw] = MSO.read_data_raw(osci_conn_ID, channel_num, 100e3);


[d_max, p_max] = MSO.read_data_max(osci_conn_ID, channel_num);


disp(d(1:5));
disp(d_raw(1:5));
disp(d_max(1:5));


figure; 
    plot(d); 
    grid on;
    title('data acquired in normal mode');

figure; 
    plot(d_raw); 
    grid on;
    title('data acquired in raw mode');


figure; 
    plot(d_max); 
    grid on;
    title('data acquired in max mode');

% figure; 
%     plot(abs(fft(d))); 
%     grid on;
%     title('spectrum of normal data');
% 
% figure; 
%     plot(abs(fft(d_raw))); 
%     grid on;
%     title('spectrum of raw data');
% 
% 
% figure; 
%     plot(abs(fft(d_max))); 
%     grid on;
%     title('spectrum of max data');


figure; plot(abs(xcorr(sins, d_raw)));


return 

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
connectionID = 'USB0::0x0957::0x2807::MY57401329::0::INSTR';
data = sins;
chNum = 1;
fs = 31.25e6;
ArbFileName = 'LOL';
WG.load_data(connectionID, data, chNum, fs, ArbFileName)


figure;
plot(f, abs(fft(sins)));
grid on;



%% single sine test

clc; close all; clearvars;


[sins, f] = Test_signals.normalized_sin();
figure;
plot(sins);
grid on;


data = sins/2;
dg_conn_ID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR';


% load data
DG.load_data(dg_conn_ID, data);


s_string = '';

for i = 1:length(data)
    s_string = [s_string, ',', num2str(data(i))];
end

a = fopen("sig2.txt");
fwrite(a, "s_string");
fclose(a);
