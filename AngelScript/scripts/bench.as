uint mix32(uint x) {
    x ^= x >> 16;
    x *= 0x7feb352d;
    x ^= x >> 15;
    x *= 0x846ca68b;
    x ^= x >> 16;
    return x;
}

uint64 mix_checksum(uint64 acc, uint64 value) {
    const uint64 c = (uint64(0x9e3779b9) << 32) | uint64(0x7f4a7c15);
    return acc ^ (value + c + (acc << 6) + (acc >> 2));
}

uint64 splitmix64(uint64 x) {
    const uint64 c1 = (uint64(0x9e3779b9) << 32) | uint64(0x7f4a7c15);
    const uint64 c2 = (uint64(0xbf58476d) << 32) | uint64(0x1ce4e5b9);
    const uint64 c3 = (uint64(0x94d049bb) << 32) | uint64(0x133111eb);
    x += c1;
    x = (x ^ (x >> 30)) * c2;
    x = (x ^ (x >> 27)) * c3;
    return x ^ (x >> 31);
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

uint rotr(uint x, uint n) {
    return (x >> n) | (x << (32 - n));
}

array<uint8> sha256_bytes(const string &in input) {
    const array<uint> k = {
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    };

    array<uint8> data;
    data.resize(0);
    for (uint i = 0; i < input.length(); ++i) {
        data.insertLast(uint8(input[i]));
    }
    uint64 bit_size = uint64(data.length()) * 8;
    data.insertLast(uint8(0x80));
    while ((data.length() % 64) != 56) {
        data.insertLast(uint8(0));
    }
    for (int i = 7; i >= 0; --i) {
        data.insertLast(uint8((bit_size >> (uint(i) * 8)) & uint64(0xff)));
    }

    array<uint> w;
    w.resize(64);
    array<uint> h;
    h.resize(8);
    h[0] = 0x6a09e667;
    h[1] = 0xbb67ae85;
    h[2] = 0x3c6ef372;
    h[3] = 0xa54ff53a;
    h[4] = 0x510e527f;
    h[5] = 0x9b05688c;
    h[6] = 0x1f83d9ab;
    h[7] = 0x5be0cd19;

    for (uint chunk = 0; chunk < data.length(); chunk += 64) {
        for (uint i = 0; i < 16; ++i) {
            uint index = chunk + i * 4;
            w[i] = (uint(data[index]) << 24)
                 | (uint(data[index + 1]) << 16)
                 | (uint(data[index + 2]) << 8)
                 | uint(data[index + 3]);
        }
        for (uint i = 16; i < 64; ++i) {
            uint s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
            uint s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
            w[i] = w[i - 16] + s0 + w[i - 7] + s1;
        }

        uint a = h[0];
        uint b = h[1];
        uint c = h[2];
        uint d = h[3];
        uint e = h[4];
        uint f = h[5];
        uint g = h[6];
        uint hh = h[7];

        for (uint i = 0; i < 64; ++i) {
            uint S1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
            uint ch = (e & f) ^ ((~e) & g);
            uint temp1 = hh + S1 + ch + k[i] + w[i];
            uint S0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
            uint maj = (a & b) ^ (a & c) ^ (b & c);
            uint temp2 = S0 + maj;

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

    array<uint8> digest;
    digest.resize(32);
    for (uint i = 0; i < 8; ++i) {
        digest[i * 4]     = uint8((h[i] >> 24) & 0xff);
        digest[i * 4 + 1] = uint8((h[i] >> 16) & 0xff);
        digest[i * 4 + 2] = uint8((h[i] >> 8) & 0xff);
        digest[i * 4 + 3] = uint8(h[i] & 0xff);
    }
    return digest;
}

double parse_double(const string &in text) {
    bool negative = false;
    uint index = 0;
    if (text.length() > 0 && uint8(text[0]) == uint8(45)) {
        negative = true;
        index = 1;
    }
    double value = 0.0;
    while (index < text.length() && uint8(text[index]) != uint8(46)) {
        value = value * 10.0 + double(uint8(text[index]) - 48);
        index++;
    }
    if (index < text.length() && uint8(text[index]) == uint8(46)) {
        index++;
        double place = 0.1;
        while (index < text.length()) {
            value += double(uint8(text[index]) - 48) * place;
            place *= 0.1;
            index++;
        }
    }
    return negative ? -value : value;
}

class Body {
    double x;
    double y;
    double z;
    double vx;
    double vy;
    double vz;
    double mass;
};

class Particle {
    float px;
    float py;
    float pz;
    float vx;
    float vy;
    float vz;
};

class TreeNode {
    int value;
    TreeNode@ left;
    TreeNode@ right;
}

TreeNode@ make_tree(int depth, int seed) {
    TreeNode node;
    node.value = seed;
    if (depth > 0) {
        @node.left = make_tree(depth - 1, seed * 2 + 1);
        @node.right = make_tree(depth - 1, seed * 2 + 2);
    }
    return node;
}

uint64 checksum_tree(TreeNode@ node) {
    if (node is null) {
        return 0;
    }
    uint64 acc = uint64(node.value);
    acc += checksum_tree(node.left);
    acc += checksum_tree(node.right);
    return acc;
}

uint64 work_dictionary(int seed) {
    dictionary map;
    for (int i = 0; i < 3000; ++i) {
        uint key = uint(splitmix64(uint64(i)) & 0xFFF);
        uint value = uint(i) ^ (key << 1);
        string str_key = formatUInt(key);
        map.set(str_key, int(value));
    }
    uint64 acc = 0;
    for (int i = 0; i < 3000; ++i) {
        uint key = uint(splitmix64(uint64(i + 7000)) & 0xFFF);
        string str_key = formatUInt(key);
        int value = 0;
        if (map.get(str_key, value)) {
            acc += uint64(value);
        }
    }
    acc ^= uint64(map.getSize());
    return mix_checksum(acc, uint64(seed));
}

uint64 work_exp_loop(int seed) {
    double sum = 0.0;
    for (int i = 1; i <= 40000; ++i) {
        double x = double(((i + seed) % 2048) + 1) * 0.00075;
        sum += exp(x);
    }
    return mix_checksum(0, uint64(sum * 1000.0));
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

uint64 work_float2string(int seed) {
    uint64 acc = 0;
    for (int i = 0; i < 12000; ++i) {
        double value = sin((i + seed) * 0.01) * 10000.0;
        string text = formatFloat(value, "", 0, 9);
        acc += uint64(text.length());
        if (text.length() > 0) {
            acc ^= uint64(uint8(text[0]));
        }
    }
    return mix_checksum(acc, uint64(seed));
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

uint64 work_n_bodies(int seed) {
 array<Body> bodies;
 bodies.resize(5);
 bodies[0].x = 0.0;
 bodies[0].y = 0.0;
 bodies[0].z = 0.0;
 bodies[0].vx = 0.0;
 bodies[0].vy = 0.0;
 bodies[0].vz = 0.0;
 bodies[0].mass = 10.0;

 bodies[1].x = 1.0;
 bodies[1].mass = 1.0;
 bodies[1].vy = 0.8;

 bodies[2].x = -1.0;
 bodies[2].mass = 1.0;
 bodies[2].vy = -0.8;

 bodies[3].y = 1.2;
 bodies[3].vx = -0.7;
 bodies[3].mass = 0.5;

 bodies[4].y = -1.2;
 bodies[4].vx = 0.7;
 bodies[4].mass = 0.5;

 const double dt = 0.01;
 for (int step = 0; step < 400; ++step) {
 for (uint i = 0; i < bodies.length(); ++i) {
 for (uint j = i + 1; j < bodies.length(); ++j) {
 double dx = bodies[j].x - bodies[i].x;
 double dy = bodies[j].y - bodies[i].y;
 double dz = bodies[j].z - bodies[i].z;
 double dist2 = dx * dx + dy * dy + dz * dz + 1e-9;
 double inv_dist = 1.0 / sqrt(dist2);
 double inv_dist3 = inv_dist * inv_dist * inv_dist;
 double force = inv_dist3 * dt;
 double im = bodies[i].mass * force;
 double jm = bodies[j].mass * force;
 bodies[i].vx += dx * jm;
 bodies[i].vy += dy * jm;
 bodies[i].vz += dz * jm;
 bodies[j].vx -= dx * im;
 bodies[j].vy -= dy * im;
 bodies[j].vz -= dz * im;
 }
 }
 for (uint i = 0; i < bodies.length(); ++i) {
 bodies[i].x += bodies[i].vx * dt;
 bodies[i].y += bodies[i].vy * dt;
 bodies[i].z += bodies[i].vz * dt;
 }
 }

 uint64 acc = 0;
 for (uint i = 0; i < bodies.length(); ++i) {
 acc ^= uint64((bodies[i].x + bodies[i].y + bodies[i].z) * 1000000.0);
 }
 return mix_checksum(acc, uint64(seed));
}

uint64 work_native_loop(int seed) {
 uint64 acc = uint64(seed);
 for (uint64 i = 0; i < 4000000; ++i) {
 acc = acc + uint64((i * 3) ^ (i >> 2));
 }
 return acc;
}

uint64 work_particles_kinematics(int seed) {
 array<Particle> particles;
 particles.resize(6000);
 for (int i = 0; i < 6000; ++i) {
 particles[i].px = float(sin(i * 0.1));
 particles[i].py = float(cos(i * 0.2));
 particles[i].pz = float(sin(i * 0.3));
 particles[i].vx = 0.01f * float(i % 7);
 particles[i].vy = 0.015f * float(i % 11);
 particles[i].vz = 0.02f * float(i % 13);
 }
 for (int step = 0; step < 100; ++step) {
 for (uint i = 0; i < particles.length(); ++i) {
 particles[i].vx += -particles[i].px * 0.0003f;
 particles[i].vy += -particles[i].py * 0.0002f;
 particles[i].vz += -particles[i].pz * 0.0004f;
 particles[i].px += particles[i].vx;
 particles[i].py += particles[i].vy;
 particles[i].pz += particles[i].vz;
 }
 }
 uint64 acc = 0;
 for (uint i = 0; i < particles.length(); ++i) {
 acc ^= uint64((particles[i].px + particles[i].py + particles[i].pz) * 100000.0f);
 }
 return mix_checksum(acc, uint64(seed));
}

uint64 work_primes_loop(int seed) {
 const int limit = 50000 + (seed & 15);
 array<int> is_prime;
 is_prime.resize(limit + 1);
 for (int i = 0; i <= limit; ++i) {
 is_prime[i] = 1;
 }
 is_prime[0] = 0;
 is_prime[1] = 0;
 int i = 2;
 while (i * i <= limit) {
 if (is_prime[i] != 0) {
 int j = i * i;
 while (j <= limit) {
 is_prime[j] = 0;
 j += i;
 }
 }
 i++;
 }
 uint64 acc = 0;
 for (int n = 2; n <= limit; ++n) {
 if (is_prime[n] != 0) {
 acc += uint64(n);
 }
 }
 return mix_checksum(acc, uint64(seed));
}

uint64 work_queen(int seed) {
    return solve_queen_impl(0, 11 + (seed & 1), 0, 0, 0);
}

uint64 work_sha256(int seed) {
 uint64 acc = 0;
 for (int i = 0; i < 1500; ++i) {
 string text = "sha256-benchmark-" + formatInt(i);
 array<uint8> digest = sha256_bytes(text);
 acc ^= uint64(digest[0]) << 56;
 acc ^= uint64(digest[8]) << 40;
 acc ^= uint64(digest[16]) << 24;
 acc ^= uint64(digest[24]) << 8;
 }
 return mix_checksum(acc, uint64(seed));
}

uint64 work_sort(int seed) {
    const int count = 2048;
    array<int> values;
    values.resize(count);
 for (int i = 0; i < count; ++i) {
 values[i] = int(splitmix64(uint64(i * 17)) & 0x7fffffff);
 }
 for (int i = 1; i < count; ++i) {
 int value = values[i];
 int j = i - 1;
 while (j >= 0 && values[j] > value) {
 values[j + 1] = values[j];
 j--;
 }
 values[j + 1] = value;
 }
 uint64 acc = 0;
 for (int i = 0; i < count; i += 31) {
 acc = mix_checksum(acc, uint64(values[i]));
 }
    return acc;
}

double spectral_a(int i, int j) {
    const int ij = i + j;
    return 1.0 / double((ij * (ij + 1) / 2) + i + 1);
}

void spectral_multiply(const array<double> &in u, array<double> &output) {
    const int n = u.length();
    for (int i = 0; i < n; ++i) {
        double sum = 0.0;
        for (int j = 0; j < n; ++j) {
            sum += spectral_a(i, j) * u[j];
        }
        output[i] = sum;
    }
}

void spectral_multiply_transposed(const array<double> &in u, array<double> &output) {
    const int n = u.length();
    for (int i = 0; i < n; ++i) {
        double sum = 0.0;
        for (int j = 0; j < n; ++j) {
            sum += spectral_a(j, i) * u[j];
        }
        output[i] = sum;
    }
}

uint64 work_spectral_norm(int seed) {
 const uint n = 120;
 array<double> u;
 array<double> v;
 array<double> tmp;
 u.resize(n);
 v.resize(n);
 tmp.resize(n);
 for (uint i = 0; i < n; ++i) {
 u[i] = 1.0;
 v[i] = 0.0;
 tmp[i] = 0.0;
 }
 for (int i = 0; i < 10; ++i) {
 spectral_multiply(u, tmp);
 spectral_multiply_transposed(tmp, v);
 spectral_multiply(v, tmp);
 spectral_multiply_transposed(tmp, u);
 }
 double uv = 0.0;
 double vv = 0.0;
 for (uint i = 0; i < n; ++i) {
 uv += u[i] * v[i];
 vv += v[i] * v[i];
 }
 double ratio = sqrt(uv / vv);
 return mix_checksum(0, uint64(ratio * 1000000.0));
}

uint64 work_string2float(int seed) {
    uint64 acc = 0;
    for (int i = 0; i < 12000; ++i) {
        double value = (i % 97) * 0.03125 + 10.0;
        string text = formatFloat(value, "", 0, 6);
        double parsed = parse_double(text);
        acc ^= uint64(parsed * 100000.0);
        acc += uint64(text.length());
    }
    return mix_checksum(acc, uint64(seed));
}

uint64 work_tree(int seed) {
    TreeNode@ root = make_tree(13, 1 + seed);
    return checksum_tree(root);
}

uint64 benchmark_dictionary(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_dictionary(i));
    }
    return acc;
}

uint64 benchmark_exp_loop(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_exp_loop(i));
    }
    return acc;
}

uint64 benchmark_fibonacci_loop(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_fibonacci_loop(i));
    }
    return acc;
}

