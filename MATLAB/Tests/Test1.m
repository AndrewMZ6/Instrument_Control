clc; close all; clearvars;
addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\');
[s, f] = Test_signals.normalized_ofdm;


connectionID = 'USB0::0x1AB1::0x0640::DG5S244900056::0::INSTR';
DG.load_data(connectionID, s);


%% OSCIlloscope

[d, p] = MSO.get_data2('USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR');


rr = d(12:end);
ss = split(rr, ',');

for i = 1:length(ss)
    yy(i) = str2num(ss{i});
end

figure; plot(yy);


%% OSCI matlab seession
clc; close all; clearvars;


% Find a VISA-USB object.
obj1 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = visa('KEYSIGHT', 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR');
else
    fclose(obj1);
    obj1 = obj1(1);
end

set(obj1,'InputBufferSize',10e3);
obj1.Timeout = 40;
% Connect to instrument object, obj1.
fopen(obj1);

% Instrument Configuration and Control

% Communicating with instrument object, obj1.
data1 = query(obj1, '*IDN?');
disp(data1);


% fprintf(obj1, ':SINGle');

fprintf(obj1, ':WAV:SOUR CHAN1');
fprintf(obj1, ':WAV:MODE NORMal');

% fprintf(obj1, ':WAV:MODE ASCii');
% fprintf(obj1, ':WAV:POINts 20000');
fprintf(obj1, ':WAV:FORM ASCII');

data9 = query(obj1, ':WAV:PRE?');
data10 = query(obj1, ':WAV:DATA?');
fprintf(obj1, '*WAI');

idn_after = query(obj1, '*IDN?');
opc = query(obj1, '*OPC?');

while ~opc
    opc = query(obj1, '*OPC?');
end

fclose(obj1);


% 
rr = data10(12:end);
ss = split(rr, ',');

for i = 1:length(ss)
    yy(i) = str2num(ss{i});
end

figure; plot(yy);



%% OSCI matlab seession but with VISADEV
clc; close all; clearvars;



obj1 = visadev('USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR');


% Instrument Configuration and Control

% Communicating with instrument object, obj1.
data1 = query(obj1, 'IDN?');

fprintf(obj1, ':WAV:SOUR CHAN1');

fprintf(obj1, ':WAV:MODE NORMal');
fprintf(obj1, ':WAV:FORM ASCii');

data10 = query(obj1, ':WAV:DATA?');



%% OSCI TCP
clc; close all; clearvars;


% Find a tcpip object.
obj1 = instrfind('Type', 'tcpip', 'RemoteHost', '192.168.0.27', 'RemotePort', 5555, 'Tag', '');

% Create the tcpip object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = tcpip('192.168.0.27', 5555);
else
    fclose(obj1);
    obj1 = obj1(1);
end



set(obj1,'InputBufferSize',10e4);
obj1.Timeout = 40;


% Connect to instrument object, obj1.
fopen(obj1);

% Instrument Configuration and Control

% Communicating with instrument object, obj1.
data1 = query(obj1, '*IDN?');

fprintf(obj1, ':WAV:SOUR CHAN1');
fprintf(obj1, ':WAV:MODE NORMal');

% fprintf(obj1, ':WAV:MODE ASCii');
% fprintf(obj1, ':WAV:POINts 20000');
fprintf(obj1, ':WAV:FORM ASCII');

data9 = query(obj1, ':WAV:PRE?');
data10 = query(obj1, ':WAV:DATA?');
fprintf(obj1, '*WAI');

idn_after = query(obj1, '*IDN?');
opc = query(obj1, '*OPC?');

while ~opc
    opc = query(obj1, '*OPC?');
end

fclose(obj1);


% 
rr = data10(12:end);
ss = split(rr, ',');

for i = 1:length(ss) - 1
    yy(i) = str2num(ss{i});
end

figure; plot(yy);


