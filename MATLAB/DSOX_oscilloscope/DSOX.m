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
        

        function preambula_struct = create_preambula_struct(preambula)
            
            % preambula is acquired in form of csv (comma separated values)
            % so first of all split the values by ','
            split_preambula = split(preambula, ',');
%             split_preambula = preambula;

            % make structure "preambula" where value and description is
            % stored for every field
            preambula_struct.format.value = str2num(split_preambula{1});
            preambula_struct.format.description = '<format>: indicates 0 (BYTE), 1 (WORD), or 2 (ASC).';

            preambula_struct.type.value = str2num(split_preambula{2});
            preambula_struct.type.description = '<type>: indicates 0 (NORMal), 1 (PEAK).';

            preambula_struct.points.value = str2num(split_preambula{3});
            preambula_struct.points.description = '<points>: integer ranging from 1 to 200,000,000.';

            preambula_struct.count.value = str2num(split_preambula{4});
            preambula_struct.count.description = '<count>: indicates the number of averages in the average sample mode. The value of <count> parameter is 1 in other modes.';

            preambula_struct.xincrement.value = str2num(split_preambula{5});
            preambula_struct.xincrement.description = '<xincrement>: indicates the time difference between two neighboring points in the X direction.';

            preambula_struct.xorigin.value = str2num(split_preambula{6});
            preambula_struct.xorigin.description = '<xorigin>: indicates the start time of the waveform data in the X direction.';

            preambula_struct.xreference.value = str2num(split_preambula{7});
            preambula_struct.xreference.description = '<xreference>: indicates the reference time of the waveform data in the X direction.';

            preambula_struct.yincrement.value = str2num(split_preambula{8});
            preambula_struct.yincrement.description = '<yincrement>: indicates the step value of the waveforms in the Y direction.';

            preambula_struct.yorigin.value = str2num(split_preambula{9});
            preambula_struct.yorigin.description = '<yorigin>: indicates the vertical offset relative to the "Vertical Reference Position" in the Y direction.';

            preambula_struct.yreference.value = str2num(split_preambula{10});
            preambula_struct.yreference.description = '<yreference>: indicates the vertical reference position in the Y direction.';


        end



        function [processed_data, preambula_struct] = process_acquired_data(data, preambula)
            preambula_struct = DSOX.create_preambula_struct(preambula);

            if (preambula_struct.points.value ~= length(data))
                error('MSO:processAcquireDataError', ...
                               ['Expected data length according to preambula = ', num2str(preambula_struct.points.value, '%e'), ...
                               '.Actual data length = ', num2str(length(data), '%e')]);
                
            end
            

            yincrement = preambula_struct.yincrement.value;
            yref = preambula_struct.yreference.value;

            % create container for processed data
            processed_data = zeros(1, length(data));

            % find values that are considered positive or negative in
            % regards to reference value "yref"
            ypositive_indexes = find(data >= yref);
            ynegative_indexes = find(data < yref);
            
            % make positive and negative data actual
            positive_data = (data(ypositive_indexes) - yref)*yincrement;
            negative_data = (data(ynegative_indexes) - yref)*yincrement;
            
            % place the data in container
            processed_data(ypositive_indexes) = positive_data;
            processed_data(ynegative_indexes) = negative_data;

        end


        function result = get_command(instr, command)

            iteration_count = 0;
            flag = 0;

            while ~flag
                if iteration_count < 5
                    iteration_count = iteration_count + 1;
%                     disp(['iteration #', num2str(iteration_count)]);

                    try 
                        
        
%                         disp(['executing command > ', command]);
                        result = writeread(instr, command);
                        write(instr, '*WAI');
                        errors = writeread(instr, 'SYST:ERR?');
%                         disp(['get_command error > ', errors]);
                        flag = 1;
    
                    catch err
    
%                         disp(['get_comma CATCH error -> ', err.message]);
                    end

                else

                    disp(['5 ITERATIONS PASSED: ', command, ' failed!']);
                    flag = 1;
                    break;
         
                end

            end

        end


        function do_command(instr, command)

            iteration_count = 0;
            flag = 0;

            while ~flag
                if iteration_count < 5
                    iteration_count = iteration_count + 1;