uint64 benchmark_fibonacci_recursive(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_fibonacci_recursive(i));
    }
    return acc;
}

uint64 benchmark_float2string(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_float2string(i));
    }
    return acc;
}

uint64 benchmark_mandelbrot(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_mandelbrot(i));
    }
    return acc;
}

uint64 benchmark_n_bodies(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_n_bodies(i));
    }
    return acc;
}

uint64 benchmark_native_loop(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_native_loop(i));
    }
    return acc;
}

uint64 benchmark_particles_kinematics(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_particles_kinematics(i));
    }
    return acc;
}

uint64 benchmark_primes_loop(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_primes_loop(i));
    }
    return acc;
}

uint64 benchmark_queen(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_queen(i));
    }
    return acc;
}

uint64 benchmark_sha256(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_sha256(i));
    }
    return acc;
}

uint64 benchmark_sort(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_sort(i));
    }
    return acc;
}

uint64 benchmark_spectral_norm(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_spectral_norm(i));
    }
    return acc;
}

uint64 benchmark_string2float(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_string2float(i));
    }
    return acc;
}

uint64 benchmark_tree(int repeat_count) {
    uint64 acc = 0;
    for (int i = 0; i < repeat_count; ++i) {
        acc = mix_checksum(acc, work_tree(i));
    }
    return acc;
}
