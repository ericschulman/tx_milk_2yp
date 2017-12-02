import numpy as np
import matplotlib.pyplot as plt
import math

# draw vertical line from (70,100) to (70, 250)
plt.plot([70, 70], [100, 250], 'k-', lw=2)

# draw diagonal line from (70, 90) to (90, 200)
plt.plot([70, 90], [90, 200], 'k-')

plt.show()

if __name__ == "__main__":