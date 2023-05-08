# distutils: language=c++
# distutils: define_macros=CYTHON_CCOMPLEX=0


from libcpp.vector cimport vector
from libcpp.complex cimport complex, polar, conj
from libcpp cimport bool

cdef double PI = 3.141592653589793238462643383279

cdef print_vector(vector[complex[double]]& v):
    print("==================")
    for i in range(v.size()):
        print(f'        {v[i]}')
    print("==================")


cdef print_matrix(vector[vector[complex[double]]]& matrix):
    for i in range(matrix.size()):
        a = ""
        for j in range(matrix[0].size()):
            a += f"{matrix[i][j]}  "
        print(a)

# expecting amount to be 2 ** x
cdef vector[complex[double]] slice_vector(vector[complex[double]]& v, int start, int step):
    cdef vector[complex[double]] res
    for i in range(start, v.size(), step):
        res.push_back(v[i])
    return res

cdef _fft(vector[complex[double]]& v, bool skip_even = False, bool skip_odd = False):
    if v.size() <= 1:
        return

    cdef vector[complex[double]] even
    if not skip_even:
        even = slice_vector(v, 0, 2)
        _fft(even)
    cdef vector[complex[double]] odd
    if not skip_odd:
        odd = slice_vector(v, 1, 2)
        _fft(odd)
    cdef complex[double] t
    for i in range(v.size() // 2):
        if not skip_odd:
            t = polar[double](1.0, -2 * PI * i / v.size()) * odd[i]
        if not skip_odd and not skip_even:
            v[i] = even[i] + t
            v[i + v.size() // 2] = even[i] - t
        elif skip_odd:
            v[i] = even[i]
        elif skip_even:
            v[i] = t


cdef vector[complex[double]] fft(vector[complex[double]]& v):
    cdef vector[complex[double]] res
    res = v
    _fft(res)
    return res

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

# cdef ifft(vector[complex[double]]& v):
#     for i in range(v.size()):
#         v[i] = conj(v[i])
#     fft(v)
#     for i in range(v.size()):
#         v[i] = conj(v[i])
#         v[i] /= v.size()


cdef _fft2(vector[vector[complex[double]]]& matrix):

    # create transposed matrix
    cdef vector[vector[complex[double]]] matrix_transposed
    cdef vector[complex[double]] v
    for i in range(matrix[0].size()):
        v.clear()
        for j in range(matrix.size()):
            v.push_back(matrix[j][i])
        matrix_transposed.push_back(v)


    # fft transposed lines (original rows)
    for i in range(matrix_transposed.size()):
        _fft(matrix_transposed[i])


    # copy back to original matrix
    for i in range(matrix_transposed.size()):
        for j in range(matrix_transposed[0].size()):
            matrix[j][i] = matrix_transposed[i][j]


    # create copyies for even only and odd only rows
    cdef vector[vector[complex[double]]] even_matrix
    cdef vector[vector[complex[double]]] odd_matrix
    even_matrix = matrix
    odd_matrix = matrix

    # fft lines, skipping right part of matrix
    for i in range(matrix.size()):
        _fft(even_matrix[i], False, True)
        _fft(odd_matrix[i], True, False)


    # smart sum
    for i in range(matrix.size()):
        for j in range(matrix[0].size()):
            if j < matrix[0].size() // 2:
                matrix[i][j] = even_matrix[i][j] + odd_matrix[i][j]
            else:
                matrix[i][j] = even_matrix[i][j - matrix[0].size() // 2] - odd_matrix[i][j - matrix[0].size() // 2]

    print_matrix(matrix)

def fft2(matrix):
    if len(matrix) == 0:
        return
    if len(matrix[0]) == 0:
        return
    need_transpose = len(matrix) > len(matrix[0])
    if need_transpose:
        matrix = list(map(list, zip(*matrix)))


    # converting to cpp
    cdef vector[vector[complex[double]]] cpp_matrix
    cpp_matrix.reserve(len(matrix))
    cdef vector[complex[double]] cpp_line
    for i in matrix:
        cpp_line.clear()
        cpp_line.reserve(len(i))
        for j in i:
            cpp_line.push_back(j)
        cpp_matrix.push_back(cpp_line)

    # do the trick
    _fft2(cpp_matrix)

    # convert back to python and return
    res = list()
    for i in range(len(matrix)):
        l = list()
        for j in range(len(matrix[0])):
                l.append(cpp_matrix[i][j])
        res.append(l)

    if need_transpose:
        matrix = list(map(list, zip(*matrix)))

    return res
