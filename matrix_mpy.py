# this file will be the reference to verify the results of matrix mpy
# input: 2 random 8 by 8 matrix

import numpy as np

# Generate random matrix

matrixOne_file = "matrix1.txt"
matrixTwo_file = "matrix2.txt"

matrixOne = np.random.randint(0, 255, size=(8, 8))
with open(matrixOne_file, "w") as f:
    #print(matrixOne.flatten())
    f.write("\n".join(str(v) for v in matrixOne.flatten()))

matrixTwo = np.random.randint(0, 255, size=(8, 8))
with open(matrixTwo_file, "w") as f:
    #print(matrixTwo.flatten())
    f.write("\n".join(str(v) for v in matrixTwo.flatten()))

# Calculate reference matrix
result = np.matmul(matrixOne, matrixTwo)
#print(result)

# Output text file of inputs and results

errors = []

def verify(matrixRTL, matrixPy):
    for (i, j), elemRTL in np.ndenumerate(matrixRTL):
        elemPy = matrixPy[i, j]
        if elemRTL != elemPy:
            errors.append(f"[{i},{j}] RTL is {elemRTL} but PY is {elemPy}")

    print(errors)
