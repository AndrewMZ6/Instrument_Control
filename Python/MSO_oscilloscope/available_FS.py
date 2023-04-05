

fixed_Fs = 1e9   # 1G Sa/s


Fs_div_list = list(range(226))

for N in Fs_div_list:
    if N <= 2:
        Fs = fixed_Fs/pow(2, N)
        print(f'Fs = {Fs/1e6:.2f} MHz, N = {N}')
    else:
        Fs = fixed_Fs/((N - 2)*8)
        print(f'Fs = {Fs/1e6:.2f} MHz, N = {N}')