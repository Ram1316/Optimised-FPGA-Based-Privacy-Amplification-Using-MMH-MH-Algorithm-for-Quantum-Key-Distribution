import numpy as np
import matplotlib.pyplot as plt
from numpy.fft import fft, ifft

# Helper functions for Number Theoretic Transform (NTT)
def NTT(x):
    # Ensure x is an array
    x = np.asarray(x)
    if x.ndim == 0:
        x = np.array([x])  # Convert scalar to array
    return fft(x)

def INTT(x):
    x = np.asarray(x)
    return ifft(x).real.astype(int)

def mod(a, m):
    return a % m

# Function for MMH-MH algorithm
def MMH_MH(x, a, b, c, γ, β, α):
    # Constants
    k = len(x)
    p = (2**γ) - 1

    # Step 1: Split data
    x_split = np.array_split(x, k)
    a_split = np.array_split(a, k)

    # Step 3: Check if all xi = 2^γ - 1
    if all(np.all(xi == p) for xi in x_split):
        return "Reload data xi"
    
    y = np.zeros(k, dtype=np.int64)
    ntt_results = []
    intt_results = []

    # Step 6-9: Perform the NTT, multiplication, and INTT for each xi and ai
    for i in range(k):
        xi_ntt = NTT(x_split[i])
        ai_ntt = NTT(a_split[i])
        y_ntt = xi_ntt * ai_ntt
        y[i] = np.sum(INTT(y_ntt))  # Use sum or mean to reduce array to scalar
        
        # Store results for graphing
        ntt_results.append(np.abs(xi_ntt))
        intt_results.append(np.abs(y_ntt))

    # Step 10: Compute MMH function
    y_total = sum(y) % p

    # Step 11-12: Compute z using NTT and INTT
    z_ntt = NTT(y_total) * NTT(b)
    z = INTT(z_ntt)

    # Step 13: Apply MH function
    z = ((z + c) % 2**α) // 2**(α - β)

    # Plot graphs
    plot_graphs(x_split, y, ntt_results, intt_results, z)

    return z

# Function to plot relevant graphs
def plot_graphs(x_split, y, ntt_results, intt_results, z):
    k = len(x_split)
    
    # Plot original x vs processed y (after MMH)
    plt.figure(figsize=(12, 6))
    plt.subplot(1, 2, 1)
    plt.plot(range(k), [np.mean(xi) for xi in x_split], label='Original Data (x)')
    plt.plot(range(k), y, label='Processed Data (y)', linestyle='--')
    plt.title('Original Data vs Processed Data (MMH)')
    plt.xlabel('Index')
    plt.ylabel('Value')
    plt.legend()
    
    # Plot NTT and INTT results for each xi
    plt.subplot(1, 2, 2)
    plt.plot(range(k), ntt_results, label='NTT Results')
    plt.plot(range(k), intt_results, label='INTT Results', linestyle='--')
    plt.title('NTT vs INTT for x')
    plt.xlabel('Index')
    plt.ylabel('Value')
    plt.legend()
    
    plt.tight_layout()
    plt.show()

    # Plot the final z values
    plt.figure()
    plt.plot(np.abs(z), label='Final Output (z)')
    plt.title('Final Output z after MH function')
    plt.xlabel('Index')
    plt.ylabel('Value')
    plt.legend()
    plt.show()

# Example with larger inputs and adjusted parameters
x = np.random.randint(0, 2**12, size=32)  # Larger data size
a = np.random.randint(0, 2**12, size=32)  # Random seeds
b = np.random.randint(1, 2**12)           # Random constant b
c = np.random.randint(0, 2**12)           # Random constant c
γ = 12  # Gamma increased
β = 8   # Adjust Beta
α = 16  # Adjust Alpha

# Run the MMH-MH algorithm with larger data
result = MMH_MH(x, a, b, c, γ, β, α)
print("Output z:", result)

