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
        function instr_object = connect(connectionID)
            instr_object = visadev(connectionID);
            instr_object.Timeout = 5;
        end

        function test_ofdm()
            instr_object = DP.connect('USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR');
            disp(instr_object);
%             idn = writeread(instr_object, '*IDN?');
%             disp(idn);
            sig = Test_signals.normalized_ofdm;
            write(instr_object, num2str(sig));
            
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