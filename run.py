import maxim_fft
import time
import random
import numpy as np
my_matrix = list()

for i in range(2 ** 3):
    l = list()
    for j in range(2 ** 2):
        l.append(random.randint(1, 100000))
    my_matrix.append(l)

#my_matrix = [[1,22,3,4],[5,12,7,9]]


# print('input:')
# print(my_matrix)

t0 = time.time()
res = maxim_fft.fft2(my_matrix)
t1 = time.time() - t0
print('my code:')
print(t1)
# print(res)

t0 = time.time()
res = np.fft.fft2(my_matrix)
t1 = time.time() - t0
print('np code:')
print(t1)
# print(res)

t0 = time.time()
res = maxim_fft.fft2(my_matrix, True)
t1 = time.time() - t0
print('my rows columns code:')
print(t1)
# print(res)


#print('output:')
#print(res)
