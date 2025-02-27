classdef MSO_class_based_unit_test < matlab.unittest.TestCase
    %Running tests commands:
    %   table(runtests('MSO_class_based_unit_test')) - run all tests
    %   run(MSO_class_based_unit_test, 'test_8GHz_fs') - run specific test

    properties
        osci_conn_ID
        channel_num
    end

    methods (TestMethodSetup)
        
        function mso_sleep(testCase)
            disp('test::Sleep');
            pause(1);
        end

    end

    methods (TestClassSetup)

        function set_initial_parameters(testCase)
            addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\', '..\TF_waveform_generator');
            testCase.channel_num = 4;
            testCase.osci_conn_ID = 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR';
        end

    end
        
    methods (Test)

        function test_100MHz_fs(testCase)

            user_fs = 100e6;
            user_numpoints = 2e6;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(oscilloscope_data.fs_instr, user_fs);
        end

        function test_200MHz_fs(testCase)

            user_fs = 200e6;
            user_numpoints = 2e6;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(oscilloscope_data.fs_instr, user_fs);
        end


        function test_300MHz_fs_not_available(testCase)

            user_fs = 300e6;
            user_numpoints = 2e6;
            testCase.verifyError(@()MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs), ...
                                'MSO:NotavailableFrequencyError');
        end


        function test_400MHz_fs_not_available(testCase)

            user_fs = 400e6;
            user_numpoints = 2e6;
            testCase.verifyError(@()MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs), ...
                                'MSO:NotavailableFrequencyError');

        end

        function test_500MHz_fs(testCase)

            user_fs = 500e6;
            user_numpoints = 100e3;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(oscilloscope_data.fs_instr, user_fs);

        end


        function test_600MHz_fs_not_available(testCase)

            user_fs = 600e6;
            user_numpoints = 1e6;
            testCase.verifyError(@()MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs), ...
                                'MSO:NotavailableFrequencyError');

        end


        function test_700MHz_fs_not_available(testCase)

            user_fs = 700e6;
            user_numpoints = 1e6;
            testCase.verifyError(@()MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs), ...
                                'MSO:NotavailableFrequencyError');

        end


        function test_800MHz_fs_not_available(testCase)

            user_fs = 800e6;
            user_numpoints = 1e6;
            testCase.verifyError(@()MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs), ...
                                'MSO:NotavailableFrequencyError');

        end

        function test_900MHz_fs_not_available(testCase)

            user_fs = 900e6;
            user_numpoints = 1e6;
            testCase.verifyError(@()MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs), ...
                                'MSO:NotavailableFrequencyError');

        end


        function test_1GHz_fs(testCase)

            user_fs = 1e9;
            user_numpoints = 10e3;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(oscilloscope_data.fs_instr, user_fs);

        end


        function test_2GHz_fs(testCase)

            user_fs = 2e9;
            user_numpoints = 10e3;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(oscilloscope_data.fs_instr, user_fs);

        end


        function test_3GHz_fs_not_available(testCase)

            user_fs = 3e9;
            user_numpoints = 10e3;
            testCase.verifyError(@()MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs), ...
                                'MSO:NotavailableFrequencyError');

        end


        function test_4GHz_fs(testCase)

            user_fs = 4e9;
            user_numpoints = 25e6;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(oscilloscope_data.fs_instr, user_fs);

        end


        function test_5GHz_fs_not_available(testCase)

            user_fs = 5e9;
            user_numpoints = 10e3;
            testCase.verifyError(@()MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs), ...
                                'MSO:NotavailableFrequencyError');

        end


        function test_6GHz_fs_not_available(testCase)

            user_fs = 6e9;
            user_numpoints = 10e3;
            testCase.verifyError(@()MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs), ...
                                'MSO:NotavailableFrequencyError');

        end


        function test_7GHz_fs_not_available(testCase)

            user_fs = 7e9;
            user_numpoints = 10e3;
            testCase.verifyError(@()MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs), ...
                                'MSO:NotavailableFrequencyError');

        end



        function test_8GHz_fs(testCase)

            user_fs = 8e9;
            user_numpoints = 1000e3;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(oscilloscope_data.fs_instr, user_fs);

        end


        function test_1k_points(testCase)

            user_fs = 100e6;
            user_numpoints = 1e3;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(length(oscilloscope_data.data), user_numpoints);
        end


        function test_10k_points(testCase)

            user_fs = 100e6;
            user_numpoints = 8e3;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(length(oscilloscope_data.data), user_numpoints);

        end


        function test_100k_points(testCase)

            user_fs = 100e6;
            user_numpoints = 80e3;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(length(oscilloscope_data.data), user_numpoints);

        end


        function test_1M_points(testCase)

            user_fs = 100e6;
            user_numpoints = 0.8e6;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(length(oscilloscope_data.data), user_numpoints);

        end


        function test_10M_points(testCase)

            user_fs = 100e6;
            user_numpoints = 8e6;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(length(oscilloscope_data.data), user_numpoints);

        end


        function test_25M_points(testCase)

            user_fs = 100e6;
            user_numpoints = 22e6;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(length(oscilloscope_data.data), user_numpoints);

        end


        function test_50M_points(testCase)

            user_fs = 100e6;
            user_numpoints = 50e6;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(length(oscilloscope_data.data), user_numpoints);

        end


        function test_100M_points(testCase)

            user_fs = 100e6;
            user_numpoints = 100e6;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(length(oscilloscope_data.data), user_numpoints);

        end

        
        function test_1_point(testCase)

            user_fs = 100e6;
            user_numpoints = 1;
            [~, oscilloscope_data] = MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs);
            testCase.verifyEqual(length(oscilloscope_data.data), user_numpoints);

        end


        function test_200M_points_not_available(testCase)

            user_fs = 100e6;
            user_numpoints = 200e6;
            testCase.verifyError(@()MSO.read_raw_bytes_fs(testCase.osci_conn_ID, testCase.channel_num, user_numpoints, user_fs), ...
                                'MSO:NotavailablePointsNumError');


        end



    end
    
end