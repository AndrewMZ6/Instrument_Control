import numpy as np
import commpy
from matplotlib import pyplot as plt

class Test_signals:

	@staticmethod
	def normalized_ofdm():

		# initial parameters
		guards = 100
		fft_size = 1024
		interpolated_size = fft_size*20
		sc_num = fft_size - guards*2

		
        # spectrum container
		sig_ofdm = np.zeros(fft_size, dtype=complex)
		

		# create bunch of random number to modulate
		r = np.random.randint(low=0, high=2, size=sc_num*4)
        
        
        # create modem with modulation index 16
		M = commpy.modulation.QAMModem(16)		
        
        
        # modulate bits
		modulated_bits = M.modulate(r)


        # place modulated data to spectrum container
		sig_ofdm[guards:int(fft_size/2)] = modulated_bits[0:int(sc_num/2)]
		sig_ofdm[int(fft_size/2) + 1:-guards + 1] = modulated_bits[int(sc_num/2):]

		
        # shift the spectrum and place zeros in the middle
		sig_ofdm_shifted = np.fft.fftshift(sig_ofdm)
		dummy1 = np.append(sig_ofdm_shifted[:int(fft_size/2)], np.zeros(interpolated_size - fft_size, dtype=complex))
		sig_ofdm_shifted = np.append(dummy1, sig_ofdm_shifted[int(fft_size/2):])
        
        
        # transite from frequency domain to time domain
		sig_ofdm_shifted_time = np.fft.ifft(sig_ofdm_shifted)

		
        # create carrier signals for I and Q data 
		fs = 25e6
		fc = 5e6
		t = np.arange(0, interpolated_size/fs, 1/fs)
		freqline = np.arange(0, fs - 1, fs/interpolated_size)
		Q_carr = -np.sin(2*np.pi*fc*t)
		I_carr = np.cos(2*np.pi*fc*t)
        
        
        # elementwise multiplication 
		real_part = np.multiply(sig_ofdm_shifted_time.real, I_carr)
		imag_part = np.multiply(sig_ofdm_shifted_time.imag, Q_carr)


        # summ real and imag parts
		sum_parts = real_part + imag_part

		# normalize 
		sum_parts /= np.max(np.abs(sum_parts))


		return sum_parts, freqline
		
    
    
	@staticmethod
	def normalized_two_sins():
        
		N = 10000
		fs = 25e6
		fc1 = 50e3
		fc2 = 100e3
		timeline = np.linspace(0, N/fs, N)
        
		sin1 = np.sin(2*np.pi*fc1*timeline)
		sin2 = np.sin(2*np.pi*fc2*timeline)
		sin_sum = sin1 + sin2
        
        
        # normalize 
		sin_sum /= np.max(np.abs(sin_sum))
        
		return sin_sum
    
        
	def normalized_sin():
        
		N = 25000
		fs = 25e6
		fc1 = 6.25e6
		timeline = np.linspace(0, N/fs, N)
        
		sin1 = np.sin(2*np.pi*fc1*timeline)
		        
        
        # normalize 
		sin1 /= np.max(np.abs(sin1))
		print(len(sin1))
        
		return sin1


if __name__ == '__main__':
    sig, f = Test_signals.normalized_ofdm()

    
    spec = np.fft.fft(sig)
    plt.scatter(spec.real, spec.imag)