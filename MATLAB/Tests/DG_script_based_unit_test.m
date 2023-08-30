clc; close all; clearvars;
% preconditions
addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\', '..\TF_waveform_generator');

signal = Test_signals.normalized_ofdm();
dg_conn_ID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR';
data_to_load = signal.data;
amp = .7;

%% test all right conditions


DG.load_data(dg_conn_ID, data_to_load, signal.Fs, amp);

%% test wrond id 

dg_conn_ID = 'USB0::0x1AB1::0x0640::DG5asdadS244900056::0::INSTR';
DG.load_data(dg_conn_ID, data_to_load, signal.Fs, amp);


%% test string Fs

DG.load_data(dg_conn_ID, data_to_load, '125e6', amp);


%% test string Amp

DG.load_data(dg_conn_ID, data_to_load, 125e6, '10e-1');


%% test 10 valued data

data_to_load = [0, 0.1, 0.3, 0.4];
DG.load_data(dg_conn_ID, data_to_load, 125e6, 0.5);


%% test unavailable Fs

data_to_load = [0, 0.1, 0.3, 0.4];
DG.load_data(dg_conn_ID, data_to_load, 115e6, 0.5);