classdef DG_class_based_unit_test < matlab.unittest.TestCase
        
    methods (Test)

        function test_one(testCase)
            addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\', '..\TF_waveform_generator');
        
            signal = Test_signals.normalized_ofdm();
            dg_conn_ID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR';
            data_to_load = signal.data;
            amp = .7;
        
            DG.load_data(dg_conn_ID, 'ello', signal.Fs, amp);
        end

    end
    
end