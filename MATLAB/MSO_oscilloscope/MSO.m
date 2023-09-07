classdef MSO < handle
    
    % methods:
    %   MSO.channel_amp(connectionID, chNum, amp)
    %   sets the amplitude value of the Trueform 33600A generator
    %
    %   WG.load_data(connectionID, data, chNum, fs, ArbFileName)
    %   upload data to generator and send it to chosen channel. Set sample
    %   frequency
    
    properties (Constant)
        Mdepth_index =  [ 1,      2,       3,     4,       5,     6,     7,      8];
        Mdepth_str =    {'1k',   '10k',  '100k', '1M',   '10M', '25M', '50M', '100M'};

        Mem_depth_map = containers.Map(MSO.Mdepth_str, MSO.Mdepth_index);

%         available_frequencies = [2e6, 5e6, 10e6, 20e6, 50e6, 100e6, 200e6, ...
%                                   500e6, 1e9, 2e9, 4e9, 8e9];
        available_frequencies_strings = {'2MHz', '5MHz', '10MHz', '20MHz', '50MHz', '100MHz', '200MHz', ...
                                   '500MHz', '1GHz', '2GHz', '4GHz', '8GHz'};


        Mdepth =    [1e3;   1e4;    1e5;    1e6;    1e7;    25e6;   50e6;   1e8];
        fs_2MHz =   [30;    300;    3e3;    30e3;   300e3;  8e5;    12e5;   30e5]*1e-6;
        fs_5MHz =   [15;    150;    15e2;   15e3;   150e3;  3e5;    8e5;    15e5]*1e-6;
        fs_10MHz =  [7;     70;     7e2;    7e3;    70e3;   1.5e5;  3e5;    7e5]*1e-6;        
        fs_20MHz =  [4;     40;     4e2;    4e3;    40e3;   70e3;   1.5e5;  4e5]*1e-6;
        fs_50MHz =  [1.5;   15;     150;    1500;   15e3;   30e3;   80e3;   15e4]*1e-6;
        fs_100MHz = [0.75;  7.5;    75;     750;    75e2;   15e3;   30e3;   75e3]*1e-6;
        fs_200MHz = [0.3;   3;      30;     300;    3e3;    8e3;    15e3;   3e4]*1e-6;
        fs_500MHz = [0.15;  1.5;    15;     150;    1500;   3e3;    8e3;    15e3]*1e-6;
        fs_1GHz =   [7;     70;     7e2;    7e3;    7e4;    15e4;   3e5;    7e5]*1e-8;       % поменялась степень множителя
        fs_2GHz =   [3.5;   35;     350;    35e2;   35e3;   8e4;    15e4;   35e4]*1e-8;
        fs_4GHz =   [1.5;   15;     150;    1500;   15e3;   4e4;    8e4;    15e4]*1e-8;
        fs_8GHz =   [0.7;    7;     70;     700;    7e3;    1e4;    4e4;    7e4]*1e-8;

        available_fs = [MSO.fs_2MHz, MSO.fs_5MHz, MSO.fs_10MHz, MSO.fs_20MHz, MSO.fs_50MHz, ...
                        MSO.fs_100MHz, MSO.fs_200MHz, MSO.fs_500MHz, MSO.fs_1GHz, MSO.fs_2GHz, MSO.fs_4GHz, MSO.fs_8GHz]

        
