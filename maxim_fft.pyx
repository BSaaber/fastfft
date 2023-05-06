# distutils: language=c++


from libcpp.vector cimport vector

def primes(unsigned int nb_primes):
    cdef int n, i
    cdef vector[int] p
    p.reserve(nb_primes)  # allocate memory for 'nb_primes' elements.

    n = 2
    while p.size() < nb_primes:  # size() for vectors is similar to len()
        for i in p:
            if n % i == 0:
                break
        else:
            p.push_back(n)  # push_back is similar to append()
        n += 1

    # If possible, C values and C++ objects are automatically
    # converted to Python objects at need.
    return p  # so here, the vector will be copied into a Python list.


# cdef extern from "Numeric" namespace "valarray":
#     cdef cppclass valarray:
#         pass
#
# cdef valarray[int] my_valarray

cdef extern from "<valarray>" namespace "std":
    cdef cppclass valarray[T]:
        valarray()
        valarray(int)  # constructor: empty constructor
        T& operator[](int)  # get/set element

cdef extern from "<complex>" namespace "std":
    cdef cppclass complex[T]:
        complex() except +
        complex(T&, T&) except +
        T real()
        T imag()

# cdef extern from "complex.h":
#     pass

def my_foo():
    my_complex_ptr = new complex[double](5.0, 5.0)
    try:
        print(my_complex_ptr.real())
    finally:
        del my_complex_ptr

    cdef valarray[complex] complex_v

    complex_v = valarray[complex](6)

    print("ok")

cdef valarray[int] v
# cdef complex[double] my_complex
# print(my_complex.real)

# print(my_complex_ptr.real())
#my_complex = new complex[double]()
v = valarray[int](6)
for i in range(5):
    v[i] = 1

print(v[1])
#print(v)

my_foo()

print("maxims fft module imported")
#print(primes(25))