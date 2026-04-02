options gen2

def mix32(x : uint) : uint {
    var y = x
    y = y ^ (y >> uint(16))
    y = y * 0x7feb352du
    y = y ^ (y >> uint(15))
    y = y * 0x846ca68bu
    y = y ^ (y >> uint(16))
    return y
}

def mix_checksum(acc : uint64; value : uint64) : uint64 {
    return acc ^ (value + uint64(0x9e3779b9) + (acc << uint64(6)) + (acc >> uint64(2)))
}

def fib_recursive_impl(n : int) : uint64 {
    if (n < 2) {
        return uint64(n)
    }
    return fib_recursive_impl(n - 1) + fib_recursive_impl(n - 2)
}

def solve_queen_impl(row : int; n : int; cols : int; diag1 : int; diag2 : int) : uint64 {
    if (row == n) {
        return uint64(1)
    }

    var available = ((1 << n) - 1) & ~(cols | diag1 | diag2)
    var solutions : uint64 = uint64(0)
    while (available != 0) {
        let bit = available & -available
        available -= bit
        solutions += solve_queen_impl(row + 1, n, cols | bit, (diag1 | bit) << 1, (diag2 | bit) >> 1)
    }
    return solutions
}

def work_arithmetic_mix(seed : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(250000)) {
        let ii = uint64(i)
        let x = mix32(uint(i + seed * 131) + uint(17))
        acc = mix_checksum(acc, uint64(x) ^ (ii * uint64(3)) ^ (ii >> uint64(2)))
    }
    return acc
}

def work_fibonacci_loop(seed : int) : uint64 {
    var a : uint64 = uint64(seed)
    var b : uint64 = uint64(seed + 1)
    var acc : uint64 = uint64(0)
    for (_ in range(250000)) {
        let c = a + b
        a = b
        b = c
        acc ^= c
    }
    return mix_checksum(acc, a ^ b)
}

def work_fibonacci_recursive(seed : int) : uint64 {
    return fib_recursive_impl(31 + (seed & 1))
}

def work_mandelbrot(seed : int) : uint64 {
    let size = 96
    var acc : uint64 = uint64(0)
    let offset = double(seed & 7) * 0.0001lf
    for (y in range(size)) {
        for (x in range(size)) {
            let cr = (double(x) / double(size)) * 3.0lf - 2.0lf + offset
            let ci = (double(y) / double(size)) * 2.0lf - 1.0lf - offset
            var zr : double = 0.0lf
            var zi : double = 0.0lf
            var iter = 0
            while ((zr * zr + zi * zi) <= 4.0lf && iter < 80) {
                let next_r = zr * zr - zi * zi + cr
                zi = 2.0lf * zr * zi + ci
                zr = next_r
                iter ++
            }
            acc += uint64(iter)
        }
    }
    return acc
}

def work_primes_loop(seed : int) : uint64 {
    let limit = 50000 + (seed & 15)
    var is_prime : array<int>
    resize(is_prime, limit + 1)
    for (i in range(limit + 1)) {
        is_prime[i] = 1
    }
    is_prime[0] = 0
    is_prime[1] = 0
    var i = 2
    while (i * i <= limit) {
        if (is_prime[i] != 0) {
            var j = i * i
            while (j <= limit) {
                is_prime[j] = 0
                j += i
            }
        }
        i ++
    }

    var acc : uint64 = uint64(0)
    for (n in range(2, limit + 1)) {
        if (is_prime[n] != 0) {
            acc += uint64(n)
        }
    }
    return acc
}

def work_queen(seed : int) : uint64 {
    return solve_queen_impl(0, 11 + (seed & 1), 0, 0, 0)
}

def work_sort(seed : int) : uint64 {
    let count = 2048
    var values : array<int>
    resize(values, count)
    for (i in range(count)) {
        values[i] = int(mix32(uint(i + seed * 17) + uint(1234)) & uint(0x7fffffff))
    }

    for (i in range(1, count)) {
        let value = values[i]
        var j = i - 1
        while (j >= 0 && values[j] > value) {
            values[j + 1] = values[j]
            j --
        }
        values[j + 1] = value
    }

    var acc : uint64 = uint64(0)
    var i = 0
    while (i < count) {
        acc = mix_checksum(acc, uint64(values[i]))
        i += 31
    }
    return acc
}

[export]
def benchmark_arithmetic_mix(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_arithmetic_mix(i))
    }
    return acc
}

[export]
def benchmark_fibonacci_loop(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_fibonacci_loop(i))
    }
    return acc
}

[export]
def benchmark_fibonacci_recursive(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_fibonacci_recursive(i))
    }
    return acc
}

[export]
def benchmark_mandelbrot(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_mandelbrot(i))
    }
    return acc
}

[export]
def benchmark_primes_loop(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_primes_loop(i))
    }
    return acc
}

[export]
def benchmark_queen(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_queen(i))
    }
    return acc
}

[export]
def benchmark_sort(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_sort(i))
    }
    return acc
}
