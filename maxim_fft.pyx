# distutils: language=c++
# distutils: define_macros=CYTHON_CCOMPLEX=0


from libcpp.vector cimport vector
from libcpp.complex cimport complex, polar, conj

cdef double PI = 3.141592653589793238462643383279

cdef print_vector(vector[complex[double]]& v):
    print("==================")
    for i in range(v.size()):
        print(f'        {v[i]}')
    print("==================")

# expecting amount to be 2 ** x
cdef vector[complex[double]] slice_vector(vector[complex[double]]& v, int start, int step):
    cdef vector[complex[double]] res
    for i in range(start, v.size(), step):
        res.push_back(v[i])
    return res
cdef _fft(vector[complex[double]]& v):
    if v.size() <= 1:
        return

    cdef vector[complex[double]] even = slice_vector(v, 0, 2)
    cdef vector[complex[double]] odd = slice_vector(v, 1, 2)
    print_vector(even)
    print_vector(odd)
    _fft(even)
    _fft(odd)
    cdef complex[double] t
    for i in range(v.size() // 2):
        t = polar[double](1.0, -2 * PI * i / v.size()) * odd[i]
        v[i] = even[i] + t
        v[i + v.size() // 2] = even[i] - t

cdef long_fft(vector[complex[double]]& v):
    cdef vector[complex[double]] res
    cdef complex[double] sum
    for i in range(v.size()):
        sum.real(0)
        sum.imag(0)
        for j in range(v.size()):
            sum += v[j] * polar[double](1.0, -2 * PI * i * j / v.size())
        res.push_back(sum)

    for i in range(v.size()):
        v[i] = res[i]


cdef fft(vector[complex[double]]& v):
    _fft(v)

cdef ifft(vector[complex[double]]& v):
    for i in range(v.size()):
        v[i] = conj(v[i])
    fft(v)
    for i in range(v.size()):
        v[i] = conj(v[i])
        v[i] /= v.size()

cdef my_foo():
    cdef vector[complex[double]] v
    v.reserve(8)
    cdef complex[double] myvar
    for i in range(1, 9, 1):
        myvar.real(i)
        myvar.imag(0)
        v.push_back(myvar)

    for i in range(v.size()):
        print(v[i].real(), v[i].imag())

    print("long way")
    fft(v)

    print('------')

    for i in range(v.size()):
        print(v[i].real(), v[i].imag())

    # print('short way')
    #
    # cdef vector[complex[double]] vv
    # for i in range(1, 9, 1):
    #     myvar.real(i)
    #     myvar.imag(0)
    #     vv.push_back(myvar)
    #
    # for i in range(vv.size()):
    #     print(vv[i].real(), vv[i].imag())
    #
    # print("long way")
    # long_fft(vv)

    # ifft(v)
    #
    # print('------')
    #
    # for i in range(v.size()):
    #     print(v[i].real(), v[i].imag())

my_foo()

print("maxims fft module imported")