classdef Test_signals

  methods (Static)

    function [output_signal, freqline] = normalized_ofdm()
    % Create normalized (in time domain) OFDM symbol with Fs = 25e6, Fc = 5e6, FFTSIZE = 1024
    % INTERPOLATION = 20, the output length = 1024*20

      guards = 100;
      fft_size = 1024;
      interpolated_size = fft_size*20;
      sig_ofdm = zeros(1, fft_size);
      sc_num = fft_size - guards*2;

      sig2 = qammod(randi([0, 15], 1, sc_num), 16);

      sig_ofdm(guards + 1:fft_size/2) = sig2(1:sc_num/2);
      sig_ofdm(fft_size/2 + 1) = complex(0, 0);
      sig_ofdm(fft_size/2 + 2:end-guards + 1) = sig2(sc_num/2 + 1:end);

      sig_ofdm_shifted = fftshift(sig_ofdm);
      sig_ofdm_shifted = [sig_ofdm_shifted(1:fft_size/2), complex(zeros(1, interpolated_size - fft_size)), sig_ofdm_shifted(fft_size/2 + 1: end)];

      sig_ofdm_shifted_time = ifft(sig_ofdm_shifted);


      fs = 25e6;
      fc = 10e6;
      t = 0:1/fs:(interpolated_size - 1)/fs;

      freqline = 0:fs/interpolated_size:fs - 1;

      Q_carr = -sin(2*pi*fc*t);
      I_carr = cos(2*pi*fc*t);

      rf_sig_ofdm = real(sig_ofdm_shifted_time).*I_carr + imag(sig_ofdm_shifted_time).*Q_carr;
      m = max(abs(rf_sig_ofdm));
      kkk = 1/m;
      rf_sig_ofdm = rf_sig_ofdm*kkk;
      output_signal = rf_sig_ofdm;

    end

 
    function [sins, freqline] = normalized_two_sins()
        
        N = 10e3;
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
        
        N = 10e3;
        fs = 25e6;
        fc1 = 100e3;
        
        freqline = 0:fs/N:fs - 1;

        timeline = 0:1/fs:(N -1)/fs;
        single_sin = sin(2*pi*fc1*timeline);
        
        single_sin = single_sin/max(abs(single_sin));
%         single_sin(end) = 1;
%         single_sin(1) = 1;
    end


  end
end