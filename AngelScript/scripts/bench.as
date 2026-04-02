uint mix32(uint x) {
    x ^= x >> 16;
    x *= 0x7feb352d;
    x ^= x >> 15;
    x *= 0x846ca68b;
    x ^= x >> 16;
    return x;
}

uint64 mix_checksum(uint64 acc, uint64 value) {
    return acc ^ (value + 0x9e3779b9 + (acc << 6) + (acc >> 2));
}

uint64 fib_recursive_impl(int n) {
    if (n < 2) {
        return uint64(n);
    }
    return fib_recursive_impl(n - 1) + fib_recursive_impl(n - 2);
}

uint64 solve_queen_impl(int row, int n, int cols, int diag1, int diag2) {
    if (row == n) {
        return 1;
    }

    int available = ((1 << n) - 1) & ~(cols | diag1 | diag2);
    uint64 solutions = 0;
    while (available != 0) {
        int bit = available & -available;
        available -= bit;
        solutions += solve_queen_impl(row + 1, n, cols | bit, (diag1 | bit) << 1, (diag2 | bit) >> 1);
    }
    return solutions;
}

uint64 work_arithmetic_mix(int seed) {
    uint64 acc = 0;
    for (uint i = 0; i < 250000; ++i) {
        uint x = mix32(i + uint(seed * 131 + 17));
        acc = mix_checksum(acc, uint64(x) ^ (uint64(i) * 3) ^ (uint64(i) >> 2));
    }
    return acc;
}

uint64 work_fibonacci_loop(int seed) {
    uint64 a = uint64(seed);
    uint64 b = uint64(seed + 1);
    uint64 acc = 0;
    for (int i = 0; i < 250000; ++i) {
        uint64 c = a + b;
        a = b;
        b = c;
        acc ^= c;
    }
    return mix_checksum(acc, a ^ b);
}

uint64 work_fibonacci_recursive(int seed) {
    return fib_recursive_impl(31 + (seed & 1));
}

uint64 work_mandelbrot(int seed) {
    uint64 acc = 0;
    const int size = 96;
    double offset = double(seed & 7) * 0.0001;
    for (int y = 0; y < size; ++y) {
        for (int x = 0; x < size; ++x) {
            double cr = (double(x) / double(size)) * 3.0 - 2.0 + offset;
            double ci = (double(y) / double(size)) * 2.0 - 1.0 - offset;
            double zr = 0.0;
            double zi = 0.0;
            int iter = 0;
            while ((zr * zr + zi * zi) <= 4.0 && iter < 80) {
                double next_r = zr * zr - zi * zi + cr;
                zi = 2.0 * zr * zi + ci;
                zr = next_r;
                ++iter;
            }
            acc += uint64(iter);
        }
    }
    return acc;
}

uint64 work_primes_loop(int seed) {
    const int limit = 50000 + (seed & 15);
    array<int> is_prime(limit + 1);
    for (int i = 0; i <= limit; ++i) {
        is_prime[i] = 1;
    }
    is_prime[0] = 0;
    is_prime[1] = 0;
    for (int i = 2; i * i <= limit; ++i) {
        if (is_prime[i] != 0) {
            for (int j = i * i; j <= limit; j += i) {
                is_prime[j] = 0;
            }
        }
    }
    uint64 acc = 0;
    for (int i = 2; i <= limit; ++i) {
        if (is_prime[i] != 0) {
            acc += uint64(i);
        }
    }
    return acc;
}

uint64 work_queen(int seed) {
    return solve_queen_impl(0, 11 + (seed & 1), 0, 0, 0);
}

uint64 work_sort(int seed) {
    const int count = 2048;
    array<int> values(count);
    for (int i = 0; i < count; ++i) {
        values[i] = int(mix32(uint(i + seed * 17) + 1234) & 0x7fffffff);
    }

    for (int i = 1; i < count; ++i) {
        int value = values[i];
        int j = i - 1;
        while (j >= 0 && values[j] > value) {
            values[j + 1] = values[j];
            --j;
        }
        values[j + 1] = value;
    }

    uint64 acc = 0;
    for (int i = 0; i < count; i += 31) {
        acc = mix_checksum(acc, uint64(values[i]));
    }
    return acc;
}

uint64 benchmark_arithmetic_mix(int repeat) {
    uint64 acc = 0;
    for (int i = 0; i < repeat; ++i) { acc = mix_checksum(acc, work_arithmetic_mix(i)); }
    return acc;
}

uint64 benchmark_fibonacci_loop(int repeat) {
    uint64 acc = 0;
    for (int i = 0; i < repeat; ++i) { acc = mix_checksum(acc, work_fibonacci_loop(i)); }
    return acc;
}

uint64 benchmark_fibonacci_recursive(int repeat) {
    uint64 acc = 0;
    for (int i = 0; i < repeat; ++i) { acc = mix_checksum(acc, work_fibonacci_recursive(i)); }
    return acc;
}

uint64 benchmark_mandelbrot(int repeat) {
    uint64 acc = 0;
    for (int i = 0; i < repeat; ++i) { acc = mix_checksum(acc, work_mandelbrot(i)); }
    return acc;
}

uint64 benchmark_primes_loop(int repeat) {
    uint64 acc = 0;
    for (int i = 0; i < repeat; ++i) { acc = mix_checksum(acc, work_primes_loop(i)); }
    return acc;
}

uint64 benchmark_queen(int repeat) {
    uint64 acc = 0;
    for (int i = 0; i < repeat; ++i) { acc = mix_checksum(acc, work_queen(i)); }
    return acc;
}

uint64 benchmark_sort(int repeat) {
    uint64 acc = 0;
    for (int i = 0; i < repeat; ++i) { acc = mix_checksum(acc, work_sort(i)); }
    return acc;
}
