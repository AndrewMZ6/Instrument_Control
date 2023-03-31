classdef DG
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
            instr_object.Timeout = 5;
        end

        function instr_object = connect_visa(connectionID)
            instr_find_result = instrfind('Type', 'visa-usb', 'RsrcName', connectionID, 'Tag', '');

            if isempty(instr_find_result)
                instr_object = visa('KEYSIGHT', connectionID);
            else
                fclose(instr_find_result);
                instr_object = instr_find_result(1);
            end
            
        end

        function test_IDN()
            instr_object = DG.connect_visa('USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR');
            disp(instr_object);
            fopen(instr_object);
%             idn = writeread(instr_object, '*IDN?');
%             disp(idn);
%             sig = Test_signals.normalized_ofdm;
%             write(instr_object, num2str(sig));
            s = query(instr_object, '*IDN?');
            disp(['The instrument answer to IDN? is: ', s]);


            fclose(instr_object);
            
        end

        function load_data(connectionID, data)
            s_string = '';
            for i = 1:length(data)
                s_string = [s_string, ',', num2str(data(i))];
            end


            instr_object = DG.connect_visa(connectionID);
            device_buffer = 100000*8;
            set(instr_object,'OutputBufferSize',(device_buffer+125));
            fopen(instr_object);

            fprintf(instr_object, [':DATA VOLATILE,', s_string]);
            fprintf(instr_object, '*WAI');
            fprintf(instr_object, ':DIGI:RATE 40e6');

            er = query(instr_object, 'SYST:ERR?');
            disp(['MY ERROR: ' , er]);
            fprintf(instr_object, ':OUTPut ON');
            fclose(instr_object);

        end


        function [instr_find_result] = get_voltage()
            connectionID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR';
            instr_find_result = instrfind('Type', 'visa-usb', 'RsrcName', connectionID, 'Tag', '');

            disp('line 31:');
            disp(instr_find_result);


            if isempty(instr_find_result)
                instr_object = visa('KEYSIGHT', connectionID);
            else
                fclose(instr_find_result);
                instr_object = instr_find_result(1);
            end

            disp('line 42:')
            disp(instr_object);


            device_buffer = 100000*8;
            set(instr_object,'OutputBufferSize',(device_buffer+125));

            fopen(instr_object);


            fprintf(instr_object, '*RST;*CLS');
            disp('line 53:');
            disp(instr_object);

            fprintf(instr_object, '*IDN?');
            disp('before closing: line 57');
            r = fscanf(instr_object);
            disp(r)
            fclose(instr_object);
        end
    end
end