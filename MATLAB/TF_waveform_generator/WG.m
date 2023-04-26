classdef WG
    % methods:
    %   WG.channel_amp(connectionID, chNum, amp)
    %   sets the amplitude value of the Trueform 33600A generator
    %
    %   WG.load_data(connectionID, data, chNum, fs, ArbFileName)
    %   upload data to generator and send it to chosen channel. Set sample
    %   frequency
    
    properties
        Property1
    end
    
    methods (Static)
        function instr_obj = visadev_connect(connectionID)
            instr_obj = visadev(connectionID);
        end

        function set_freq(connectionID, freq)
            instr_obj = WG.visadev_connect(connectionID);
            chNum = 1;
            command = [':SOURce', num2str(chNum), ':FREQuency ', num2str(freq)];
            write(instr_obj, command);
        end

        function channel_amp(connectionID, chNum, amp)
            
            % Функция отвечающая за установку амплитуды канала 1 и 2 на генераторе
            % WaveformGenerator 33500B
            %
            % channelAmp(connectionID, chNum, amp)
            % 
            % chNum - номер канала, 1 или 2
            % amp - зачение амплитуды в Вольтах/МиллиВольтах
            % connectionID - идентификатор соединения с инструментом
            
            if strcmpi(connectionID, 'default')
                connectionID = 'USB0::0x0957::0x4B07::MY53401534::0::INSTR';
            end
            
            WG_Obj = instrfind('Type', 'visa-usb', 'RsrcName', connectionID, 'Tag', '');
            
            % Create the VISA-USB object if it does not exist
            % otherwise use the object that was found.
            if isempty(WG_Obj)
                WG_Obj = visa('Agilent', connectionID);
            else 
                fclose(WG_Obj);
                WG_Obj = WG_Obj(1);
            end
            
            % Открыть соединение с инструментом
            fopen(WG_Obj);
            
            write(WG_Obj, ['SOURCE', num2str(chNum), ':VOLT ', num2str(amp)]);
            
            fclose(WG_Obj);
            
        end
        function load_data(connectionID, data, chNum, fs, ArbFileName)
            %SENDTOWG отправить данные на генератор Waveform Generator 33500B
            %
            %   WG.load_data(connectionID, data, chNum, fs, ArbFileName)
            
            if (nargin< 5) ArbFileName = 'Untitled'; end
            if (nargin< 4) fs = 50e6; end
            if (nargin< 3)
                error('Нужно передать как минимум два аргумента');
            end
            
            if strcmpi(connectionID, 'default')
                connectionID = 'USB0::0x0957::0x4B07::MY53401534::0::INSTR';
            end
            
            switch parseID(connectionID)
                case 1
                    % Waveform Generator 33500B USB visa 
                    % Этот блок игнорируется если соединение происходит через LAN см. блок "Waveform Generator 33500B LAN"
                    % Идентификатор (4 аргумент) берется из Keysight Connection Expert
                    
                    % С новым синтаксисом VISA эта штука только мешает
                    %WG_obj = instrfind('Type', 'visa-usb', 'RsrcName', connectionID, 'Tag', '');
                    
                    
                    WG_obj = visadev(connectionID);
                    
                    
                    % Подстчет производится из расчёта 8 бит на 1 точку
                    %obj_buffer = 10e6*8;
                    %set (WG_obj,'OutputBufferSize',(obj_buffer+125));
                    % Время ожидания запроса
                    WG_obj.Timeout = 10;
                    
                    