%         fs_map = containers.Map(MSO.available_frequencies, MSO.available_fs);


        freq_table = table(MSO.Mdepth, MSO.fs_2MHz, MSO.fs_5MHz, MSO.fs_10MHz, MSO.fs_20MHz, MSO.fs_50MHz, ...
                           MSO.fs_100MHz, MSO.fs_200MHz, MSO.fs_500MHz, MSO.fs_1GHz, MSO.fs_2GHz, MSO.fs_4GHz, MSO.fs_8GHz, ...
                           'VariableNames', {'Mdepth', 'fs_2MHz', 'fs_5MHz', 'fs_10MHz', 'fs_20MHz', 'fs_50MHz', 'fs_100MHz', ...
                           'fs_200MHz', 'fs_500MHz', 'fs_1GHz', 'fs_2GHz', 'fs_4GHz', 'fs_8GHz'});
        
        
        available_frequencies = [2e6, 5e6, 10e6, 20e6, 50e6, 100e6, 200e6, ...
                                   500e6, 1e9, 2e9, 4e9, 8e9];

        available_frequencies_str = {'fs_2MHz', 'fs_5MHz', 'fs_10MHz', 'fs_20MHz', 'fs_50MHz', 'fs_100MHz', 'fs_200MHz', ...
                                   'fs_500MHz', 'fs_1GHz', 'fs_2GHz', 'fs_4GHz', 'fs_8GHz'};

        fs_table_name = containers.Map(MSO.available_frequencies, MSO.available_frequencies_str);

    end
    

    methods (Static)
        function instr_object = connect_visadev(connectionID)
            
            try
                instr_object = visadev(connectionID);
                instr_object.Timeout = 10;
            catch err
                disp(err.message)
                if strcmp(err.message, 'Resource string is invalid or resource was not found.')
                    warning('Инструмент выключен D:');
                    
                end
            end
            
        end


        function time_scale = get_timescale_from_table(fs, pts_num)

            fs_str = MSO.get_fs_table_name(fs);
            points_index = MSO.freq_table.Mdepth == pts_num;

            time_scale = MSO.freq_table.(fs_str)(points_index);

        end

        function fs_string = get_fs_table_name(fs_num)

            

            available_frequencies_one_line = ['2MHz, 5MHz, 10MHz, 20MHz, 50MHz, 100MHz, 200MHz,', ...
                                   '500MHz, 1GHz, 2GHz, 4GHz, 8GHz'];
            
            try
                fs_string = MSO.fs_table_name(fs_num);
            catch ME
                if (strcmp(ME.identifier, 'MATLAB:Containers:Map:NoKey'))
                    error('MSO:unavailableSamplingFrequencyError', ['Sampling Frequency you entered is not available for MSO oscilloscope. ' ...
                        'List of available Fs: ', available_frequencies_one_line]);
                end
            end


        end

        function is_fs_mso_available(fs)
            
            fs_arr = [8e9, 4e9, 2e9, 1e9, 500e6, 200e6, ...
                        100e6, 50e6, 20e6, 10e6, 5e6, 2e6, 1e6];

            available_frequencies_one_line = ['2MHz, 5MHz, 10MHz, 20MHz, 50MHz, 100MHz, 200MHz,', ...
                                   '500MHz, 1GHz, 2GHz, 4GHz, 8GHz'];

            if ~ismember(fs, fs_arr)
                error('MSO:NotavailableFrequencyError', ...
                    ['Sampling Frequency you entered is not available for MSO oscilloscope. ' ...
                        'List of available Fs: ', available_frequencies_one_line]);
            end

        end

        function [points_str, points_num] = get_available_points(Npoints)
            % Npoints - number of points to be read asked by user


            arr_keys = [1e3, 10e3, 100e3, 1e6, 10e6, 25e6, 50e6, 100e6];
            arr_vals = {'1k', '10k', '100k', '1M', '10M', '25M', '50M', '100M'};
            M = containers.Map(arr_keys, arr_vals);

           available_points = [1e3, 10e3, 100e3, 1e6, 10e6, 25e6, 50e6, 100e6];
           temp = available_points(available_points >= Npoints);

           if isempty(temp)
              
               error('MSO:NotavailablePointsNumError', ...
                   ['The number of points you entered is too large. Available points are ', ...
                   '1 to 100M'])
              
           end


           points_num = temp(1);
           points_str = M(temp(1));

        end

        function time_scale = calculate_timescale(fs, Npoints)
            
            Ts = 1/fs;
            disp(['calculate_time_scale: fs = ', num2str(fs, '%e'), ' Npoints = ', num2str(Npoints, '%e')]);
            T_screen = Ts*Npoints;
            time_scale = T_screen/10;
            disp(['calculated time_scale = ', num2str(time_scale, '%e')]);

        end


        function preambula_struct = create_preambula_struct(preambula)
            
            % preambula is acquired in form of csv (comma separated values)
            % so first of all split the values by ','
            split_preambula = split(preambula, ',');

            % make structure "preambula" where value and description is
            % stored for every field
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
                            write(instr_object, ':RUN');
                            read_success_flag = 1;
                            % display system errors
                            disp(['mso -> errors: ' , errs]);
        
                            
                            [revived_sig, preambula] = MSO.process_acquired_data(data, pre);
                            
                            
                            decimate_coeff = str2double(srate)/fs_gen;   % 2e9 is oscilloscope sampling frequency
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


        function [revived_sig, timeline] = read_raw_ascii(connectionID, ch_num, points)


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
                        write(instr_object, [':WAV:POINts ', num2str(points)]);

                        write(instr_object, ':WAV:FORM ASCii');
                        
                        
                        % acquire preambula
                        pre = writeread(instr_object, ':WAV:PRE?');
                        
                        % acquire data
                        revived_sig = writeread(instr_object, ':WAV:DATA?');
                        write(instr_object, ':RUN');
                        preambula_struct = MSO.create_preambula_struct(pre);
                        temp = 0:preambula_struct.points.value;
                        timeline = temp*preambula_struct.xincrement.value;
                        
                        return;
                        write(instr_object, ':WAV:DATA?');
                        write(instr_object, '*WAI');
                        data = readbinblock(instr_object, 'uint8');
    %                     
    %                     % check for system errors
                        errs = writeread(instr_object, ':SYST:ERR?');
                        write(instr_object, ':RUN');
                        
                        disp(['mso -> errors: ' , errs]);
                        
%                         [revived_sig, preambula] = MSO.process_acquired_data(data, pre);
                        read_success_flag = 1;
