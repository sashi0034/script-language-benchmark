void benchmark_dictionary(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_dictionary(); }
}

void benchmark_exp_loop(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_exp_loop(); }
}

void benchmark_fibonacci_loop(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_fibonacci_loop(); }
}

void benchmark_fibonacci_recursive(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_fibonacci_recursive(); }
}

void benchmark_float2string(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_float2string(); }
}

void benchmark_mandelbrot(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_mandelbrot(); }
}

void benchmark_n_bodies(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_n_bodies(); }
}

void benchmark_native_loop(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_native_loop(); }
}

void benchmark_particles_kinematics(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_particles_kinematics(); }
}

void benchmark_primes_loop(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_primes_loop(); }
}

void benchmark_queen(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_queen(); }
}

void benchmark_sha256(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_sha256(); }
}

void benchmark_sort(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_sort(); }
}

void benchmark_spectral_norm(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_spectral_norm(); }
}

void benchmark_string2float(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_string2float(); }
}

void benchmark_tree(int repeat) {
    for (int i = 0; i < repeat; ++i) { bench_tree(); }
}
