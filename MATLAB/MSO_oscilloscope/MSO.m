classdef MSO < handle
    
    % methods:
    %   MSO.channel_amp(connectionID, chNum, amp)
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


        function preambula_struct = create_preambula_struct(preambula)
            
            % preambula is acquired in form of csv (comma separated values)
            % so first of all split the values by ','
            split_preambula = split(preambula, ',');

            preambula_struct.format.value = str2num(split_preambula(1));
            preambula_struct.format.description = '<format>: indicates 0 (BYTE), 1 (WORD), or 2 (ASC).';

            preambula_struct.type.value = str2num(split_preambula(2));
            preambula_struct.type.description = '<type>: indicates 0 (NORMal), 1 (MAXimum), or 2 (RAW).';

            preambula_struct.points.value = str2num(split_preambula(3));
            preambula_struct.points.description = '<points>: After the memory depth option is installed, <points> is an integer ranging from 1 to 200,000,000.';

            preambula_struct.count.value = str2num(split_preambula(4));
            preambula_struct.count.description = '<count>: indicates the number of averages in the average sample mode. The value of <count> parameter is 1 in other modes.';

            preambula_struct.xincrement.value = str2num(split_preambula(5));
            preambula_struct.xincrement.description = '<xincrement>: indicates the time difference between two neighboring points in the X direction.';

            preambula_struct.xorigin.value = str2num(split_preambula(6));
            preambula_struct.xorigin.description = '<xorigin>: indicates the start time of the waveform data in the X direction.';

            preambula_struct.xreference.value = str2num(split_preambula(7));
            preambula_struct.xreference.description = '<xreference>: indicates the reference time of the waveform data in the X direction.';

            preambula_struct.yincrement.value = str2num(split_preambula(8));
            preambula_struct.yincrement.description = '<yincrement>: indicates the step value of the waveforms in the Y direction.';

            preambula_struct.yorigin.value = str2num(split_preambula(9));
            preambula_struct.yorigin.description = '<yorigin>: indicates the vertical offset relative to the "Vertical Reference Position" in the Y direction.';

            preambula_struct.yreference.value = str2num(split_preambula(10));
            preambula_struct.yreference.description = '<yreference>: indicates the vertical reference position in the Y direction.';


        end
        
        function [processed_data, preambula_struct] = process_acquired_data(data, preambula)
            preambula_struct = MSO.create_preambula_struct(preambula);

            if (preambula_struct.points.value ~= length(data))
                error('mso -> Read error: preambula.points != length(data)');
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

        function [revived_sig, preambula] = read_data_normal(connectionID, ch_num)

            % connect to the instrument
            instr_object = MSO.connect_visadev(connectionID);
            
            instr_name = writeread(instr_object, '*IDN?');
            disp(['mso -> connected to ', instr_name]);
            
            read_success_flag = 0;

            while ~read_success_flag
            
                try
                    % set the acquirance regime
                    write(instr_object, ':STOP');
                    write(instr_object, [':WAV:SOUR MATH', num2str(ch_num)]);
        
                    write(instr_object, ':WAV:MODE NORMal');
                    write(instr_object, ':WAV:FORM BYTE');
                    
                    % acquire preambula
                    pre = writeread(instr_object, ':WAV:PRE?');
                   
                    % acquire data
                    write(instr_object, ':WAV:DATA?');
                    write(instr_object, '*WAI');
                    data = readbinblock(instr_object, 'uint8');
                    
                    % check for system errors
                    errs = writeread(instr_object, ':SYST:ERR?');
                    write(instr_object, ':RUN');
                    
                    disp(['mso -> errors: ' , errs]);
                    
        
                    [revived_sig, preambula] = MSO.process_acquired_data(data, pre);

                    read_success_flag = 1;
                catch err

                    disp(['catched error read_data_normal: ', err.message]);

                end

            end


        end


        function [instr_object, revived_sig, preambula] = read_data_raw(connectionID, ch_num, points)


            % connect to the instrument
            instr_object = MSO.connect_visadev(connectionID);
            
            instr_name = writeread(instr_object, '*IDN?');
            disp(['mso -> connected to ', instr_name]);


            read_success_flag = 0;
            iteration_count = 0;

            while ~read_success_flag
                if iteration_count < 50
                    try
                        iteration_count = iteration_count + 1;
                
                        % set the acquirance regime
                        write(instr_object, ':STOP');
                        write(instr_object, [':WAV:SOUR CHAN', num2str(ch_num)]);
            
                        write(instr_object, ':WAV:MODE RAW');
                        write(instr_object, ':WAV:FORM BYTE');
                        write(instr_object, [':WAV:POINts ', num2str(points)]);
                        
                        % acquire preambula
                        pre = writeread(instr_object, ':WAV:PRE?');
                        
                        % acquire data
    %                     write(instr_object, ':WAV:DATA?');
    %                     write(instr_object, '*WAI');
    %                     data = readbinblock(instr_object, 'uint8');
    %                     
    %                     % check for system errors
    %                     errs = writeread(instr_object, ':SYST:ERR?');
                        write(instr_object, ':RUN');
                        
