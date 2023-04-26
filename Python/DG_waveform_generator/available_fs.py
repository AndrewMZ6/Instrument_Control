N_list = list(range(20))


for N in N_list:

	if N <= 2:

		Fs = 1e9/(pow(2, N))
		print(f'Fs = {Fs:.2f}, N = {N}       (IF)')

	else:
		Fs = 1e9/((N-2)*8)
		print(f'Fs = {Fs:.2f}, N = {N}       (ELSE)')