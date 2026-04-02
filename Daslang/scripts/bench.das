options gen2
require benchmark

[export]
def benchmark_dictionary(repeat : int) {
    for (_ in range(repeat)) {
        bench_dictionary()
    }
}

[export]
def benchmark_exp_loop(repeat : int) {
    for (_ in range(repeat)) {
        bench_exp_loop()
    }
}

[export]
def benchmark_fibonacci_loop(repeat : int) {
    for (_ in range(repeat)) {
        bench_fibonacci_loop()
    }
}

[export]
def benchmark_fibonacci_recursive(repeat : int) {
    for (_ in range(repeat)) {
        bench_fibonacci_recursive()
    }
}

[export]
def benchmark_float2string(repeat : int) {
    for (_ in range(repeat)) {
        bench_float2string()
    }
}

[export]
def benchmark_mandelbrot(repeat : int) {
    for (_ in range(repeat)) {
        bench_mandelbrot()
    }
}

[export]
def benchmark_n_bodies(repeat : int) {
    for (_ in range(repeat)) {
        bench_n_bodies()
    }
}

[export]
def benchmark_native_loop(repeat : int) {
    for (_ in range(repeat)) {
        bench_native_loop()
    }
}

[export]
def benchmark_particles_kinematics(repeat : int) {
    for (_ in range(repeat)) {
        bench_particles_kinematics()
    }
}

[export]
def benchmark_primes_loop(repeat : int) {
    for (_ in range(repeat)) {
        bench_primes_loop()
    }
}

[export]
def benchmark_queen(repeat : int) {
    for (_ in range(repeat)) {
        bench_queen()
    }
}

[export]
def benchmark_sha256(repeat : int) {
    for (_ in range(repeat)) {
        bench_sha256()
    }
}

[export]
def benchmark_sort(repeat : int) {
    for (_ in range(repeat)) {
        bench_sort()
    }
}

[export]
def benchmark_spectral_norm(repeat : int) {
    for (_ in range(repeat)) {
        bench_spectral_norm()
    }
}

[export]
def benchmark_string2float(repeat : int) {
    for (_ in range(repeat)) {
        bench_string2float()
    }
}

[export]
def benchmark_tree(repeat : int) {
    for (_ in range(repeat)) {
        bench_tree()
    }
}
