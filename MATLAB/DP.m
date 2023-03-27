classdef DP
    % methods:
    %   WG.channel_amp(connectionID, chNum, amp)
    %   sets the amplitude value of the Trueform 33600A generator
    %
    %   WG.load_data(connectionID, data, chNum, fs, ArbFileName)
    %   upload data to generator and send it to chosen channel. Set sample
    %   frequency
    
    properties
        Property1
    end
    
    methods (Static)
        function instr_object = connect(connectionID)
            instr_object = visadev(connectionID);
            instr_object.Timeout = 10;
        end

        function set_voltage()
            instr_object = DP.connect('USB0::0x1AB1::0x0E11::DP8A244900528::0::INSTR');
            disp(instr_object);
            idn = writeread(instr_object, '*IDN?');
            disp(idn);
            write(instr_object, ':SOURce1:VOLTage 7');
            current_voltage = writeread(instr_object, ':SOURce1:VOLTage?');
            disp(['measured voltage = ', current_voltage]);
        end
    end
end