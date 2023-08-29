classdef DSOX
    %DSOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1;
    end
    
    methods (Static)
        function instr_obj = visadev_connect(connectionID)
            instr_obj = visadev(connectionID);
        end

        function rms = get_rms(connectionID, chNum)
            instr_obj = DSOX.visadev_connect(connectionID);            
            command = [':MEASure:VRMS? DISPlay,AC,CHANnel', num2str(chNum)];
            rms = writeread(instr_obj, command);
            errors = writeread(instr_obj, 'SYS:ERR?');
            disp(['get_rms errors -> ', errors]);
        end

        function rms = get_voltage_DC(connectionID, chNum)
            instr_obj = DSOX.visadev_connect(connectionID);            
            command = [':MEASure:VAVerage? DISPlay,CHANnel', num2str(chNum)];
            rms = writeread(instr_obj, command);
            rms = str2num(rms);
        end

        function delay = get_delay(connectionID)
            instr_obj = DSOX.visadev_connect(connectionID);
            command = ':MEASure:DELay? CHANnel1,CHANnel2';
            delay = writeread(instr_obj, command);
            errors = writeread(instr_obj, 'SYS:ERR?');
            disp(['get_delay errors -> ', errors]);
        end

        function phase = get_phase(connectionID)
            instr_obj = DSOX.visadev_connect(connectionID);
            command = ':MEASure:PHASe? CHANnel1,CHANnel2';
            phase = writeread(instr_obj, command);
        end


        function set_razvertka(connectionID, tb)
            instr_obj = DSOX.visadev_connect(connectionID);            
            command = [':TIMebase:RANGe ', num2str(tb)];
            write(instr_obj, command);
            errors = writeread(instr_obj, 'SYS:ERR?');
            disp(['set_razvertka errors -> ', errors]);
        end

        function vmax = get_vmax(connID, chNum)
            if strcmpi(connID, 'default')
                connID = 'USB0::0x0957::0x179B::MY52447296::0::INSTR';
            end
           
            OSCI_Obj = instrfind('Type', 'visa-usb', 'RsrcName', connID, 'Tag', '');
            
            if isempty(OSCI_Obj)
                OSCI_Obj = visa('Agilent', connID);
            else 
                fclose(OSCI_Obj);
                OSCI_Obj = OSCI_Obj(1);
            end
        
            % Открыть соединение с инструментом
            fopen(OSCI_Obj);
        
            % Запросить RANGe
            command = [':MEASure:VMAX? CHANnel', num2str(chNum)];
            vmax = str2num(query(OSCI_Obj, command)); 
            
            % прочитать строку ошибок
            request = ':SYSTEM:ERR?';
            instrumentError = query(OSCI_Obj, request);
            disp(instrumentError);
            
            % Закрыть соединение с инструментом
            fclose(OSCI_Obj);
        end

        function range = get_screen_range(connID, chNum)
            if strcmpi(connID, 'default')
                connID = 'USB0::0x0957::0x179B::MY52447296::0::INSTR';
            end
           
            OSCI_Obj = instrfind('Type', 'visa-usb', 'RsrcName', connID, 'Tag', '');
            
            if isempty(OSCI_Obj)
                OSCI_Obj = visa('Agilent', connID);
            else 
                fclose(OSCI_Obj);
                OSCI_Obj = OSCI_Obj(1);
            end
        
            % Открыть соединение с инструментом
            fopen(OSCI_Obj);
        
            % Запросить RANGe
            command = [':CHANnel', num2str(chNum), ':RANGe?'];
            range = str2num(query(OSCI_Obj, command));
            
            % прочитать строку ошибок
            request = ':SYSTEM:ERR?';
            instrumentError = query(OSCI_Obj,request);
            disp(instrumentError);
            
            % Закрыть соединение с инструментом
            fclose(OSCI_Obj);
        end
        
        function set_screen_range(connID, chNum, voltage)
            if strcmpi(connID, 'default')
                connID = 'USB0::0x0957::0x179B::MY52447296::0::INSTR';
            end
           
            OSCI_Obj = instrfind('Type', 'visa-usb', 'RsrcName', connID, 'Tag', '');
            
            if isempty(OSCI_Obj)
                OSCI_Obj = visa('Agilent', connID);
            else 
                fclose(OSCI_Obj);
                OSCI_Obj = OSCI_Obj(1);
            end
        
            % Открыть соединение с инструментом
            fopen(OSCI_Obj);
        
            % Запросить RANGe
            command = [':CHANnel', num2str(chNum), ':RANGe ', num2str(voltage)];
            fwrite(OSCI_Obj, command); 
            
            % прочитать строку ошибок
            instrumentError = query(OSCI_Obj,':SYSTEM:ERR?');
            disp(instrumentError);
            
            % Закрыть соединение с инструментом
            fclose(OSCI_Obj);
        end

        function RECIEVED_FROM_OSCI = read_data(connectionID)

            % Осциллограф DSOX1102G USB visa (LAN соединение отсутствует)
            % Идентификатор (4 аргумент) берется из Keysight Connection Expert
            OSCI_Obj = instrfind('Type', 'visa-usb', 'RsrcName', connectionID, 'Tag', '');

            % Create the VISA-USB object if it does not exist
            % otherwise use the object that was found.
            if isempty(OSCI_Obj)
                OSCI_Obj = visa('Agilent', connectionID);
            else 
                fclose(OSCI_Obj);
                OSCI_Obj = OSCI_Obj(1);
            end

            % Установка размера буфера
            OSCI_Obj.InputBufferSize = 1000000;
            % Установка времени ожидания
            OSCI_Obj.Timeout = 10;
            % Установка порядка следования байт
            OSCI_Obj.ByteOrder = 'littleEndian';
            % Открыть соединение с инструментом
            fopen(OSCI_Obj);

            % Сбросить настройки, включить авто-скалирование и остановить прибор
            % fprintf(OSCI_Obj,'*RST; :AUTOSCALE'); 
            fprintf(OSCI_Obj,':STOP');
            % Источник данных - канал 1
            fprintf(OSCI_Obj,':WAVEFORM:SOURCE CHAN1'); 
            % Set timebase to main
            fprintf(OSCI_Obj,':TIMEBASE:MODE MAIN');
            % Set up acquisition type and count. 
            fprintf(OSCI_Obj,':ACQUIRE:TYPE NORMAL');
            fprintf(OSCI_Obj,':ACQUIRE:COUNT 1');
            % Specify 5000 points at a time by :WAV:DATA?
            fprintf(OSCI_Obj,':WAV:POINTS:MODE RAW');
            fprintf(OSCI_Obj,':WAV:POINTS 50000');
            % Now tell the instrument to digitize channel1
            fprintf(OSCI_Obj,':DIGITIZE CHAN1');
            % Wait till complete
            operationComplete = str2double(query(OSCI_Obj,'*OPC?'));
            while ~operationComplete
                operationComplete = str2double(query(OSCI_Obj,'*OPC?'));
            end
            % Get the data back as a WORD (i.e., INT16), other options are ASCII and BYTE
            fprintf(OSCI_Obj,':WAVEFORM:FORMAT WORD');

            % Set the byte order on the instrument as well
            fprintf(OSCI_Obj,':WAVEFORM:BYTEORDER LSBFirst');

            % Get the preamble block
            preambleBlock = query(OSCI_Obj,':WAVEFORM:PREAMBLE?');
            % The preamble block contains all of the current WAVEFORM settings.  
            % It is returned in the form <preamble_block><NL> where <preamble_block> is:
            %    FORMAT        : int16 - 0 = BYTE, 1 = WORD, 2 = ASCII.
            %    TYPE          : int16 - 0 = NORMAL, 1 = PEAK DETECT, 2 = AVERAGE
            %    POINTS        : int32 - number of data points transferred.
            %    COUNT         : int32 - 1 and is always 1.
            %    XINCREMENT    : float64 - time difference between data points.
            %    XORIGIN       : float64 - always the first data point in memory.
            %    XREFERENCE    : int32 - specifies the data point associated with
            %                            x-origin.
            %    YINCREMENT    : float32 - voltage diff between data points.
            %    YORIGIN       : float32 - value is the voltage at center screen.
            %    YREFERENCE    : int32 - specifies the data point where y-origin
            %                            occurs.

            % Now send commmand to read data
            fprintf(OSCI_Obj,':WAV:DATA?');

            % read back the BINBLOCK with the data in specified format and store it in
            % the waveform structure. FREAD removes the extra terminator in the buffer
            waveform.RawData = binblockread(OSCI_Obj,'uint16'); fread(OSCI_Obj,1);

            % Read back the error queue on the instrument
            instrumentError = query(OSCI_Obj,':SYSTEM:ERR?');

            while ~isequal(instrumentError,['+0,"No error"' char(10)])
                disp(['Instrument Error: ' instrumentError]);
                instrumentError = query(OSCI_Obj,':SYSTEM:ERR?');
            end

            % Массив с полученными данными
            RECIEVED_FROM_OSCI = waveform.RawData;

            % Закрыть соединение с инструментом
            fclose(OSCI_Obj);

        end
    end
end

