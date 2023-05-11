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


cdef void base2x2fft2(vector[vector[complex[double]]]& matrix):
    matrix[0][0], matrix[0][1] = matrix[0][0] + matrix[0][1], matrix[0][0] - matrix[0][1]
    matrix[1][0], matrix[1][1] = matrix[1][0] + matrix[1][1], matrix[1][0] - matrix[1][1]

    matrix[0][0], matrix[1][0] = matrix[0][0] + matrix[1][0], matrix[0][0] - matrix[1][0]
    matrix[0][1], matrix[1][1] = matrix[0][1] + matrix[1][1], matrix[0][1] - matrix[1][1]


cdef complex[double] W_MINUS_PI_2I(double n, double m):
    return exp[double](MINUS_PI_2I * m / n)


cdef void fft2_square(vector[vector[complex[double]]]& matrix):
    cdef int n = matrix.size()
    cdef half_n = n // 2
    if n == 2:
        base2x2fft2(matrix)
        return

    cdef vector[vector[complex[double]]] matrix00, matrix01, matrix10, matrix11

    matrix00.reserve(half_n)
    matrix01.reserve(half_n)
    matrix10.reserve(half_n)
    matrix11.reserve(half_n)


    cdef vector[complex[double]] line0
    cdef vector[complex[double]] line1
    # todo - redo
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

    fft2_square(matrix00)
    fft2_square(matrix01)
    fft2_square(matrix10)
    fft2_square(matrix11)


    cdef complex[double] v00, vW10, vW01, vW11

    for i in range(half_n):
        for j in range(half_n):
            v00 = matrix00[i][j]
            vW10 = matrix10[i][j] * W_MINUS_PI_2I(n, i)
            vW01 = matrix10[i][j] * W_MINUS_PI_2I(n, j)
            vW11 = matrix10[i][j] * W_MINUS_PI_2I(n, i + i)

            matrix[i][j] = v00 + vW10 + vW01 + vW11
            matrix[i + half_n][j] = v00 - vW10 + vW01 - vW11
            matrix[i][j + half_n] = v00 + vW10 - vW01 - vW11
            matrix[i + half_n][j + half_n] = v00 - vW10 - vW01 + vW11


def py_fft2_square(matrix):
    cdef vector[vector[complex[double]]] cpp_matrix
    cpp_matrix.reserve(len(matrix))
    for line in matrix:
       cpp_matrix.push_back(line)
    fft2_square(cpp_matrix)
    return cpp_matrix
