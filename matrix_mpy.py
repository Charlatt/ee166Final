# this file will be the reference to verify the results of matrix mpy
# input: 2 random 8 by 8 matrix

import numpy as np
import argparse

# Generate random matrix

def calculate_result(matrix1, matrix2):
    return np.matmul(matrix1, matrix2, dtype=np.uint8)

def write_random_matrix(filename):
    matrixOne = np.random.randint(0, 255, size=(8, 8))
    with open(filename, "w") as f:
        f.write("\n".join(f"{v:x}" for v in matrixOne.flatten()))

def file_to_matrix(filename):
    try:
        with open(filename) as f:
            values = []
            for line in f:
                values.append(int(line, base=16))

            assert len(values) == 64

            return np.array(values, dtype=np.uint8).reshape(8, 8)
    except:
        exit(f"Couldn't open file '{filename}'")


def verify(matrixRTL, matrixPy):
    errors = []
    for (i, j), elemRTL in np.ndenumerate(matrixRTL):
        elemPy = matrixPy[i, j] # truncate to 8 bits
        if elemRTL != elemPy:
            errors.append(f"[{i},{j}] RTL is {elemRTL} but PY is {elemPy}")

    print("\n".join(errors))

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--generate", action="store_true", default=False)
    parser.add_argument("--verify", action="store_true", default=False)
    parser.add_argument("--matrix-a", "-a", default="matrix1.txt", help="Filename for input matrix a")
    parser.add_argument("--matrix-b", "-b", default="matrix2.txt", help="Filename for input matrix b")
    parser.add_argument("--result-matrix", "-c", default="output.txt", help="Filename for result matrix to verify")

    args = parser.parse_args()

    if args.generate:
        print("Generating files...")
        write_random_matrix(args.matrix_a)
        write_random_matrix(args.matrix_b)
    elif args.verify:
        matrix1 = file_to_matrix(args.matrix_a)
        matrix2 = file_to_matrix(args.matrix_b)
        matrix_to_test = file_to_matrix(args.result_matrix)
        result = calculate_result(matrix1, matrix2)
        verify(matrix_to_test, result)
        c = 0
        a = [0x36, 0x79, 0x43, 0x5d, 0xcc, 0xf7, 0xf1, 0x47]
        b = [0x55, 0x75, 0x9b, 0xe9, 0x82, 0x5d, 0xfa, 0xc0]
        for i in range(7, -1, -1):
            c = (((a[i] * b[i]) & (2**8 - 1)) + c) & (2**8 - 1)
        print(c)
    else:
        parser.print_help()
