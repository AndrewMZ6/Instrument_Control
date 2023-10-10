classdef Test_signals

  properties (Constant)

      %OFDM control panel
        fft_size = 1024;
        interpolated_size = 12800;
        guards_size = 100;
        fc_ofdm = 15e6;
        fs_ofdm = 125e6;
        M_ofdm = 16;

     %SIN control panel
        N_sin = 10000;
        fs_sin = 125e6;
        fc_sin = 15e6;
    

    % common formula for BW, Fs, FftSize, InterpolatedSize
    %
    %          Fs*FftSize
    % BW = ------------------
    %       InterpolatedSize                  
    %

  end

  methods (Static)

      function output = normalized_ofdm()
    % Create real (not complex) normalized in time domain (values are locked to
    % -1 to +1) OFDM symbol with length "interp_size"
      
      
      % normalized_ofdm control panel
          grds = Test_signals.guards_size;
          fsize = Test_signals.fft_size;
          isize = Test_signals.interpolated_size;
          M = Test_signals.M_ofdm;
          fc = Test_signals.fc_ofdm;
          fs = Test_signals.fs_ofdm;


      % maping bits
          sig_ofdm = zeros(1, fsize);
          sc_num = fsize - grds*2;

          BPS = log2(M);
          bits = randi([0, 1], 1, sc_num*BPS);
    
          sig2 = qammod(bits.', M, 'InputType','bit');
    
          sig_ofdm(grds + 1:fsize/2) = sig2(1:sc_num/2);
          sig_ofdm(fsize/2 + 1) = complex(0, 0);
          sig_ofdm(fsize/2 + 2:end - grds + 1) = sig2(sc_num/2 + 1:end);

      % -------------------------------------------------------


      sig_ofdm_shifted = fftshift(sig_ofdm);
      sig_ofdm_shifted = [sig_ofdm_shifted(1:fsize/2), complex(zeros(1, isize - fsize)), sig_ofdm_shifted(fsize/2 + 1: end)];

      sig_ofdm_shifted_time = ifft(sig_ofdm_shifted);


      % Carrier frequency. Baseband to passband
          Ts = 1/fs;
          t = 0:Ts:(isize - 1)*Ts;
    
          freqline = 0:fs/isize:fs - 1;
    
          I_carr = -sin(2*pi*fc*t);
          Q_carr = cos(2*pi*fc*t);
          rf_sig_ofdm = real(sig_ofdm_shifted_time).*I_carr + imag(sig_ofdm_shifted_time).*Q_carr;


      % Normalize to max value = 1
          m = max(abs(rf_sig_ofdm));
          kkk = 1/m;
          rf_sig_ofdm_normalized = rf_sig_ofdm*kkk;


      % Create output struct
          output.data = rf_sig_ofdm_normalized;
          output.freqline = freqline;
          output.bits = bits;
          output.sig_ofdm = sig_ofdm_shifted;
          output.modulated_bits = sig2;
          output.modulation_order = M;
          output.Fs = fs;

          est_BW = ((fs*fsize)/isize)*1e-6;
          disp(['Estimated ofdm BW = ', num2str(est_BW), ' MHz']);

    end

 
    function [sins, freqline] = normalized_two_sins()
        
        N = 10000;
        fs = 25e6;
        fc1 = 50e3;
        fc2 = 100e3;

        freqline = 0:fs/N:fs - 1;

        timeline = 0:1/fs:(N -1)/fs;
        sin1 = sin(2*pi*fc1*timeline);
        sin2 = sin(2*pi*fc2*timeline);
        sins = sin1 + sin2;
        sins = sins/max(abs(sins));
    end

    function signal = normalized_sin()
        
        N = Test_signals.N_sin;
        fs = Test_signals.fs_sin;
        fc = Test_signals.fc_sin;
        
        freqline = 0:fs/N:fs - 1;
        timeline = 0:1/fs:(N -1)/fs;
        
        single_sin = sin(2*pi*fc*timeline);

        signal.data = single_sin;
        signal.freqline = freqline;
        signal.timeline = timeline;
        signal.Fs = fs;

    end
    

    function output_data = process_ofdm(rx_signal, tx_signal, M)
        
        %process_ofdm - method made to accept real valued time domain ofdm
        % signal as input and fetch complex data from it as well as
        % demodulate it using "demodulate_ofdm_data" method
        
        [correlation_without_window, lags] = xcorr(rx_signal, tx_signal);

        figure;
            plot(abs(correlation_without_window));
            grid on;
            title('process\_ofdm -> correlation');
        
        
        L = length(correlation_without_window) + 1;
        disp(['TEST SIGNALS DEBUG -> L = ', num2str(L)]);
        kaiser_win = [kaiser(L/2 - 1).', kaiser(L/2).'];
        gauss_win = [gausswin(L/2 - 1 , 2).', gausswin(L/2, 2).'];
        
        win = gauss_win;
        x1 = correlation_without_window.*win;

        [~, max_idx1] = max(abs(x1));
        start1 = lags(max_idx1);
        cut_rx_signal = rx_signal(start1 + 1:start1 + length(tx_signal));

        modulated_data = Test_signals.to_baseband(cut_rx_signal);

%         spec1 = fft(cut_rx_signal);
%         modulated_data = [spec1(1537 - 412:1536), spec1(1538:1537 + 412)];


        output_data.modulated_data = modulated_data;
        output_data.bits = Test_signals.demodulate_ofdm_data(modulated_data, M);
        output_data.cut_rx_signal = cut_rx_signal;
    end
    
    function bits = demodulate_ofdm_data(modulated_data, M)

        normalized_data = (modulated_data./std(modulated_data));
        normalization_factor = sqrt(M) - 1;

        bits = qamdemod(normalization_factor*normalized_data.', M, 'OutputType','bit').';
    end


    function x = to_baseband(cut_rx_signal)

        fs = Test_signals.fs_ofdm;
        fc = Test_signals.fc_ofdm;
        fsize = Test_signals.fft_size;
        gsize = Test_signals.guards_size;

        Ts = 1/fs;
        t = 0:Ts:(length(cut_rx_signal) -1)*Ts;
        
        I_carr = -sin(2*pi*fc*t);
        Q_carr = cos(2*pi*fc*t);
        
        I_cut_data = cut_rx_signal.*I_carr;
        Q_cut_data = cut_rx_signal.*Q_carr;
        
        xx=fft(complex(I_cut_data, Q_cut_data));
        
        left_index = fsize/2;
        right_index = fsize/2 - 1;
        
        
        restored = [xx(end-right_index:end), xx(1:left_index)];
        central_zero_sample = left_index + 1;

        cut_index = left_index - gsize;
        

        x = [restored(central_zero_sample - cut_index:central_zero_sample - 1), ...
            restored(central_zero_sample + 1:central_zero_sample + cut_index)];
    end


  end
end