%                     disp(['iteration #', num2str(iteration_count)]);

                    try 
%                         disp(['executing command > ', command]);
                        write(instr, command);
                        write(instr, '*WAI');
                        errors = writeread(instr, 'SYST:ERR?');
%                         disp(['get_rms errors -> ', errors]);
                        flag = 1;
    
                    catch err
    
%                         disp(['get_rms CATCH error -> ', err.message]);
                    end

                else

                    disp(['5 ITERATIONS PASSED: ', command, ' failed!']);
                    flag = 1;
                    break;
         
                end

            end

        end

        function rms = get_rms(chNum, instr_obj)

                    
            command = [':MEAS:VRMS? DISP,AC,CHAN', num2str(chNum)];
            rms = DSOX.get_command(instr_obj, command);
            
        end

        function rms = get_voltage_DC(connectionID, chNum)
            instr_obj = DSOX.visadev_connect(connectionID);            
            command = [':MEASure:VAVerage? DISPlay,CHANnel', num2str(chNum)];
            rms = writeread(instr_obj, command);
            rms = str2num(rms);
        end

        function delay = get_delay(instr_obj)

            command = ':MEAS:DEL? CHAN1,CHAN2';
            delay = DSOX.get_command(instr_obj, command);
            
        end

        function phase = get_phase(instr)
            
            command = ':MEASure:PHASe? CHANnel1,CHANnel2';
            phase = DSOX.get_command(instr, command);

        end


        function set_razvertka(instr_obj, tb)
            
            command = [':TIM:RANG ', num2str(tb)];
            DSOX.do_command(instr_obj, command);
    
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

        function [processed_data, d] = read_data(connectionID, chNum)

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


            % create counters
            read_success_flag = 0;
            iteration_count = 0;


            % main data acquisition loop
            while ~read_success_flag
                if iteration_count < 5
                    try
                        iteration_count = iteration_count + 1;
                        disp(['iteration #', num2str(iteration_count)]);


                        fprintf(OSCI_Obj,':STOP');
                        fprintf(OSCI_Obj, [':WAVEFORM:SOURCE CHAN', num2str(chNum)]);
                        fprintf(OSCI_Obj,':TIMEBASE:MODE MAIN');
                        fprintf(OSCI_Obj,':ACQUIRE:TYPE NORMAL');
            %             fprintf(OSCI_Obj, [':ACQUIRE:COUNT ', num2str(chNum)]);

                        fprintf(OSCI_Obj,':WAV:POINTS:MODE RAW');
                        fprintf(OSCI_Obj,':WAV:POINTS 50000');
                        % Now tell the instrument to digitize channel1
                        fprintf(OSCI_Obj, [':DIGITIZE CHAN', num2str(chNum)]);
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

            
                        % Now send commmand to read data
                        fprintf(OSCI_Obj,':WAV:DATA?');
            

                        RawData = binblockread(OSCI_Obj,'uint16'); fread(OSCI_Obj,1);
            
                        % Read back the error queue on the instrument
                        instrumentError = query(OSCI_Obj,':SYSTEM:ERR?');
            
                        while ~isequal(instrumentError,['+0,"No error"' char(10)])
                            disp(['Instrument Error: ' instrumentError]);
                            instrumentError = query(OSCI_Obj,':SYSTEM:ERR?');
                        end
            

                        [processed_data, d] = DSOX.process_acquired_data(RawData, preambleBlock);
                        
                        read_success_flag = 1;
                        fprintf(OSCI_Obj,':RUN');

                    catch err

                        disp(['DSOX::read_data ERROR: ', err.message]);
                        fprintf(OSCI_Obj,':RUN');

                    end

                else
                    fprintf(OSCI_Obj,':RUN');    
                    error('DSOX:maximumIterationNumberError', 'Maximum iterations number is exceeded');     
                     
                end


            end

            % Закрыть соединение с инструментом
            fclose(OSCI_Obj);

        end
    end
end

