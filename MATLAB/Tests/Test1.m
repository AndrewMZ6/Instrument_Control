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
signal = Test_signals.normalized_ofdm(1024, 12800, 100, 15e6, 125e6, 16);

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



s = Test_signals.process_ofdm(d_max, signal.data);


er = biterr(signal.bits, s.bits)

return


figure;
    plot(abs(x1_ww))






win = gauss_win;





figure;
        
    plot(abs(x1_ww));
    grid on;
    title('Correlation of dec\_data');














figure;
    plot(signal.freqline, abs(fft(cut_data1)))
    title('prinyaty na nesushei')


figure;
    plot(cut_data1(1:10e3))


x1(max_idx1);




% for i = 1:num_pre-1
%     argumon(i) = sum(channel_chirp_frac_est(i*N-N+1:N*i).*conj(channel_chirp_frac_est(i*N+1:N*i+N)));
% end
%  
% [arg] = -mean(angle(argumon));
% est3 = arg/(2*pi*obj.Ts);
% dphi3 = est3*2*pi/obj.BW; % сдвиг




er1 = biterr(rx_bits1,signal.bits);


disp(['er1 = ', num2str(er1)])


cut_ofdm_1_td = ifft(cut_ofdm_1);


x3 = xcorr(cut_ofdm_1_td, ifft(signal.data.'));

[~, m3] = max(abs(x3));

dphi1 = angle(x3(m3))/824;


for j = 1:824
    lala1_td(j) = cut_ofdm_1_td(j)*exp(1i*(-dphi1*j));
end


lala1 = fft(lala1_td);


figure;
    subplot(2, 2, 1);
        scatter(real(cut_ofdm_1), imag(cut_ofdm_1), 1);
        title('DECIMATED');
        grid on;
    
    subplot(2, 2, 3);
        scatter(real(lala1), imag(lala1), 1);
        title('DECIMATED FC');
        grid on;



rx_bits3 = qamdemod((3*lala1./std(lala1)).', MORDER, 'OutputType','bit').';


er3 = biterr(rx_bits3,signal.bits);


disp(['er3 = ', num2str(er3)])



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