%                         disp(['mso -> errors: ' , errs]);
                        
%                         [revived_sig, preambula] = MSO.process_acquired_data(data, pre);
                        read_success_flag = 1;
                        revived_sig = 0;
                        preambula = 0;
                        
    
                    catch err
                

                        disp(['catched error read_data_raw: ', err.message]);
                        disp(['iteration #', num2str(iteration_count)]);

                    end

                else
                    revived_sig = 0;
                    preambula = 0;
                    break;
                end


            end


        end

        function [decimated_sig, preambula] = read_data(connectionID, ch_num, fs_gen)

            
            
            instr_object = MSO.read_data_raw(connectionID, ch_num, 10e3);
            
            read_success_flag = 0;
            while_loop = 0;

            

                while ~read_success_flag
                    if while_loop < 50

                        while_loop = while_loop + 1;
    
                        try


                            

                            % connect to the instrument
                            
%                             instr_object = MSO.connect_visadev(connectionID);
 
                            
                            instr_name = writeread(instr_object, '*IDN?');
                            disp(["mso -> connected to ", instr_name]);


                            disp(['mso -> reading iteration #', num2str(while_loop)]);
                            % set the acquirance regime
                            write(instr_object, ':STOP');
                            write(instr_object, [':WAV:SOUR CHAN', num2str(ch_num)]);
                
                            write(instr_object, ':WAV:MODE MAX');
        
                            write(instr_object, ':WAV:FORM BYTE');
                            
                            % acquire preambula
                            pre = writeread(instr_object, ':WAV:PRE?');
                            
                            % acquire data
                            write(instr_object, ':WAV:DATA?');
                            write(instr_object, '*WAI');
                            data = readbinblock(instr_object, 'uint8');
                            
                            disp(['MSO DEBUG -> data length = ', num2str(length(data))]);
                            if (length(data) == 1)
                                continue;
                            end

                            if  (length(data) == 1000)
                                clear instr_object;
                                instr_object = MSO.read_data_raw(connectionID, ch_num, 10e3);
                                continue;
                            end

                            
                            % check for system errors
                            errs = writeread(instr_object, ':SYST:ERR?');
                            srate = writeread(instr_object, ':ACQuire:SRATe?');
                            disp(['MSO DEBUG -> SRATE = ', srate]);
                            write(instr_object, ':RUN');
                            read_success_flag = 1;
                            % display system errors
                            disp(['mso -> errors: ' , errs]);
        
                            figure;
                                plot(data);
                            
                            [revived_sig, preambula] = MSO.process_acquired_data(data, pre);
                            
                            
                            
                            decimate_coeff = str2num(srate)/fs_gen;   % 2e9 is oscilloscope sampling frequency
                            disp(['MSO DEBUG -> DECI COEFF = ', num2str(decimate_coeff)]);

%                             decimated_sig = revived_sig(decimate_coeff:decimate_coeff:end);
                            decimated_sig = decimate(revived_sig, decimate_coeff);
        
                            
        
                        catch err
        
                            disp(['mso -> catched error in read_data_max: ', err.message]);
                            write(instr_object, ':RUN');
        
                        end
                    else
                        
                        disp('mso -> errors: Usuccesfull read');
                        return;

                    end
    
                end



        end


        function [instr_object, revived_sig, preambula] = read_raw(connectionID, ch_num, points)


            % connect to the instrument
            instr_object = MSO.connect_visadev(connectionID);
            
            instr_name = writeread(instr_object, '*IDN?');
            disp(['mso -> connected to ', instr_name]);


            read_success_flag = 0;
            iteration_count = 0;

            while ~read_success_flag
                if iteration_count < 50
                    try
                        iteration_count = iteration_count + 1;
                
                        % set the acquirance regime
                        write(instr_object, ':STOP');
                        write(instr_object, [':WAV:SOUR CHAN', num2str(ch_num)]);
            
                        write(instr_object, ':WAV:MODE RAW');
                        write(instr_object, ':WAV:FORM BYTE');
                        write(instr_object, [':WAV:POINts ', num2str(points)]);
                        
                        % acquire preambula
                        pre = writeread(instr_object, ':WAV:PRE?');
                        
                        % acquire data
                        write(instr_object, ':WAV:DATA?');
                        write(instr_object, '*WAI');
                        data = readbinblock(instr_object, 'uint8');
    %                     
    %                     % check for system errors
                        errs = writeread(instr_object, ':SYST:ERR?');
                        write(instr_object, ':RUN');
                        
                        disp(['mso -> errors: ' , errs]);
                        
                        [revived_sig, preambula] = MSO.process_acquired_data(data, pre);
                        read_success_flag = 1;
%                         revived_sig = 0;
%                         preambula = 0;
                        
    
                    catch err
                

                        disp(['catched error read_data_raw: ', err.message]);
                        disp(['iteration #', num2str(iteration_count)]);

                    end

                else
                    revived_sig = 0;
                    preambula = 0;
                    break;
                end


            end


        end

    end
end