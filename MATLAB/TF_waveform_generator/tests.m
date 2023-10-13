close all; clearvars; clc;

endpoint_url = 'https://ofdm-buddy.onrender.com/generate/ofdm/real/';
fftsize = 1024;
modulation_order = 4;
bw = 5e6;
fs = 50e6;
fc = 10e6;

api_url = [endpoint_url, 'fftsize/', num2str(fftsize), '/morder/', num2str(modulation_order), '/bw/', num2str(bw), '/fs/', num2str(fs), '/fc/', num2str(fc)];
response = cellfun(@str2double, jsondecode(webread(api_url)));

figure;
    plot(abs(fft(response)));

connection_ID = 'USB0::0x0957::0x2807::MY57401329::0::INSTR';
data = response;
chNum = 1;
amp = 0.5;
FileName = 'NAMENAME';

mrx = max(abs(data));
data_normalized = data/mrx;
data_scaled = data_normalized/1;

WG.load_data(connection_ID, data_scaled, chNum, fs, amp, FileName);
