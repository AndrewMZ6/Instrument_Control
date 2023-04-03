clc; close all; clearvars;
addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\');
s = Test_signals.two_sins;
s = s/max(s);


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
    obj1 = visa('RIGOL', 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR');
else
    fclose(obj1);
    obj1 = obj1(1);
end

set(obj1,'InputBufferSize',40e3);
obj1.Timeout = 40;
% Connect to instrument object, obj1.
fopen(obj1);

% Instrument Configuration and Control

% Communicating with instrument object, obj1.
data1 = query(obj1, '*IDN?');
disp(data1);


% fprintf(obj1, ':SINGle');

fprintf(obj1, ':WAV:SOUR CHAN1');
fprintf(obj1, ':WAV:MODE NORM');

% fprintf(obj1, ':WAV:POINts 20000');
fprintf(obj1, ':WAV:FORM BYTE');

data9 = query(obj1, ':WAV:PRE?');
% data10 = query(obj1, ':WAV:DATA?');
fprintf(obj1, 'WAV:DATA?');
rtrtr = binblockread(obj1, 'uint8');
fread(obj1, 1);
fprintf(obj1, '*WAI');

idn_after = query(obj1, '*IDN?');
opc = query(obj1, '*OPC?');

while ~opc
    opc = query(obj1, '*OPC?');
end

fclose(obj1);
figure; plot(rtrtr);




%% OSCI matlab seession but with VISADEV
clc; close all; clearvars;



obj1 = visadev('USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR');


% Instrument Configuration and Control

% Communicating with instrument object, obj1.
data1 = writeread(obj1, '*IDN?');

write(obj1, ':WAV:SOUR CHAN1');

write(obj1, ':WAV:MODE NORM');
write(obj1, ':WAV:FORM BYTE');
% write(obj1, ':WAV:POINts 10000');

pre = writeread(obj1, ':WAV:PRE?');

write(obj1, ':WAV:DATA?');

% data2 = readbinblock(obj1, 'uint8');
data2 = readbinblock(obj1);
% data2 = read(obj1);

figure;
plot(data2);

split_pre = split(pre, ',');
yincrement = str2num(split_pre(8));
yref = str2num(split_pre(10));

revived_sig = zeros(1, length(data2));
ypositive_indexes = find(data2 > yref);
ynegative_indexes = find(data2 < yref);

positive_data = (data2(ypositive_indexes) - yref)*yincrement;
negative_data = (data2(ynegative_indexes) - yref)*yincrement;

revived_sig(ypositive_indexes) = positive_data;
revived_sig(ynegative_indexes) = negative_data;


figure;

plot(revived_sig);




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


%%  OSCI measure
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


fprintf(obj1, ':SINGle');



fprintf(obj1, ':WAV:SOUR CHAN1');
fprintf(obj1, ':WAV:MODE RAW');

% fprintf(obj1, ':WAV:MODE ASCii');

fprintf(obj1, ':WAV:FORM BYTE');

fprintf(obj1, ':WAV:POINts 20000');

fprintf(obj1, ':MEAS:SOUR CHAN1');
fprintf(obj1, '*WAI');


data9 = query(obj1, ':WAV:PRE?');
fprintf(obj1, '*WAI');

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



%%  SHOW ALL
clc; close all; clearvars;


% Find a VISA-USB object.
obj1 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = visa('RIGOL', 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR');
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


data2 = query(obj1, 'ACQUIRE:TYPE?');
disp(data2);


data3 = query(obj1, 'WAV:FORM?');
disp(data3);


data4 = query(obj1, ':WAV:MODE?');
disp(data4);


data5 = query(obj1, ':WAV:POINTS?');
disp(data5);


data6 = query(obj1, ':TYPE?');
disp(data6);


disp(obj1.ByteOrder);
disp(obj1.InputBufferSize);


fclose(obj1);