%                         revived_sig = 0;
%                         preambula = 0;
                        revived_sig = data;
                        
    
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

        function [revived_sig, timeline, data] = read_raw_bytes(connectionID, ch_num, points)


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
                        write(instr_object, [':WAV:POINts ', num2str(points)]);

                        write(instr_object, ':WAV:FORM BYTE');
                        
                        
                        % acquire preambula
                        pre = writeread(instr_object, ':WAV:PRE?');
                        
                        % acquire data
%                         write(instr_object, ':WAV:DATA?');
%                         write(instr_object, ':RUN');
                        preambula_struct = MSO.create_preambula_struct(pre);
                        temp = 0:preambula_struct.points.value;
                        timeline = temp*preambula_struct.xincrement.value;
                        
                        write(instr_object, ':WAV:DATA?');
                        write(instr_object, '*WAI');
                        data = readbinblock(instr_object, 'uint8');
                        disp(['readbinblock length = ', num2str(length(data))]);
    %                     
    %                     % check for system errors
                        errs = writeread(instr_object, ':SYST:ERR?');
                        write(instr_object, ':RUN');
                        
                        disp(['mso -> errors: ' , errs]);
                        
                        [revived_sig, preambula] = MSO.process_acquired_data(data, pre);
                        read_success_flag = 1;
                        
                      
                        
    
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

        function [revived_sig, oscilloscope_data] = read_raw_bytes_fs(connectionID, ch_num, points, fs)

            % initial checks of available fs and available points
            MSO.is_fs_mso_available(fs);
            [pts_str, pts_num] = MSO.get_available_points(points);


            % calculate oscilloscope display timescale
%             tscale = MSO.calculate_timescale(fs, pts_num);
            tscale = MSO.get_timescale_from_table(fs, pts_num);


            % connect to the instrument
            instr_object = MSO.connect_visadev(connectionID);
            instr_name = writeread(instr_object, '*IDN?');
            disp(['mso -> connected to ', instr_name]);

            
            % set points number and timescale
            write(instr_object, [':ACQ:MDEP ', pts_str]);
            write(instr_object, [':TIM:SCAL ', num2str(tscale)]);
            
            


            % create counters
            read_success_flag = 0;
            iteration_count = 0;


            % main data acquisition loop
            while ~read_success_flag
                if iteration_count < 3
                    try
                        iteration_count = iteration_count + 1;
                        disp(['iteration #', num2str(iteration_count)]);
                
                        % set the acquirance regime
                        write(instr_object, ':STOP');
                        write(instr_object, [':WAV:SOUR CHAN', num2str(ch_num)]);
                        write(instr_object, ':WAV:MODE RAW');
                        write(instr_object, [':WAV:POINts ', num2str(points)]);
                        write(instr_object, ':WAV:FORM BYTE');
                        
                        
                        % acquire preambula
                        pre = writeread(instr_object, ':WAV:PRE?');
                        preambula_struct = MSO.create_preambula_struct(pre);


                        % create timeline axis for plotting aqcuired data: plot(timeline, aqcuired_data)
                        temp = 0:preambula_struct.points.value;
                        timeline = temp*preambula_struct.xincrement.value;


                        % acquire data
                        write(instr_object, ':WAV:DATA?');
                        write(instr_object, '*WAI');
                        data = readbinblock(instr_object, 'uint8');
                        
      
                        % check for system errors
                        errs = writeread(instr_object, ':SYST:ERR?');
                        write(instr_object, ':RUN');                        
                        disp(['mso -> errors: ' , errs]);

                        if (preambula_struct.points.value ~= points)
                            
                            error('MSO:acquireDataPontsNumberError', ['Demaded ', num2str(points, '%e'), ' points' ...
                                ', but got ', num2str(preambula_struct.points.value, '%e'), ' points'])
                        end


                        % process acquired data according to preambula data                        
                        [revived_sig, preambula] = MSO.process_acquired_data(data, pre);

                        fs_instr = str2double(writeread(instr_object, ':ACQ:SRATe?'));
                        
                        
                        % create "oscilloscope_data" struct with service data
                        oscilloscope_data.timeline = timeline;
                        oscilloscope_data.data = data;
                        oscilloscope_data.fs_instr = fs_instr;
                        oscilloscope_data.preambula = preambula;


                        read_success_flag = 1;
    
                    catch err
 
                        disp(['MSO::read_raw_bytes_fs ERROR: ', err.message]);
 
                    end

                else
                    error('MSO:maximumIterationNumberError', 'Maximum iterations number is exceeded');                    
                end


            end


        end


        function set_memdepth(instr_obj, md)

            md_str = MSO.get_available_points(md);
            command = [':ACQ:MDEP ', md_str];
            write(instr_obj, command);

        end


        function set_timescale(instr_obj, tscale)

            command = [':TIM:SCAL ', num2str(tscale)];
            write(instr_obj, command);

        end


        function fs = get_current_Fs(instr_obj)
            fs = str2double(writeread(instr_obj, ':ACQ:SRATe?'));
        end

    end
end