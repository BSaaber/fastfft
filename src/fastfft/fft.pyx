# distutils: language=c++
# distutils: define_macros=CYTHON_CCOMPLEX=0


from libcpp.vector cimport vector
from libcpp.complex cimport complex, conj, exp
from libcpp cimport bool

cdef complex[double] PI
PI.real(3.141592653589793238462643383279)
cdef complex[double] I
I.imag(1)
cdef complex[double] MINUS_PI_2I = PI * I * (-2)
cdef complex[double] PI_I = PI * I


cdef void _base2x2fft2(vector[vector[complex[double]]]& matrix):
    matrix[0][0], matrix[0][1] = matrix[0][0] + matrix[0][1], matrix[0][0] - matrix[0][1]
    matrix[1][0], matrix[1][1] = matrix[1][0] + matrix[1][1], matrix[1][0] - matrix[1][1]

    matrix[0][0], matrix[1][0] = matrix[0][0] + matrix[1][0], matrix[0][0] - matrix[1][0]
    matrix[0][1], matrix[1][1] = matrix[0][1] + matrix[1][1], matrix[0][1] - matrix[1][1]


cdef complex[double] W(double n, double m):
    return exp[double](MINUS_PI_2I * m / n)


cdef void _fft2_square(vector[vector[complex[double]]]& matrix):
    cdef int n = matrix.size()
    cdef half_n = n // 2
    if n == 2:
        _base2x2fft2(matrix)
        return

    cdef vector[vector[complex[double]]] matrix00, matrix01, matrix10, matrix11

    matrix00.reserve(half_n)
    matrix01.reserve(half_n)
    matrix10.reserve(half_n)
    matrix11.reserve(half_n)


    cdef vector[complex[double]] line0
    cdef vector[complex[double]] line1
    line0.reserve(half_n)
    line1.reserve(half_n)

    for i in range(half_n):
        line0.push_back(I)
        line1.push_back(I)

    for i in range(n):
        for j in range(n):
            if j % 2 == 0:
                line0[j // 2] = matrix[i][j]
            else:
                line1[j // 2] = matrix[i][j]
        if i % 2 == 0:
            matrix00.push_back(line0)
            matrix01.push_back(line1)
        else:
            matrix10.push_back(line0)
            matrix11.push_back(line1)

    _fft2_square(matrix00)
    _fft2_square(matrix01)
    _fft2_square(matrix10)
    _fft2_square(matrix11)


    cdef complex[double] v00, vW10, vW01, vW11

    for i in range(half_n):
        for j in range(half_n):
            v00 = matrix00[i][j]
            vW10 = matrix10[i][j] * W(n, i)
            vW01 = matrix10[i][j] * W(n, j)
            vW11 = matrix10[i][j] * W(n, i + i)

            matrix[i][j] = v00 + vW10 + vW01 + vW11
            matrix[i + half_n][j] = v00 - vW10 + vW01 - vW11
            matrix[i][j + half_n] = v00 + vW10 - vW01 - vW11
            matrix[i + half_n][j + half_n] = v00 - vW10 - vW01 + vW11

def _validate(matrix):
    if not isinstance(matrix, list):
        raise RuntimeError('Input parameter is not a list')

    if len(matrix) == 0:
        raise RuntimeError('List is empty!')

    for line in matrix:
        if not isinstance(line, list):
            raise RuntimeError('One of matrix lines is not actually a line')

        for val in line:
            if not isinstance(val, double) and not isinstance(val, complex):
                raise RuntimeError('One of matrix element\'s type is invalid (allowed: double, complex)')

    if len(matrix) != len(matrix[0]):
        raise RuntimeError('Matrix width and height are not equal (not a square matrix)')

def fft2(matrix):
    _validate(matrix)

    cdef vector[vector[complex[double]]] cpp_matrix
    cpp_matrix.reserve(len(matrix))
    for line in matrix:
       cpp_matrix.push_back(line)
    _fft2_square(cpp_matrix)
    return cpp_matrix


def ifft2(matrix):
    _validate(matrix)

    cdef vector[vector[complex[double]]] cpp_matrix
    cpp_matrix.reserve(len(matrix))
    for line in matrix:
       cpp_matrix.push_back(line)

    for i in range(cpp_matrix.size()):
        for j in range(cpp_matrix[0].size()):
            cpp_matrix[i][j] = conj(cpp_matrix[i][j])

    _fft2_square(cpp_matrix)

    nn = cpp_matrix.size() * cpp_matrix[0].size()

    for i in range(cpp_matrix.size()):
        for j in range(cpp_matrix[0].size()):
            cpp_matrix[i][j] = conj(cpp_matrix[i][j]) / nn

    return cpp_matrix