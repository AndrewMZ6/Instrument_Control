%% R&S (В разработке)
close all;

% Кнопка Setup -> General Setup -> Network address -> IP address
% Собственный ip адресс инструмента 169.254.21.200
% Find a tcpip object.
RS = instrfind('Type', 'tcpip', 'RemoteHost', '192.168.0.78', 'RemotePort', 5025, 'Tag', '');

% Create the tcpip object if it does not exist
% otherwise use the object that was found.
if isempty(RS)
    RS = tcpip('192.168.0.78', 5025);
else
    fclose(RS);
    RS = RS(1);
end

% Установка буфера и времени ожидания
RS.OutputBufferSize = 1e7;
RS.InputBufferSize = 1e7;
RS.timeout = 8;

% Параметры измерения
% Частота дискретизации должна быть ровно в 2 раза больше полосы
% измеряемого сигнала
fsampling = 40e6; % Полоса (BWIDth) устанавливается инструментом автоматически в зависимости от fsampling
fcentral = 500e6;
NumOfPoints = 50e3;

% Открыть соединение с инструментом
fopen(RS);

% Сброс и очистка регистра статуса
fprintf(RS, '*RST;*CLS');

% Запрос имени инструмента
data1 = query(RS, '*IDN?');
disp(['Инструмент: ', data1]);

% Установка нужного режима
fprintf(RS, 'INSTrument IQ');
% IQ, SANalyzer

% Получение информации о режиме работы 
mode = query(RS, 'INSTrument?');
disp(['Режим: ', mode]);

% fprintf(RS, 'INPut:DIQ:SRATe 20e6');
insrate = query(RS, 'INPut:DIQ:SRATe?');
disp(['Входная частота = ', insrate]);

% Установка центральной частоты
fprintf(RS, ['FREQ:CENT ', num2str(fcentral)]);

% Одиночное измерение
fprintf(RS, 'INITiate:CONTinuous OFF');

% Установка частоты дискретизации
fprintf(RS, ['TRACe:IQ:SRATe ', num2str(fsampling)]);
sam = query(RS, 'TRACe:IQ:SRATe?');
disp(['Частота дискретизации = ', sam]);

% Установка количества точек измерения (Record Length)
% В приложении IQWizard это поле "Count"
% Количество снимаемых точек зависит от времени измерения, устанавливать можно только что-то одно
% Если нужно установить время: fprintf(RS, 'SENS:SWE:TIME 1ms');
% fprintf(RS, 'SENS:SWE:TIME 1ms');
fprintf(RS, ['TRACe:IQ:RLENgth ' , num2str(NumOfPoints)]);
rlen = query(RS, 'TRACe:IQ:RLENgth?');
disp(['Количество точек = ', rlen]);

% Количество свипов
fprintf(RS, 'SWE:COUN 1');
% fprintf(RS, 'INIT;*WAI');

% Запрос ширины полосы измерения
% Ширина полосы зависит от частоты дискретизации
BandWidth = query(RS, 'TRACe:IQ:BWIDth?');
disp(['Ширина полосы = ', BandWidth]);

% Позволить изменениям отображаться на экране
% в противном случае экран потемнеет и выведется надпись "REMOTE MODE"
fprintf(RS, 'SYST:DISP:UPD ON');
fprintf(RS, 'INIT; *WAI');

try
    data4 = query(RS, 'TRACe:IQ:DATA?'); 

    numdata4 = str2num(data4);

    Inum = numdata4(1:2:end);
    Qnum = numdata4(2:2:end);

    compl = complex(Inum, Qnum);

    spec = fft(compl);

    figure;
    plot(abs(fftshift(spec)));
    title(['Количество комплексных векторов = ', num2str(length(compl))]);
    figure;
    plot(abs(compl));
    title('compl');

    scatterplot(spec);title('spec');
    scatterplot(compl);title('compl');
catch me
    disp(['Catched message: ', me.message]);
end

err = query(RS, ':SYST:ERR?');
disp(['Ошибка: ',err]);
% meme = fscanf(RS);
% return
fprintf(RS, 'INITiate:CONTinuous ON');
% fclose(RS);

%% Корреляция
close all;

% sig_time = ifft(spec_zeros);          -|_ 000000000 _|-|  10240
% pil_time = ifft(pilot_zeros);         -|_ 000000000 _|-|  10240
% ref2_time = [pil_time, sig_time];

corrr3 = xcorr(pil_time, compl);
figure;
plot(abs(corrr3));title('pil time');

corrr4 = xcorr(sig_time, compl);
figure;
plot(abs(corrr4));title('sig time');

corrr2 = xcorr(ref2_time, compl);
figure;
plot(abs(corrr2));title('ref2 time');

% spec_time = ifft(spectrum_shifted);       -|_ _|-|    1024
% spec_time_pilot = ifft(pilot_shifted);    -|_ _|-|    1024
% ref1_time = [spec_time_pilot, spec_time];

corrr6 = xcorr(spec_time_pilot, compl);
figure;
plot(abs(corrr6));title('spec time pilot');

corrr5 = xcorr(spec_time, compl);
figure;
plot(abs(corrr5));title('spec time');

[corrr7, lag7] = xcorr(ref1_time, compl);
figure;
plot(abs(corrr7));title('ref1 time');

[~, pos4] = max(abs(corrr7));
t = lag7(pos4);

cut = compl(abs(t):abs(t) + length(ref1_time));
cut_spec = fft(cut);
scatterplot(cut_spec);title('cut spec');
figure;
plot(abs(fftshift(cut_spec)));title('cut spec shifted');

fclose(RS);
