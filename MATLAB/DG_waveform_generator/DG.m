classdef DG
    % methods:
    %   DG.load_data(connectionID, chNum, amp)
    %   sets the amplitude value of the Trueform 33600A generator
    %
    %   WG.load_data(connectionID, data, chNum, fs, ArbFileName)
    %   upload data to generator and send it to chosen channel. Set sample
    %   frequency
    properties (Constant)
        
        M = containers.Map([25e6, 125e6, 250e6, 500e6], [7, 3, 2, 1]);
        
    end

    
    methods (Static)

        function s_string = stringify(data)
            s_string = '';

            for i = 1:length(data)
                s_string = [s_string, ',', num2str(data(i))];
            end
            
        end

        function instr_object = connect_visadev(connectionID)
             
                instr_object = visadev(connectionID);
                        
        end

        function load_data(connID, data, fs, amp)
            

            % If generator sampling frequency is not available
            % make a warning and stop execution

            try
                Fs_instr = DG.M(fs);
            catch ME
                if (strcmp(ME.identifier, 'MATLAB:Containers:Map:NoKey'))
                    error('Generator sampling frequency can only be 25MHz, 125MHz, 250MHz, 500MHz');                    
                end
            end



            L = 16383;
            zeros_length = L - length(data);
            zeros_arr = zeros(1, zeros_length);
            singnal_with_zeros = [data, zeros_arr];
            
            % normalize if data abolute
            data_max = max(abs(singnal_with_zeros));

            
            singnal_with_zeros = singnal_with_zeros/data_max;
            


            s_string = DG.stringify(singnal_with_zeros);

            instr_object = DG.connect_visadev(connID);
            
            % Ask the instrument for it's name
            instr_name = writeread(instr_object, '*IDN?');
            disp(['dg -> connected to ', instr_name]);

            
%             interp_value = writeread(instr_object, ':DATA:POIN:INT?');
%             disp(['before load: ', interp_value]);
            
            write(instr_object, [':VOLTage ', num2str(amp)]);
            write(instr_object, ':FUNCtion:ARB:MODE PLAY');
            write(instr_object, [':FUNCtion:ARB:SAMPLE ', num2str(Fs_instr)]);


            write(instr_object, [':DATA VOLATILE,', s_string]);
            write(instr_object, '*WAI');
            er = writeread(instr_object, 'SYST:ERR?');
            disp(['dg -> errors: ' , er]);
            write(instr_object, ':OUTPut ON');  


%             pts = writeread(instr_object, ':DATA:POINts? VOLATILE');
%             disp(['points? = ', num2str(pts)]);

        end
    end
    
end