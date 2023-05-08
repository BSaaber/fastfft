import maxim_fft
import time
import random
import numpy as np
my_matrix = list()

for i in range(2 ** 10):
    l = list()
    for j in range(2 ** 9):
        l.append(random.randint(1, 100000))
    my_matrix.append(l)
#print('input:')
#print(my_matrix)

t0 = time.time()
res = maxim_fft.fft2(my_matrix)
t1 = time.time() - t0
print('my code:')
print(t1)

t0 = time.time()
res = np.fft.fft2(my_matrix)
t1 = time.time() - t0
print('np code:')
print(t1)


#print('output:')
#print(res)
