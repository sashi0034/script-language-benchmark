#pragma once

#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <stdexcept>
#include <string>
#include <string_view>
#include <unordered_map>
#include <vector>

namespace slc {

inline volatile std::uint64_t g_sink = 0;

inline std::uint64_t splitmix64(std::uint64_t x) {
    x += 0x9e3779b97f4a7c15ULL;
    x = (x ^ (x >> 30U)) * 0xbf58476d1ce4e5b9ULL;
    x = (x ^ (x >> 27U)) * 0x94d049bb133111ebULL;
    return x ^ (x >> 31U);
}

inline void consume(std::uint64_t value) {
    g_sink ^= value + 0x9e3779b97f4a7c15ULL + (g_sink << 6U) + (g_sink >> 2U);
}

inline void bench_dictionary_native() {
    std::unordered_map<int, int> map;
    map.reserve(4096);
    std::uint64_t acc = 0;
    for (int i = 0; i < 3000; ++i) {
        const int key = static_cast<int>(splitmix64(static_cast<std::uint64_t>(i)) & 4095ULL);
        map[key] = i ^ (key << 1);
    }
    for (int i = 0; i < 3000; ++i) {
        const int key = static_cast<int>(splitmix64(static_cast<std::uint64_t>(i + 7000)) & 4095ULL);
        auto it = map.find(key);
        if (it != map.end()) {
            acc += static_cast<std::uint64_t>(it->second);
        }
    }
    consume(acc ^ static_cast<std::uint64_t>(map.size()));
}

inline void bench_exp_loop_native() {
    double sum = 0.0;
    for (int i = 1; i <= 40000; ++i) {
        const double x = static_cast<double>((i % 2048) + 1) * 0.00075;
        sum += std::exp(x);
    }
    consume(static_cast<std::uint64_t>(sum * 1000.0));
}

inline void bench_fibonacci_loop_native() {
    std::uint64_t a = 0;
    std::uint64_t b = 1;
    std::uint64_t acc = 0;
    for (int i = 0; i < 250000; ++i) {
        const std::uint64_t c = a + b;
        a = b;
        b = c;
        acc ^= c;
    }
    consume(acc ^ a ^ b);
}

inline std::uint64_t fib_recursive(int n) {
    if (n < 2) {
        return static_cast<std::uint64_t>(n);
    }
    return fib_recursive(n - 1) + fib_recursive(n - 2);
}

inline void bench_fibonacci_recursive_native() {
    consume(fib_recursive(31));
}

inline void bench_float2string_native() {
    std::uint64_t acc = 0;
    std::array<char, 64> buffer{};
    for (int i = 0; i < 12000; ++i) {
        const double value = std::sin(static_cast<double>(i) * 0.01) * 10000.0;
        const int written = std::snprintf(buffer.data(), buffer.size(), "%.9f", value);
        acc += static_cast<std::uint64_t>(written > 0 ? written : 0);
        acc ^= static_cast<std::uint64_t>(buffer[0]);
    }
    consume(acc);
}

inline void bench_mandelbrot_native() {
    std::uint64_t acc = 0;
    constexpr int size = 96;
    for (int y = 0; y < size; ++y) {
        for (int x = 0; x < size; ++x) {
            const double cr = (static_cast<double>(x) / size) * 3.0 - 2.0;
            const double ci = (static_cast<double>(y) / size) * 2.0 - 1.0;
            double zr = 0.0;
            double zi = 0.0;
            int iter = 0;
            while ((zr * zr + zi * zi) <= 4.0 && iter < 80) {
                const double next_r = zr * zr - zi * zi + cr;
                zi = 2.0 * zr * zi + ci;
                zr = next_r;
                ++iter;
            }
            acc += static_cast<std::uint64_t>(iter);
        }
    }
    consume(acc);
}

struct Body {
    double x;
    double y;
    double z;
    double vx;
    double vy;
    double vz;
    double mass;
};

inline void bench_n_bodies_native() {
    std::array<Body, 5> bodies = {{
        {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0},
        {1.0, 0.0, 0.0, 0.0, 0.8, 0.0, 1.0},
        {-1.0, 0.0, 0.0, 0.0, -0.8, 0.0, 1.0},
        {0.0, 1.2, 0.0, -0.7, 0.0, 0.0, 0.5},
        {0.0, -1.2, 0.0, 0.7, 0.0, 0.0, 0.5},
    }};

    constexpr double dt = 0.01;
    for (int step = 0; step < 400; ++step) {
        for (std::size_t i = 0; i < bodies.size(); ++i) {
            for (std::size_t j = i + 1; j < bodies.size(); ++j) {
                const double dx = bodies[j].x - bodies[i].x;
                const double dy = bodies[j].y - bodies[i].y;
                const double dz = bodies[j].z - bodies[i].z;
                const double dist2 = dx * dx + dy * dy + dz * dz + 1e-9;
                const double inv_dist = 1.0 / std::sqrt(dist2);
                const double inv_dist3 = inv_dist * inv_dist * inv_dist;
                const double force = inv_dist3 * dt;
                const double im = bodies[i].mass * force;
                const double jm = bodies[j].mass * force;
                bodies[i].vx += dx * jm;
                bodies[i].vy += dy * jm;
                bodies[i].vz += dz * jm;
                bodies[j].vx -= dx * im;
                bodies[j].vy -= dy * im;
                bodies[j].vz -= dz * im;
            }
        }
        for (auto &body : bodies) {
            body.x += body.vx * dt;
            body.y += body.vy * dt;
            body.z += body.vz * dt;
        }
    }

    std::uint64_t acc = 0;
    for (const auto &body : bodies) {
        acc ^= static_cast<std::uint64_t>((body.x + body.y + body.z) * 1000000.0);
    }
    consume(acc);
}

inline void bench_native_loop_native() {
    std::uint64_t acc = 0;
    for (std::uint64_t i = 0; i < 4000000ULL; ++i) {
        acc += (i * 3ULL) ^ (i >> 2U);
    }
    consume(acc);
}

inline void bench_particles_kinematics_native() {
    struct Particle {
        float px;
        float py;
        float pz;
        float vx;
        float vy;
        float vz;
    };

    std::vector<Particle> particles;
    particles.reserve(6000);
    for (int i = 0; i < 6000; ++i) {
        particles.push_back(Particle{
            static_cast<float>(std::sin(i * 0.1)),
            static_cast<float>(std::cos(i * 0.2)),
            static_cast<float>(std::sin(i * 0.3)),
            static_cast<float>(0.01 * (i % 7)),
            static_cast<float>(0.015 * (i % 11)),
            static_cast<float>(0.02 * (i % 13)),
        });
    }

    for (int step = 0; step < 100; ++step) {
        for (auto &p : particles) {
            p.vx += -p.px * 0.0003f;
            p.vy += -p.py * 0.0002f;
            p.vz += -p.pz * 0.0004f;
            p.px += p.vx;
            p.py += p.vy;
            p.pz += p.vz;
        }
    }

    std::uint64_t acc = 0;
    for (const auto &p : particles) {
        acc ^= static_cast<std::uint64_t>((p.px + p.py + p.pz) * 100000.0f);
    }
    consume(acc);
}

inline void bench_primes_loop_native() {
    constexpr int limit = 50000;
    std::vector<bool> is_prime(limit + 1, true);
    is_prime[0] = false;
    is_prime[1] = false;
    for (int i = 2; i * i <= limit; ++i) {
        if (is_prime[i]) {
            for (int j = i * i; j <= limit; j += i) {
                is_prime[j] = false;
            }
        }
    }
    std::uint64_t acc = 0;
    for (int i = 2; i <= limit; ++i) {
        if (is_prime[i]) {
            acc += static_cast<std::uint64_t>(i);
        }
    }
    consume(acc);
}

inline bool solve_queen(int row, int n, int cols, int diag1, int diag2, std::uint64_t &solutions) {
    if (row == n) {
        ++solutions;
        return true;
    }
    int available = ((1 << n) - 1) & ~(cols | diag1 | diag2);
    while (available != 0) {
        const int bit = available & -available;
        available -= bit;
        solve_queen(row + 1, n, cols | bit, (diag1 | bit) << 1, (diag2 | bit) >> 1, solutions);
    }
    return solutions != 0;
}

inline void bench_queen_native() {
    std::uint64_t solutions = 0;
    solve_queen(0, 12, 0, 0, 0, solutions);
    consume(solutions);
}

inline std::uint32_t rotr(std::uint32_t x, std::uint32_t n) {
    return (x >> n) | (x << (32U - n));
}

inline std::array<std::uint8_t, 32> sha256_bytes(std::string_view input) {
    static const std::uint32_t k[64] = {
        0x428a2f98U, 0x71374491U, 0xb5c0fbcfU, 0xe9b5dba5U, 0x3956c25bU, 0x59f111f1U, 0x923f82a4U, 0xab1c5ed5U,
        0xd807aa98U, 0x12835b01U, 0x243185beU, 0x550c7dc3U, 0x72be5d74U, 0x80deb1feU, 0x9bdc06a7U, 0xc19bf174U,
        0xe49b69c1U, 0xefbe4786U, 0x0fc19dc6U, 0x240ca1ccU, 0x2de92c6fU, 0x4a7484aaU, 0x5cb0a9dcU, 0x76f988daU,
        0x983e5152U, 0xa831c66dU, 0xb00327c8U, 0xbf597fc7U, 0xc6e00bf3U, 0xd5a79147U, 0x06ca6351U, 0x14292967U,
        0x27b70a85U, 0x2e1b2138U, 0x4d2c6dfcU, 0x53380d13U, 0x650a7354U, 0x766a0abbU, 0x81c2c92eU, 0x92722c85U,
        0xa2bfe8a1U, 0xa81a664bU, 0xc24b8b70U, 0xc76c51a3U, 0xd192e819U, 0xd6990624U, 0xf40e3585U, 0x106aa070U,
        0x19a4c116U, 0x1e376c08U, 0x2748774cU, 0x34b0bcb5U, 0x391c0cb3U, 0x4ed8aa4aU, 0x5b9cca4fU, 0x682e6ff3U,
        0x748f82eeU, 0x78a5636fU, 0x84c87814U, 0x8cc70208U, 0x90befffaU, 0xa4506cebU, 0xbef9a3f7U, 0xc67178f2U,
    };

    std::array<std::uint32_t, 8> h = {
        0x6a09e667U, 0xbb67ae85U, 0x3c6ef372U, 0xa54ff53aU,
        0x510e527fU, 0x9b05688cU, 0x1f83d9abU, 0x5be0cd19U,
    };

    std::vector<std::uint8_t> data(input.begin(), input.end());
    const std::uint64_t bit_size = static_cast<std::uint64_t>(data.size()) * 8ULL;
    data.push_back(0x80U);
    while ((data.size() % 64U) != 56U) {
        data.push_back(0U);
    }
    for (int i = 7; i >= 0; --i) {
        data.push_back(static_cast<std::uint8_t>((bit_size >> (i * 8)) & 0xffU));
    }

    std::array<std::uint32_t, 64> w{};
    for (std::size_t chunk = 0; chunk < data.size(); chunk += 64U) {
        for (int i = 0; i < 16; ++i) {
            const std::size_t index = chunk + static_cast<std::size_t>(i) * 4U;
            w[i] = (static_cast<std::uint32_t>(data[index]) << 24U)
                | (static_cast<std::uint32_t>(data[index + 1U]) << 16U)
                | (static_cast<std::uint32_t>(data[index + 2U]) << 8U)
                | static_cast<std::uint32_t>(data[index + 3U]);
        }
        for (int i = 16; i < 64; ++i) {
            const std::uint32_t s0 = rotr(w[i - 15], 7U) ^ rotr(w[i - 15], 18U) ^ (w[i - 15] >> 3U);
            const std::uint32_t s1 = rotr(w[i - 2], 17U) ^ rotr(w[i - 2], 19U) ^ (w[i - 2] >> 10U);
            w[i] = w[i - 16] + s0 + w[i - 7] + s1;
        }

        std::uint32_t a = h[0];
        std::uint32_t b = h[1];
        std::uint32_t c = h[2];
        std::uint32_t d = h[3];
        std::uint32_t e = h[4];
        std::uint32_t f = h[5];
        std::uint32_t g = h[6];
        std::uint32_t hh = h[7];

        for (int i = 0; i < 64; ++i) {
            const std::uint32_t s1 = rotr(e, 6U) ^ rotr(e, 11U) ^ rotr(e, 25U);
            const std::uint32_t ch = (e & f) ^ ((~e) & g);
            const std::uint32_t temp1 = hh + s1 + ch + k[i] + w[i];
            const std::uint32_t s0 = rotr(a, 2U) ^ rotr(a, 13U) ^ rotr(a, 22U);
            const std::uint32_t maj = (a & b) ^ (a & c) ^ (b & c);
            const std::uint32_t temp2 = s0 + maj;

            hh = g;
            g = f;
            f = e;
            e = d + temp1;
            d = c;
            c = b;
            b = a;
            a = temp1 + temp2;
        }

        h[0] += a;
        h[1] += b;
        h[2] += c;
        h[3] += d;
        h[4] += e;
        h[5] += f;
        h[6] += g;
        h[7] += hh;
    }

    std::array<std::uint8_t, 32> digest{};
    for (int i = 0; i < 8; ++i) {
        digest[i * 4] = static_cast<std::uint8_t>((h[i] >> 24U) & 0xffU);
        digest[i * 4 + 1] = static_cast<std::uint8_t>((h[i] >> 16U) & 0xffU);
        digest[i * 4 + 2] = static_cast<std::uint8_t>((h[i] >> 8U) & 0xffU);
        digest[i * 4 + 3] = static_cast<std::uint8_t>(h[i] & 0xffU);
    }
    return digest;
}

inline void bench_sha256_native() {
    std::uint64_t acc = 0;
    for (int i = 0; i < 1500; ++i) {
        const std::string text = "sha256-benchmark-" + std::to_string(i);
        const auto digest = sha256_bytes(text);
        acc ^= static_cast<std::uint64_t>(digest[0]) << 56U;
        acc ^= static_cast<std::uint64_t>(digest[8]) << 40U;
        acc ^= static_cast<std::uint64_t>(digest[16]) << 24U;
        acc ^= static_cast<std::uint64_t>(digest[24]) << 8U;
    }
    consume(acc);
}

inline void bench_sort_native() {
    std::vector<std::uint64_t> values(12000);
    for (std::size_t i = 0; i < values.size(); ++i) {
        values[i] = splitmix64(static_cast<std::uint64_t>(i * 17U));
    }
    std::sort(values.begin(), values.end());
    consume(values[0] ^ values[values.size() / 2U] ^ values.back());
}

inline double spectral_a(int i, int j) {
    const int ij = i + j;
    return 1.0 / static_cast<double>((ij * (ij + 1) / 2) + i + 1);
}

inline void spectral_multiply(const std::vector<double> &u, std::vector<double> &out) {
    const int n = static_cast<int>(u.size());
    for (int i = 0; i < n; ++i) {
        double sum = 0.0;
        for (int j = 0; j < n; ++j) {
            sum += spectral_a(i, j) * u[j];
        }
        out[i] = sum;
    }
}

inline void spectral_multiply_transposed(const std::vector<double> &u, std::vector<double> &out) {
    const int n = static_cast<int>(u.size());
    for (int i = 0; i < n; ++i) {
        double sum = 0.0;
        for (int j = 0; j < n; ++j) {
            sum += spectral_a(j, i) * u[j];
        }
        out[i] = sum;
    }
}

inline void bench_spectral_norm_native() {
    constexpr int n = 120;
    std::vector<double> u(n, 1.0);
    std::vector<double> v(n, 0.0);
    std::vector<double> tmp(n, 0.0);
    for (int i = 0; i < 10; ++i) {
        spectral_multiply(u, tmp);
        spectral_multiply_transposed(tmp, v);
        spectral_multiply(v, tmp);
        spectral_multiply_transposed(tmp, u);
    }

    double vv = 0.0;
    double uv = 0.0;
    for (int i = 0; i < n; ++i) {
        uv += u[i] * v[i];
        vv += v[i] * v[i];
    }
    consume(static_cast<std::uint64_t>(std::sqrt(uv / vv) * 1000000.0));
}

inline void bench_string2float_native() {
    std::uint64_t acc = 0;
    for (int i = 0; i < 12000; ++i) {
        const std::string text = std::to_string((i % 97) * 0.03125 + 10.0);
        char *end = nullptr;
        const double value = std::strtod(text.c_str(), &end);
        acc ^= static_cast<std::uint64_t>(value * 100000.0);
        acc += static_cast<std::uint64_t>(end - text.c_str());
    }
    consume(acc);
}

struct TreeNode {
    std::unique_ptr<TreeNode> left;
    std::unique_ptr<TreeNode> right;
    int value = 0;
};

inline std::unique_ptr<TreeNode> make_tree(int depth, int seed) {
    auto node = std::make_unique<TreeNode>();
    node->value = seed;
    if (depth > 0) {
        node->left = make_tree(depth - 1, seed * 2 + 1);
        node->right = make_tree(depth - 1, seed * 2 + 2);
    }
    return node;
}

inline std::uint64_t checksum_tree(const TreeNode *node) {
    if (!node) {
        return 0;
    }
    return static_cast<std::uint64_t>(node->value)
        + checksum_tree(node->left.get())
        + checksum_tree(node->right.get());
}

inline void bench_tree_native() {
    auto tree = make_tree(13, 1);
    consume(checksum_tree(tree.get()));
}


inline bool run_named_native_workload(std::string_view name) {
    if (name == "dictionary") {
        bench_dictionary_native();
    } else if (name == "exp_loop") {
        bench_exp_loop_native();
    } else if (name == "fibonacci_loop") {
        bench_fibonacci_loop_native();
    } else if (name == "fibonacci_recursive") {
        bench_fibonacci_recursive_native();
    } else if (name == "float2string") {
        bench_float2string_native();
    } else if (name == "mandelbrot") {
        bench_mandelbrot_native();
    } else if (name == "n_bodies") {
        bench_n_bodies_native();
    } else if (name == "native_loop") {
        bench_native_loop_native();
    } else if (name == "particles_kinematics") {
        bench_particles_kinematics_native();
    } else if (name == "primes_loop") {
        bench_primes_loop_native();
    } else if (name == "queen") {
        bench_queen_native();
    } else if (name == "sha256") {
        bench_sha256_native();
    } else if (name == "sort") {
        bench_sort_native();
    } else if (name == "spectral_norm") {
        bench_spectral_norm_native();
    } else if (name == "string2float") {
        bench_string2float_native();
    } else if (name == "tree") {
        bench_tree_native();
    } else {
        return false;
    }
    return true;
}

}  // namespace slc