%                     % Установка соедининения
%                     try
%                        fopen(WG_obj);
%                     catch exception %problem occurred throw error message
%                         uiwait(msgbox('Error occurred trying to connect to the 33522, verify correct IP address','Error Message','error'));
%                         rethrow(exception);
%                     end
                case 0
                    % Waveform Generator 33500B LAN 
                    % Этот блок игнорируется если соединение происходит через USB см. блок "Waveform Generator 33500B USB visa"
                    % Чтобы посмотреть ip генератора - кнопка System -> I/O config -> LAN
                    % settings
                    WG_obj = instrfind('Type', 'tcpip', 'RemoteHost', connectionID, 'RemotePort', 5025, 'Tag', '');
                    
                    % Сценарий соединения с инструментом взят из tmtool
                    % Create the tcpip object if it does not exist
                    % otherwise use the object that was found.
                    if isempty(WG_obj)
                        WG_obj = tcpip(connectionID, 5025);
                    else
                        fclose(WG_obj);
                        WG_obj = WG_obj(1);
                    end
                    
                    % Подстчет производится из расчёта 8 бит на 1 точку
                    obj_buffer = 10e6*8;
                    set (WG_obj,'OutputBufferSize',(obj_buffer+125));
                    % Время ожидания запроса
                    WG_obj.Timeout = 10;
                    
                    % Установка соедининения
                    try
                       fopen(WG_obj);
                    catch exception %problem occurred throw error message
                        uiwait(msgbox('Error occurred trying to connect to the 33522, verify correct IP address','Error Message','error'));
                        rethrow(exception);
                    end
                otherwise
                    error('Не удалось подключиться к инструменту :(')
            end
            
            % Отправка данных на генератор 33500B(этот блок общий как для LAN так и для USB и запускается после соединения с инструментом)
            % Запрос имени инструмента
            
            idn = writeread(WG_obj, '*IDN?');
            write(WG_obj, '*CLS');
            idn = convertStringsToChars(idn);
            fprintf(idn)
            fprintf('\n\n')

            write(WG_obj, ['OUTPUT', num2str(chNum), ' OFF']);
            
            % Название вашего массива в инстументе
            name = ArbFileName;
            % Задание частоты дискретизации
            sRate = fs;
            % Задание величины амлитуды
            amp = 0.1;
            
            % ловушка ошибок
            
            errorstr = writeread(WG_obj, 'SYST:ERR?');
            errorstr = convertStringsToChars(errorstr);
            disp(errorstr);
            
            % Создания полосы загрузки
            mes = ['Connected to ' idn ' sending waveforms.....'];
            h = waitbar(0,mes);
            
            % Сбросить настройки инструмента
            % write (WG_obj, '*RST');
            
            % Убеждаемся, что массив представлен в виде строки, а не столбцов
            if isrow(data) == 0
                data = data';
            end
            
            % Включить или выключить встроенный фильтр на генераторе
            ON_OFF_FILTER_CH1 = ['SOURce', num2str(chNum),  ':FUNCtion:ARBitrary:FILTer ', 'OFF'];
            write(WG_obj, ON_OFF_FILTER_CH1); 
            
            % Обновляем окно загрузки
            waitbar(.1,h,mes);
            
            % Очистка временной памяти
            write(WG_obj, ['SOURce', num2str(chNum),  ':DATA:VOLatile:CLEar']); 
            
            % ловушка ошибок
            
            errorstr = writeread(WG_obj, 'SYST:ERR?');
            disp(errorstr);
            
            if ischar(data)
                % Обновляем окно загрузки
                waitbar(.8,h,mes);
                
                % Сообщаем, что в канал 2 нужно подать шум
                command = ['SOURce', num2str(chNum), ':FUNCtion NOISe'];
                % Выполнить команду
                write(WG_obj, command); 
                
                % устанавливаем ширину полосы шума
                command = ['SOURce', num2str(chNum), ':FUNCtion:NOISe:BAND 100e3'];
                % Выполнить команду
                write(WG_obj, command);
                
                % Обновить окно загрузки
                waitbar(0.9, h, mes);
                
                % установка размаха шума по амплитуде
                command = ['SOURCE', num2str(chNum), ':VOLT 100e-3'];
                % Выполнить команду
                write(WG_obj, command);
                
                % Включить выход 2 (если выход включен над ним загорается лампочка)
                write(WG_obj, ['OUTPut', num2str(chNum),  ' ON']);
                
                % Заполняем окно загрузки, удаляем его
                waitbar(1, h, mes);
                delete(h);
            else
                % Некоторые версии Matlab требую double
                data = single(data);
            
                % Размещаем данные между 1 и -1
                mx = max(abs(data));
                data = (1*data)/mx;
            
                % Устанавливаем порядок следования байт
                % BORD = Byte ORDer
                write(WG_obj, 'FORM:BORD SWAP');  
                
                % Количество байт
                SENT_TO_WG_Bytes=num2str(length(data) * 4); 
                
                % Создание заголовка для binblock
                header= ['SOURce', num2str(chNum),  ':DATA:ARBitrary ', name, ', #', num2str(length(SENT_TO_WG_Bytes)), SENT_TO_WG_Bytes]; 
                
                % ловушка ошибок
                
                errorstr = writeread(WG_obj, 'SYST:ERR?');
                disp(errorstr);
                
                % Конвертация данных в формат unsigned int8
                binblockBytes = typecast(data, 'uint8');
                
                % Конкатенация заголовка и тела, и запись данных на инструмент
                write(WG_obj, [header binblockBytes], 'uint8');
                
                % Команда инструменту ожидать выполнения предыдущей команды до конца перед
                % продолжением
                write(WG_obj, '*WAI');   
                
                % Обновляем окно загрузки
                waitbar(.8,h,mes);
                
                % Сообщаем, что в канал 1 нужно записать массив с нашим именем name
                command = ['SOURce', num2str(chNum),  ':FUNCtion:ARBitrary ' name];
                % Выполнить команду
                write(WG_obj, command); 
                
                % set current arb waveform to defined arb testrise
                command = ['MMEM:STOR:DATA', num2str(chNum),  ' "INT:\' name '.arb"'];
                % Выполнить команду
                write(WG_obj, command);
                
                % ловушка ошибок
                
                errorstr = writeread(WG_obj, 'SYST:ERR?');
                disp(errorstr);
                
                % Обновить окно загрузки
                waitbar(.9,h,mes);
                
                % Установка частоты дискретизации
                command = ['SOURCE', num2str(chNum), ':FUNCtion:ARB:SRATe ' num2str(sRate)];
                % Выполнить команду
                write(WG_obj, command);
                
                % Включить нашу функцию
                write(WG_obj, ['SOURce', num2str(chNum), ':FUNCtion ARB']); 

                                
                % Установка амплитуды
                command = ['SOURCE', num2str(chNum),  ':VOLT ' num2str(amp)];
                % Выполнить команду
                write(WG_obj, command);
                
                % Установка смещения 
                write(WG_obj, ['SOURCE', num2str(chNum), ':VOLT:OFFSET 0']);
                
                % Включить выход 1 (если выход включен над ним загорается лампочка)
                write(WG_obj, ['OUTPUT', num2str(chNum), ' ON']);
                
                % Сообщить, что загрузка завершена
                fprintf(['SENT_TO_WG waveform downloaded to channel ', num2str(chNum),  '\n\n']);
                
                % Заполняем окно загрузки, удаляем его
                waitbar(1,h,mes);
                delete(h);
            end
            
            % Проверка наличия ошибок
            
            
            
            % Вывод ошибок
            if strncmp (errorstr, '+0,"No error"',13)
               errorcheck = 'Arbitrary waveform generated without any error\n';
               fprintf(errorcheck)
            else
               errorcheck = ['Error reported: ', errorstr];
               errorcheck = convertStringsToChars(errorcheck);
               disp(errorcheck)
            end
            
            % Закрыть соединение с инструментом
            %fclose(WG_obj);
            
            function flag = parseID(id)
                flag = false;
                len = length(id);
                for i = 1:len
                    if id(i) == ':'
                        flag = true;
                    end
                end
            end
            
        end
        function turn_on_noise(connectionID, chNum, amp, bw)
            
            % Функция отвечающая за установку шума на канале 1 или 2
            % WaveformGenerator 33500B
            %
            % genNoise(connectionID, amp, bw, chNum)
            % 
            % chNum - номер канала, 1 или 2
            % amp - зачение амплитуды в Вольтах/МиллиВольтах
            
            % предел полосы для шума от 1 мГц до 20 МГц
            if (nargin< 3) bw = 10e6; end
            if (nargin< 2) amp = 50e-3; end
            if (nargin< 1) connectionID = 'USB0::0x0957::0x4B07::MY53401534::0::INSTR'; end
            
            switch parseID(connectionID)
                case 1
                    % Waveform Generator 33500B USB visa 
                    % Этот блок игнорируется если соединение происходит через LAN см. блок "Waveform Generator 33500B LAN"
                    % Идентификатор (4 аргумент) берется из Keysight Connection Expert
                    WG_obj = instrfind('Type', 'visa-usb', 'RsrcName', connectionID, 'Tag', '');
                    
                    if isempty(WG_obj) % В аргументах visa может применяться новое название 'KEYSIGHT', 
                        % а может и старое 'AGILENT'.
                        WG_obj = visa('Agilent', connectionID);
                    else
                        fclose(WG_obj);
                        WG_obj = WG_obj(1);
                    end
                    
                    % Подстчет производится из расчёта 8 бит на 1 точку
                    obj_buffer = 10e6*8;
                    set (WG_obj,'OutputBufferSize',(obj_buffer+125));
                    % Время ожидания запроса
                    WG_obj.Timeout = 10;
                    
                    % Установка соедининения
                    try
                       fopen(WG_obj);
                    catch exception %problem occurred throw error message
                        uiwait(msgbox('Error occurred trying to connect to the 33522, verify correct IP address','Error Message','error'));
                        rethrow(exception);
                    end
                case 0
                    % Waveform Generator 33500B LAN 
                    % Этот блок игнорируется если соединение происходит через USB см. блок "Waveform Generator 33500B USB visa"
                    % Чтобы посмотреть ip генератора - кнопка System -> I/O config -> LAN
                    % settings
                    WG_obj = instrfind('Type', 'tcpip', 'RemoteHost', connectionID, 'RemotePort', 5025, 'Tag', '');
                    
                    % Сценарий соединения с инструментом взят из tmtool
                    % Create the tcpip object if it does not exist
                    % otherwise use the object that was found.
                    if isempty(WG_obj)
                        WG_obj = tcpip(connectionID, 5025);
                    else
                        fclose(WG_obj);
                        WG_obj = WG_obj(1);
                    end
                    
                    % Подстчет производится из расчёта 8 бит на 1 точку
                    obj_buffer = 10e6*8;
                    set (WG_obj,'OutputBufferSize',(obj_buffer+125));
                    % Время ожидания запроса
                    WG_obj.Timeout = 10;
                    
                    % Установка соедининения
                    try
                       fopen(WG_obj);
                    catch exception %problem occurred throw error message
                        uiwait(msgbox('Error occurred trying to connect to the 33522, verify correct IP address','Error Message','error'));
                        rethrow(exception);
                    end
                otherwise
                    error('Не удалось подключиться к инструменту :(')
            end
            
            % Отправка данных на генератор 33500B(этот блок общий как для LAN так и для USB и запускается после соединения с инструментом)
            % Запрос имени инструмента
            write (WG_obj, '*IDN?');
            idn = fscanf (WG_obj);
            write (idn)
            write ('\n\n')
            
            % Сообщаем, что в канал 2 нужно подать шум
            command = ['SOURce', num2str(chNum),':FUNCtion NOISe'];
            % Выполнить команду
            write(WG_obj,command); 
            
            % устанавливаем ширину полосы шума
            command = ['SOURce', num2str(chNum),':FUNCtion:NOISe:BAND ', num2str(bw)];
            % Выполнить команду
            write(WG_obj,command);
                        
            % установка размаха шума по амплитуде
            command = ['SOURCE', num2str(chNum),':VOLT ' num2str(amp)];
            % Выполнить команду
            write(WG_obj,command);
            
            % Включить выход 2 (если выход включен над ним загорается лампочка)
            command = ['OUTPut', num2str(chNum),' ON'];
            write(WG_obj,command);
            
            % Проверка наличия ошибок
            
            errorstr = writeread(WG_obj, 'SYST:ERR?');
            errorstr = convertStringsToChars(errorstr);
            
            % Вывод ошибок
            if strncmp (errorstr, '+0,"No error"',13)
               errorcheck = 'Шум успешно добавлен \n';
               write (errorcheck)
            else
               errorcheck = ['Error reported: ', errorstr];
               write (errorcheck)
            end
            
            % Закрыть соединение с инструментом
            fclose(WG_obj);
            
            function flag = parseID(id)
                flag = false;
                len = length(id);
                for i = 1:len
                    if id(i) == ':'
                        flag = true;
                    end
                end
            end
        end
    end
end