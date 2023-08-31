function tests = DG_function_based_unit_test
    tests = functiontests(localfunctions);
end


function test_one(testCase)
    addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\', '..\TF_waveform_generator');

    signal = Test_signals.normalized_ofdm();
    dg_conn_ID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR';
    data_to_load = signal.data;
    amp = .7;

    DG.load_data(dg_conn_ID, 'ello', signal.Fs, amp);
end


function test_two(testCase)

    
    dg_conn_ID = 'USB0::0x1AB1::0x0640::DG5asdadS244900056::0::INSTR';
    DG.load_data(dg_conn_ID, [.1, .5], signal.Fs, amp);

end
