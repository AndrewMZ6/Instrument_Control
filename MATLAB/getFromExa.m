function [exadata1] = getFromExa(connectionID, samp_rate, points_num, cent_freq, timeout)

% function [exadata1] = getFromExa(connectionID, samp_rate, points_num, cent_freq, timeout)
%
% Обязательные параметры:
% connectionID - идентификатор соединения с инстументом
% 
% samp_rate - частота дискретизации. По умолчанию 20 MHz
% points_num - количество снимаемых комплексных отсчетов, по умолчанию 100 000
% cent_freq - центральная частота (частота несущей). По умолчанию 500 MHz
%
% Опциональные параметры:
% timeout - время ожидания снятия точек. Если время ожидания меньше времени
% съема, то не все точки будут сняты. По умолчанию 60 сек.
%
% exadata1 - полученные от анализатора комплексные отсчёты

% Установка значений по умолчанию
if (nargin < 5) timeout = 60; end
if (nargin < 4) cent_freq = 500e6; end
if (nargin < 3) points_num = 100000; end
if (nargin < 2) samp_rate = 20e6; end
if (nargin < 1)
    error('Необходимо указать connectionID инструмента. Используйте функцию getIntsrID')
end

% Определение TCP или USB соединения
switch (contains(connectionID, '::'))
    case 1
        % Анализатор сигналов EXA N9010B USB visa
        % Этот блок игнорируется если соединение происходит через LAN см. блок "EXA N9010B LAN"
        
        exa = instrfind('Type', 'visa-usb', 'RsrcName', connectionID, 'Tag', '');
        
        % Create the VISA object if it does not exist
        % otherwise use the object that was found.
        if isempty(exa)
            exa = visa('AGILENT',connectionID);
        else
            fclose(exa);
            exa = exa(1);
        end
        
        exa.OutputBufferSize = 50e7;
        exa.InputBufferSize = 50e7;
        exa.timeout = timeout;
        
        fopen(exa);
    case 0
        % Анализатор сигналов EXA N9010B LAN
        % Этот блок игнорируется если соединение происходит через USB см. блок "EXA N9010B USB visa"
        
        % Чтобы посмотреть ip используйте экранную клавиатуру. Win+R -> cmd ->
        % ipconfig/all
        exa = instrfind('Type', 'tcpip', 'RemoteHost', connectionID, 'RemotePort', 5025, 'Tag', '');
        
        % Create the tcpip object if it does not exist
        % otherwise use the object that was found.
        if isempty(exa)
            exa = tcpip(connectionID, 5025);
        else
            fclose(exa);
            exa = exa(1);
        end
        
        exa.OutputBufferSize = 50e7;
        % InputBufferSize - Буфер инструмента
        exa.InputBufferSize = 50e7;
        exa.timeout = timeout;
        
        fopen(exa);
end


fprintf(exa, '*RST;*CLS');

% Настройка режима и конфигурации
fprintf(exa, 'INST:SEL BASIC');
fprintf(exa, 'CONFigure:WAVeform');

% Установка частоты несущей
fprintf(exa, ['FREQ:CENT ', num2str(cent_freq)]);

% Не помню для чего это :(
fprintf(exa, ':INIT:CONT OFF');

% Установка времени съема точек в зависимости от количества точек
acq_time = points_num/samp_rate;
fprintf(exa, [':WAV:SWE:TIME ', num2str(acq_time)]);

% Не помню для чего это :(
fprintf(exa,':INIT:IMM');

% Установка частоты дискретизации
fprintf(exa, [':WAV:SRAT ', num2str(samp_rate)]);

% Установка формата принимаемых данных
fprintf(exa,':FORM:DATA ASCii');

% Запрос на чтение данных. Данные помещаются в буфер инструмента
fprintf(exa,':READ:WAV0?');

% exadata содержит сырые данные с анализатора типа <char>
% '2.306786738E-02,1.153779309E-02,1.795095950E-02,...'
% Забор данных из буфера инструмента
data = fscanf(exa);
% data массив чисел <double>
exadata = str2num(data);

I_exa = exadata(1:2:end);
Q_exa = exadata(2:2:end);
% disp(length(I_exa));
% disp(length(Q_exa));
[~, s_I] = size(I_exa);
[~, s_Q] = size(Q_exa);
if s_I ~= s_Q
    exadata1 = complex(I_exa(1:end - 1), Q_exa);
else
    exadata1 = complex(I_exa, Q_exa);
end

fclose(exa);
