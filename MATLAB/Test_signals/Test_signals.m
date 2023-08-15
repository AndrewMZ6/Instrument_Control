classdef Test_signals

  properties (Constant)

    x = 10;
  end

  methods (Static)

      function output = normalized_ofdm(fft_size, interpolated_size, guards_size, fc, fs, M)
    % Create real (not complex) normalized in time domain (values are locked to
    % -1 to +1) OFDM symbol with length "interp_size"

      guards = guards_size; % 100
      fft_size = fft_size;
      interpolated_size = interpolated_size; %12800;


      % maaping bits
          sig_ofdm = zeros(1, fft_size);
          sc_num = fft_size - guards*2;
    
          MORDER = M;
          BPS = log2(MORDER);
          bits = randi([0, 1], 1, sc_num*BPS);
            
    
          sig2 = qammod(bits.', MORDER, 'InputType','bit');

    
    
          sig_ofdm(guards + 1:fft_size/2) = sig2(1:sc_num/2);
          sig_ofdm(fft_size/2 + 1) = complex(0, 0);
          sig_ofdm(fft_size/2 + 2:end-guards + 1) = sig2(sc_num/2 + 1:end);

      % -------------------------------------------------------


      sig_ofdm_shifted = fftshift(sig_ofdm);
      sig_ofdm_shifted = [sig_ofdm_shifted(1:fft_size/2), complex(zeros(1, interpolated_size - fft_size)), sig_ofdm_shifted(fft_size/2 + 1: end)];

      sig_ofdm_shifted_time = ifft(sig_ofdm_shifted);


      % Carrier frequency. Baseband to passband
          fs = fs;
          Ts = 1/fs;
          fc = fc;
          t = 0:Ts:(interpolated_size - 1)*Ts;
    
          freqline = 0:fs/interpolated_size:fs - 1;
    
          Q_carr = -sin(2*pi*fc*t);
          I_carr = cos(2*pi*fc*t);
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

    function [single_sin, freqline, timeline] = normalized_sin()
        
        N = 10000;
        fs = 125e6;
        fc = 5e6;
        
        freqline = 0:fs/N:fs - 1;

        timeline = 0:1/fs:(N -1)/fs;
        single_sin = sin(2*pi*fc*timeline);

    end
    

    function output_data = process_ofdm(rx_signal, tx_signal, M)
        
        % signal - struct containing the following fields:
        %   signal.data - real valued (not complex) passband ofdm signal
        %   signal.tx_data_length - length of the transmited ofdm signal
        %
        % output - struct with fileds:
        %   output.modulated_data - payload modulated data
        %   output.bits - demodulated payload ready to be compared
        
        [correlation_without_window, lags] = xcorr(rx_signal, tx_signal);
        

        L = length(correlation_without_window);
        kaiser_win = [kaiser(L/2 - 1).', kaiser(L/2).'];
        gauss_win = [gausswin(L/2 - 1 , 2).', gausswin(L/2, 2).'];
        
        win = gauss_win;
        x1 = correlation_without_window.*win;

        [~, max_idx1] = max(abs(x1));
        start1 = lags(max_idx1);
        cut_rx_signal = rx_signal(start1 + 1:start1 + length(tx_signal));

        spec1 = fft(cut_rx_signal);
        modulated_data = [spec1(1537 - 412:1536), spec1(1538:1537 + 412)];


        


        output_data.modulated_data = modulated_data;
        output_data.bits = Test_signals.demodulate_ofdm_data(modulated_data, M);

    end
    
    function bits = demodulate_ofdm_data(modulated_data, M)

        std(modulated_data)
        disp(['prop = ', num2str(Test_signals.x)])
        
        normalized_data = (modulated_data./std(modulated_data));
        normalization_factor = sqrt(M) - 1;
        
        bits = qamdemod(normalization_factor*normalized_data.', M, 'OutputType','bit').';
    end


  end
end