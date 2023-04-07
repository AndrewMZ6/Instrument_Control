classdef MSO
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
        function instr_object = connect_visadev(connectionID)
            instr_object = visadev(connectionID);
        end

        function instr_object = connect_visa(connectionID)
            instr_find_result = instrfind('Type', 'visa-usb', 'RsrcName', connectionID, 'Tag', '');

            if isempty(instr_find_result)
                instr_object = visa('KEYSIGHT', connectionID);
            else
                fclose(instr_find_result);
                instr_object = instr_find_result(1);
            end

            device_buffer = 10000*8;
%             set(instr_object,'OutputBufferSize',(device_buffer+125));
            set(instr_object,'InputBufferSize',(device_buffer+125));
            
        end

        function revived_sig = read_data_normal(connectionID)

            % connect to the instrument
            instr_object = MSO.connect_visadev(connectionID);
            
            instr_name = writeread(instr_object, '*IDN?');
            disp(['mso -> connected to ', instr_name]);

            write(instr_object, ':STOP');
            write(instr_object, ':WAV:SOUR CHAN1');

            write(instr_object, ':WAV:MODE NORMal');
            write(instr_object, ':WAV:FORM BYTE');

            pre = writeread(instr_object, ':WAV:PRE?');
           

            write(instr_object, ':WAV:DATA?');
            data2 = readbinblock(instr_object, 'uint8');

            errs = writeread(instr_object, ':SYST:ERR?');
            write(instr_object, ':RUN');
            
            disp(['mso -> errors: ' , errs]);
            

            % aqcuired data processing
            split_pre = split(pre, ',');
            disp(split_pre(5));
            yincrement = str2num(split_pre(8));
            yref = str2num(split_pre(10));


            revived_sig = zeros(1, length(data2));
            ypositive_indexes = find(data2 > yref);
            ynegative_indexes = find(data2 < yref);
            
            positive_data = (data2(ypositive_indexes) - yref)*yincrement;
            negative_data = (data2(ynegative_indexes) - yref)*yincrement;
            
            revived_sig(ypositive_indexes) = positive_data;
            revived_sig(ynegative_indexes) = negative_data;


        end


        function revived_sig = read_data_raw(connectionID, points)


            % connect to the instrument
            instr_object = MSO.connect_visadev(connectionID);
            
            instr_name = writeread(instr_object, '*IDN?');
            disp(['mso -> connected to ', instr_name]);

            write(instr_object, ':STOP');
            write(instr_object, ':WAV:SOUR CHAN1');

            write(instr_object, ':WAV:MODE RAW');
            write(instr_object, ':WAV:FORM BYTE');
            write(instr_object, [':WAV:POINts ', num2str(points)]);

            pre = writeread(instr_object, ':WAV:PRE?');
            

            write(instr_object, ':WAV:DATA?');
            data2 = readbinblock(instr_object, 'uint8');

            errs = writeread(instr_object, ':SYST:ERR?');
            write(instr_object, ':RUN');
            
            disp(['mso -> errors: ' , errs]);
            

            % aqcuired data processing
            split_pre = split(pre, ',');
            disp(split_pre(5));
            yincrement = str2num(split_pre(8));
            yref = str2num(split_pre(10));


            revived_sig = zeros(1, length(data2));
            ypositive_indexes = find(data2 > yref);
            ynegative_indexes = find(data2 < yref);
            
            positive_data = (data2(ypositive_indexes) - yref)*yincrement;
            negative_data = (data2(ynegative_indexes) - yref)*yincrement;
            
            revived_sig(ypositive_indexes) = positive_data;
            revived_sig(ynegative_indexes) = negative_data;
        end
    end
end