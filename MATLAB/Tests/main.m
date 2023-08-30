%% Load data to generator 

clc; close all; clearvars;
addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\', '..\TF_waveform_generator');

% signal = Test_signals.normalized_sin();
signal = Test_signals.normalized_ofdm();

figure;
    plot(signal.freqline/1e6, abs(fft(signal.data)));
    grid on;
    title('Спектр тестового OFDM сигнала');
    xlabel('Частота, МГц');


figure;
    plot(signal.data);
    grid on;
    title('Тестовый OFDM сигнал во временной области');
    xlabel('Отсчёты');
    ylabel('Амплитуда');


dg_conn_ID = 'USB0::0x1AB1::0x0640::DG5S245900056::0::INSTR';
data_to_load = signal.data;


% load data
amp = .7;
DG.load_data(dg_conn_ID, data_to_load, signal.Fs, amp);
%% Oscilloscope and MSO file
clc; close all; 
% clearvars;
osci_conn_ID = 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR';

channel_num = 1;
% read data in raw mode. The mode allows max of internal instrument memory depth points to load
oscilloscope_data = MSO.read_data(osci_conn_ID, channel_num, signal.Fs);

figure;
    plot(oscilloscope_data);
    grid on;
    title('Полученные данные с осциллографа');
    xlabel('Отсчёты');
    ylabel('Амплитуда, В');


processed_signal = Test_signals.process_ofdm(oscilloscope_data, signal.data, signal.modulation_order);
scatterplot(processed_signal.modulated_data);
    title('Созвездие принятого OFDM сигнала', 'Color','Black');
    grid on;

[er, errate] = biterr(signal.bits, processed_signal.bits);
er 
errate

% 
% figure;
%     plot(signal.freqline/1e6, abs(fft(processed_signal.cut_rx_signal)));
%     grid on;
%     title('Спектр принятого OFDM сигнала');
%     xlabel('Частота, МГц');

% 
% figure;
%     plot(d_max);
% 
% 
% figure;
%     plot(abs(xcorr(d_max, signal.data)));