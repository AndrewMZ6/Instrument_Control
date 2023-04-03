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
		r = np.random.randint(low=0, high=16, size=sc_num)
		M = commpy.modulation.QAMModem(16)

		
		modulated_bits = np.zeros(sc_num, dtype=complex)
		for i in range(len(modulated_bits)):
			modulated_bits[i] = Test_signals.my_qam16mod(r[i], M)[0]


		sig_ofdm[guards:int(fft_size/2)] = modulated_bits[0:int(sc_num/2)]
		sig_ofdm[int(fft_size/2) + 1:-guards + 1] = modulated_bits[int(sc_num/2):]

		sig_ofdm_shifted = np.fft.fftshift(sig_ofdm)
		dummy1 = np.append(sig_ofdm_shifted[:int(fft_size/2)], np.zeros(interpolated_size - fft_size, dtype=complex))
		dummy2 = np.append(dummy1, sig_ofdm_shifted[int(fft_size/2) + 1:])
		#sig_ofdm_shifted = np.concatenate(sig_ofdm_shifted[:int(fft_size/2)], np.zeros(interpolated_size - fft_size, dtype=complex), sig_ofdm_shifted[int(fft_size/2) + 1:])
		sig_ofdm_shifted = dummy2

		sig_ofdm_shifted_time = np.fft.ifft(sig_ofdm_shifted)

		
		fs = 50e6
		fc = 10e6
		t = np.arange(0, (interpolated_size - 1)/fs, 1/fs)
		freqline = np.arange(0, fs - 1, fs/interpolated_size)

		Q_carr = -np.sin(2*np.pi*fc*t)
		I_carr = np.cos(2*np.pi*fc*t)

		real_part = np.multiply(sig_ofdm_shifted_time.real, I_carr)
		imag_part = np.multiply(sig_ofdm_shifted_time.imag, Q_carr)

		sum_parts = real_part + imag_part

		# normalize 
		sum_parts /= np.max(np.abs(sum_parts))


		return sum_parts, freqline
		


	def my_qam16mod(number, modem):

		# let's say the input number is 13
		# the binary representation of 13 is '1101' string
		number_bin = np.binary_repr(number)

		# convert the string to list  ['1', '1', '0', '1']
		number_bin_list = list(number_bin)

		# convert the list of characters into the list of integers array([1, 1, 0, 1])
		number_int_np_array = np.array(number_bin_list, dtype=int)

		# modulate the number with modem
		modulated_number = modem.modulate(number_int_np_array)

		return modulated_number
    
    
	@staticmethod
	def two_sins():
        
		N = 10000
		fs = 20e6
		fc1 = 5e4
		fc2 = 10e4
		timeline = np.linspace(0, N/fs, N)
        
		sin1 = np.sin(2*np.pi*fc1*timeline)
		sin2 = np.sin(2*np.pi*fc2*timeline)
		sin_sum = sin1 + sin2
        
		return sin_sum
        


if __name__ == '__main__':
# 	sig, f = Test_signals.normalized_ofdm()
# 	print(f'sig type = {type(sig)}')
# 	print(f'sig length = {len(sig)}')
# 	print(f'sig[:10] = {sig[:10]}')

# 	fig, ax = plt.subplots()
# 	fig2, ax2 = plt.subplots()
# 	ax.plot(sig)
# 	ax2.plot(f, np.abs(np.fft.fft(sig)))
# 	plt.show()

    plt.plot(Test_signals.two_sins())