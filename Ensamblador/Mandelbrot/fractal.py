import cmath
MAX_ITER = 79

def compute(c):
    z = c
    n = 0
    while (z.real < 2 and z.imag < 2) and n < MAX_ITER:
        z = z*z + c
        n += 1
    return n
