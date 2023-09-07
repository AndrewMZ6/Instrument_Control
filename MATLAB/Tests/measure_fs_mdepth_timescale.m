clc; close all; clearvars;
addpath('..\Test_signals\', '..\DG_waveform_generator\', '..\MSO_oscilloscope\', '..\TF_waveform_generator');


mdepth_array = [25e6];
timescale_array = (100:100:5e3)*1e-6;
timescale_array = [timescale_array(1), timescale_array];
fs_surf = zeros(length(mdepth_array), length(timescale_array));


connectionID = 'USB0::0x1AB1::0x0515::MS5A244909354::0::INSTR';
instr_obj = MSO.connect_visadev(connectionID);

mdepth_counter = 1;
for md = mdepth_array
    write(instr_obj, '*RST');
    write(instr_obj, '*CLS');
    write(instr_obj, ':CLEAR');
    pause(0.5)


    MSO.set_memdepth(instr_obj, md);
    
    tscale_counter = 1;
    for tscale = timescale_array
        
        MSO.set_timescale(instr_obj, tscale);
        pause(2);
        current_Fs = MSO.get_current_Fs(instr_obj);
        fs_surf(mdepth_counter, tscale_counter) = current_Fs;

        tscale_counter = tscale_counter + 1;
        

    end

    mdepth_counter = mdepth_counter + 1;
end

clear instr_obj;

figure;
    surf(timescale_array*1e6, log10(mdepth_array), log10(fs_surf));
    xlabel('timescale, us (microseconds)');
    ylabel('mdepth, millions points');
    zlabel('fs');

    
figure;
legends = {};
for i = 1:length(mdepth_array)
    
        p = semilogy(timescale_array*1e6, fs_surf(i,:));
        p.Marker = 'o';
        legends{i} = ['mdepth = ', num2str(mdepth_array(i), '%e')];
        hold on;
        
end
    
xlabel('timescale, us (microseconds)');
        ylabel('Fs');
        legend(legends);
        grid on;


return;

figure;

    
        p = semilogy(timescale_array*1e6, fs_surf);
        p.Marker = 'o';
        legends = ['mdepth = ', num2str(mdepth_array, '%e')];
        hold on;
        

    
        xlabel('timescale, us (microseconds)');
        ylabel('Fs');
        legend(legends);
        grid on;

%%
close all;