classdef DG
    % methods:
    %   DG.load_data(connectionID, chNum, amp)
    %   sets the amplitude value of the Trueform 33600A generator
    %
    %   WG.load_data(connectionID, data, chNum, fs, ArbFileName)
    %   upload data to generator and send it to chosen channel. Set sample
    %   frequency

    
    methods (Static)

        function instr_object = connect_visadev(connectionID)
            instr_object = visadev(connectionID);
            instr_object.Timeout = 10;
        end

        function load_data(connID, data)
            
            % normalize if data abolute
            data_max = max(abs(data));

            if data_max > 1
                data = data/data_max;
            end

            data = round(data, 7);
            s_string = '';

            for i = 1:length(data)
                s_string = [s_string, ',', num2str(data(i))];
            end


            instr_object = DG.connect_visadev(connID);
            
            % Ask the instrument for it's name
            instr_name = writeread(instr_object, '*IDN?');
            disp(['dg -> connected to ', instr_name]);

            
            write(instr_object, [':DATA VOLATILE,', s_string]);

            er = writeread(instr_object, 'SYST:ERR?');
            disp(['dg -> errors: ' , er]);
            write(instr_object, ':OUTPut ON');  

        end
    end
end