%% Load data to generator 

clc; close all; clearvars;
addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\', '..\TF_waveform_generator');

% arrs_r = jsondecode(arr.answer.real);
% arrs_i = jsondecode(arr.answer.imag);

% arr = webread('http://192.168.2.93:8089/tOFDM/1800/2');
% arrs_i = cellfun(@str2double, jsondecode(webread('http://192.168.2.93:8088/pOFDM/1024/2/100')));

% p = complex(arrs_r, arrs_i);

% parsed_array = parse_web_array(arr);

arr = [1, 2, 3, 4, 5, 6];
arr2 = 10:-1:5;
arr3 = complex(arr, arr2);
arr4 = 0.1:0.1:0.7;
request_body = jsonencode(struct('boasdad', 'mypaload', 'arr', arr4));
options = weboptions('MediaType', 'application/json');


annn = webwrite('http://192.168.2.93:8088/process_integers', request_body, options);

scatterplot(fft(arrs_i))

figure;
    plot(abs(fftshift(fft(arrs_i))));

return
dg_conn_ID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR';


% load data
amp = .7;
DG.load_data(dg_conn_ID, data_to_load, 25e6, amp);


%% READ BYTES


clc; close all; clearvars;
Fs = 125e6;
% Ts = 1/Fs;
% Npoints = 100e3;
% TBscale = Npoints*Ts;

addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\', '..\TF_waveform_generator');


osci_conn_ID = 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR';
channel_num = 1;


fs = 500e6;
points = 250e3;

[ee, oscilloscope_data] = MSO.read_raw_bytes_fs(osci_conn_ID, channel_num, points, fs);


assert(length(oscilloscope_data.data) == points) 
assert(oscilloscope_data.preambula.points.value == points) 

isize = length(oscilloscope_data.data);
fs_instr = oscilloscope_data.fs_instr;
freqline = 0:fs_instr/isize:fs_instr - 1;

figure;
    plot(ee);


spectrum = abs(fft(oscilloscope_data.data));

figure;
    plot(freqline(2:end)*1e-6, fftshift(spectrum(2:end)));
    xlabel('frequency, MHz');