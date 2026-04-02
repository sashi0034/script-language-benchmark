options gen2
require math

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

def splitmix64(x : uint64) : uint64 {
    var y = x
    let c1 = (uint64(0x9e3779b9) << uint64(32)) | uint64(0x7f4a7c15)
    let c2 = (uint64(0xbf58476d) << uint64(32)) | uint64(0x1ce4e5b9)
    let c3 = (uint64(0x94d049bb) << uint64(32)) | uint64(0x133111eb)
    y += c1
    y = (y ^ (y >> uint64(30))) * c2
    y = (y ^ (y >> uint64(27))) * c3
    y = y ^ (y >> uint64(31))
    return y
}

def append_decimal_digits(var target : array<uint8>&; value : int) {
    if (value == 0) {
        target |> push(uint8(48))
        return
    }
    var digits : array<uint8>
    resize(digits, 0)
    var temp = value
    while (temp != 0) {
        digits |> push(uint8(uint(temp % 10) + uint(48)))
        temp /= 10
    }
    let len = length(digits)
    for (i in range(len)) {
        target |> push(digits[len - 1 - i])
    }
}

def format_decimal_text(value : double; precision : int) : array<uint8> {
    var text : array<uint8>
    resize(text, 0)
    var current = value
    if (current < 0.0lf) {
        text |> push(uint8(45))
        current = -current
    }
    let integer_part = int(current)
    append_decimal_digits(text, integer_part)
    text |> push(uint8(46))
    var fractional = current - double(integer_part)
    for (i in range(precision)) {
        fractional *= 10.0lf
        let digit = int(fractional) % 10
        text |> push(uint8(uint(digit) + uint(48)))
        fractional -= double(digit)
    }
    return <- text
}

def parse_double_from_text(text : array<uint8>) : double {
    var index = 0
    var negative = false
    if (length(text) > 0 && text[0] == uint8(45)) {
        negative = true
        index = 1
    }
    var value = 0.0lf
    while (index < length(text) && text[index] != uint8(46)) {
        value = value * 10.0lf + double(int(text[index]) - 48)
        index ++
    }
    if (index < length(text) && text[index] == uint8(46)) {
        index ++
        var place = 0.1lf
        while (index < length(text)) {
            value += double(int(text[index]) - 48) * place
            place *= 0.1lf
            index ++
        }
    }
    return negative ? -value : value
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

def work_dictionary(seed : int) : uint64 {
    let capacity = 4096
    var values : array<int>;
    var present : array<int>;
    resize(values, capacity);
    resize(present, capacity);
    for (i in range(capacity)) {
        values[i] = 0;
        present[i] = 0;
    }
    var size = 0;
    for (i in range(3000)) {
        let key = int(splitmix64(uint64(i)) & uint64(capacity - 1));
        let value = int(i) ^ (key << 1);
        if (present[key] == 0) {
            size += 1;
            present[key] = 1;
        }
        values[key] = value;
    }
    var acc : uint64 = uint64(0);
    for (i in range(3000)) {
        let key = int(splitmix64(uint64(i + 7000)) & uint64(capacity - 1));
        if (present[key] != 0) {
            acc += uint64(values[key]);
        }
    }
    acc ^= uint64(size);
    return mix_checksum(acc, uint64(seed));
}

def work_exp_loop(seed : int) : uint64 {
    var sum : double = 0.0lf
    for (i in range(1, 40001)) {
        let x = double(((i + seed) % 2048) + 1) * 0.00075lf
        sum += exp(x)
    }
    return mix_checksum(uint64(0), uint64(sum * 1000.0lf))
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

def work_float2string(seed : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(12000)) {
        let value = sin(double(i + seed) * 0.01lf) * 10000.0lf
        var text <- format_decimal_text(value, 9)
        acc += uint64(length(text))
        if (length(text) > 0) {
            acc ^= uint64(text[0])
        }
    }
    return mix_checksum(acc, uint64(seed))
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

def work_n_bodies(seed : int) : uint64 {
    let count = 5
    var bodies : array<double>
    resize(bodies, count * 7)
    bodies[0] = 0.0lf
    bodies[1] = 0.0lf
    bodies[2] = 0.0lf
    bodies[3] = 0.0lf
    bodies[4] = 0.0lf
    bodies[5] = 0.0lf
    bodies[6] = 10.0lf

    bodies[7] = 1.0lf
    bodies[8] = 0.0lf
    bodies[9] = 0.0lf
    bodies[10] = 0.0lf
    bodies[11] = 0.8lf
    bodies[12] = 0.0lf
    bodies[13] = 1.0lf

    bodies[14] = -1.0lf
    bodies[15] = 0.0lf
    bodies[16] = 0.0lf
    bodies[17] = 0.0lf
    bodies[18] = -0.8lf
    bodies[19] = 0.0lf
    bodies[20] = 1.0lf

    bodies[21] = 0.0lf
    bodies[22] = 1.2lf
    bodies[23] = 0.0lf
    bodies[24] = -0.7lf
    bodies[25] = 0.0lf
    bodies[26] = 0.0lf
    bodies[27] = 0.5lf

    bodies[28] = 0.0lf
    bodies[29] = -1.2lf
    bodies[30] = 0.0lf
    bodies[31] = 0.7lf
    bodies[32] = 0.0lf
    bodies[33] = 0.0lf
    bodies[34] = 0.5lf

    let dt = 0.01lf
    for (step in range(400)) {
        for (i in range(count)) {
            let i_base = i * 7
            for (j in range(i + 1, count)) {
                let j_base = j * 7
                let dx = bodies[j_base + 0] - bodies[i_base + 0]
                let dy = bodies[j_base + 1] - bodies[i_base + 1]
                let dz = bodies[j_base + 2] - bodies[i_base + 2]
                let dist2 = dx * dx + dy * dy + dz * dz + 1e-9lf
                let inv_dist = 1.0lf / sqrt(dist2)
                let inv_dist3 = inv_dist * inv_dist * inv_dist
                let force = inv_dist3 * dt
                let im = bodies[i_base + 6] * force
                let jm = bodies[j_base + 6] * force
                bodies[i_base + 3] += dx * jm
                bodies[i_base + 4] += dy * jm
                bodies[i_base + 5] += dz * jm
                bodies[j_base + 3] -= dx * im
                bodies[j_base + 4] -= dy * im
                bodies[j_base + 5] -= dz * im
            }
        }
        for (i in range(count)) {
            let base = i * 7
            bodies[base + 0] += bodies[base + 3] * dt
            bodies[base + 1] += bodies[base + 4] * dt
            bodies[base + 2] += bodies[base + 5] * dt
        }
    }

    var acc : uint64 = uint64(0)
    for (i in range(count)) {
        let base = i * 7
        acc ^= uint64((bodies[base + 0] + bodies[base + 1] + bodies[base + 2]) * 1000000.0lf)
    }
    return mix_checksum(acc, uint64(seed))
}

def work_native_loop(seed : int) : uint64 {
    var acc : uint64 = uint64(seed)
    for (i in range(4000000)) {
        let value = uint64(uint64(i) * uint64(3)) ^ uint64(uint64(i) >> uint64(2))
        acc += value
    }
    return acc
}

def work_particles_kinematics(seed : int) : uint64 {
    let count = 6000
    var particles : array<double>
    resize(particles, count * 6)
    for (i in range(count)) {
        let base = i * 6
        particles[base + 0] = sin(double(i) * 0.1lf)
        particles[base + 1] = cos(double(i) * 0.2lf)
        particles[base + 2] = sin(double(i) * 0.3lf)
        particles[base + 3] = double(i % 7) * 0.01lf
        particles[base + 4] = double(i % 11) * 0.015lf
        particles[base + 5] = double(i % 13) * 0.02lf
    }
    for (step in range(100)) {
        for (i in range(count)) {
            let base = i * 6
            particles[base + 3] += -particles[base + 0] * 0.0003lf
            particles[base + 4] += -particles[base + 1] * 0.0002lf
            particles[base + 5] += -particles[base + 2] * 0.0004lf
            particles[base + 0] += particles[base + 3]
            particles[base + 1] += particles[base + 4]
            particles[base + 2] += particles[base + 5]
        }
    }
    var acc : uint64 = uint64(0)
    for (i in range(count)) {
        let base = i * 6
        acc ^= uint64((particles[base + 0] + particles[base + 1] + particles[base + 2]) * 100000.0lf)
    }
    return mix_checksum(acc, uint64(seed))
}

let sha256_k = [
    0x428a2f98u, 0x71374491u, 0xb5c0fbcfu, 0xe9b5dba5u, 0x3956c25bu, 0x59f111f1u, 0x923f82a4u, 0xab1c5ed5u,
    0xd807aa98u, 0x12835b01u, 0x243185beu, 0x550c7dc3u, 0x72be5d74u, 0x80deb1feu, 0x9bdc06a7u, 0xc19bf174u,
    0xe49b69c1u, 0xefbe4786u, 0x0fc19dc6u, 0x240ca1ccu, 0x2de92c6fu, 0x4a7484aau, 0x5cb0a9dcu, 0x76f988dau,
    0x983e5152u, 0xa831c66du, 0xb00327c8u, 0xbf597fc7u, 0xc6e00bf3u, 0xd5a79147u, 0x06ca6351u, 0x14292967u,
    0x27b70a85u, 0x2e1b2138u, 0x4d2c6dfcu, 0x53380d13u, 0x650a7354u, 0x766a0abbu, 0x81c2c92eu, 0x92722c85u,
    0xa2bfe8a1u, 0xa81a664bu, 0xc24b8b70u, 0xc76c51a3u, 0xd192e819u, 0xd6990624u, 0xf40e3585u, 0x106aa070u,
    0x19a4c116u, 0x1e376c08u, 0x2748774cu, 0x34b0bcb5u, 0x391c0cb3u, 0x4ed8aa4au, 0x5b9cca4fu, 0x682e6ff3u,
    0x748f82eeu, 0x78a5636fu, 0x84c87814u, 0x8cc70208u, 0x90befffau, 0xa4506cebu, 0xbef9a3f7u, 0xc67178f2u,
]

def rotr_uint(x : uint; n : uint) : uint {
    return (x >> n) | (x << (uint(32) - n))
}

def sha256_bytes(input : array<uint8>) : array<uint8> {
    var data : array<uint8>
    resize(data, 0)
    for (i in range(length(input))) {
        data |> push(input[i])
    }
    var bit_size : uint64 = uint64(length(data)) * uint64(8)
    data |> push(uint8(0x80))
    while ((length(data) % 64) != 56) {
        data |> push(uint8(0))
    }
    for (i in range(8)) {
        let shift = uint64(7 - i) * uint64(8)
        data |> push(uint8((bit_size >> shift) & uint64(0xff)))
    }

    var w : array<uint>
    resize(w, 64)
    var h : array<uint>
    resize(h, 8)
    h[0] = 0x6a09e667u
    h[1] = 0xbb67ae85u
    h[2] = 0x3c6ef372u
    h[3] = 0xa54ff53au
    h[4] = 0x510e527fu
    h[5] = 0x9b05688cu
    h[6] = 0x1f83d9abu
    h[7] = 0x5be0cd19u

    var chunk = 0
    while (chunk < length(data)) {
        for (i in range(16)) {
            let index = chunk + i * 4
            w[i] = (uint(data[index]) << uint(24)) | (uint(data[index + 1]) << uint(16)) | (uint(data[index + 2]) << uint(8)) | uint(data[index + 3])
        }
        for (i in range(16, 64)) {
            let s0 = rotr_uint(w[i - 15], uint(7)) ^ rotr_uint(w[i - 15], uint(18)) ^ (w[i - 15] >> uint(3))
            let s1 = rotr_uint(w[i - 2], uint(17)) ^ rotr_uint(w[i - 2], uint(19)) ^ (w[i - 2] >> uint(10))
            w[i] = w[i - 16] + s0 + w[i - 7] + s1
        }
        var a = h[0]
        var b = h[1]
        var c = h[2]
        var d = h[3]
        var e = h[4]
        var f = h[5]
        var g = h[6]
        var hh = h[7]

        for (i in range(64)) {
            let S1 = rotr_uint(e, uint(6)) ^ rotr_uint(e, uint(11)) ^ rotr_uint(e, uint(25))
            let ch = (e & f) ^ ((~e) & g)
            let temp1 = hh + S1 + ch + sha256_k[i] + w[i]
            let S0 = rotr_uint(a, uint(2)) ^ rotr_uint(a, uint(13)) ^ rotr_uint(a, uint(22))
            let maj = (a & b) ^ (a & c) ^ (b & c)
            let temp2 = S0 + maj

            hh = g
            g = f
            f = e
            e = d + temp1
            d = c
            c = b
            b = a
            a = temp1 + temp2
        }

        h[0] += a
        h[1] += b
        h[2] += c
        h[3] += d
        h[4] += e
        h[5] += f
        h[6] += g
        h[7] += hh
        chunk += 64
    }

    var digest : array<uint8>
    resize(digest, 32)
    for (i in range(8)) {
        let value = h[i]
        digest[i * 4 + 0] = uint8((value >> uint(24)) & 0xff)
        digest[i * 4 + 1] = uint8((value >> uint(16)) & 0xff)
        digest[i * 4 + 2] = uint8((value >> uint(8)) & 0xff)
        digest[i * 4 + 3] = uint8(value & 0xff)
    }
    return <- digest
}

def work_sha256(seed : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(1500)) {
        var message : array<uint8>
        resize(message, 0)
        message |> push(uint8(0x73))
        message |> push(uint8(0x68))
        message |> push(uint8(0x61))
        message |> push(uint8(0x32))
        message |> push(uint8(0x35))
        message |> push(uint8(0x36))
        message |> push(uint8(0x2d))
        message |> push(uint8(0x62))
        message |> push(uint8(0x65))
        message |> push(uint8(0x6e))
        message |> push(uint8(0x63))
        message |> push(uint8(0x68))
        message |> push(uint8(0x6d))
        message |> push(uint8(0x61))
        message |> push(uint8(0x72))
        message |> push(uint8(0x6b))
        message |> push(uint8(0x2d))
        append_decimal_digits(message, i)
        var digest = sha256_bytes(message)
        acc ^= uint64(digest[0]) << uint64(56)
        acc ^= uint64(digest[8]) << uint64(40)
        acc ^= uint64(digest[16]) << uint64(24)
        acc ^= uint64(digest[24]) << uint64(8)
    }
    return mix_checksum(acc, uint64(seed))
}

def spectral_a(i : int; j : int) : double {
    let ij = i + j
    return 1.0lf / double((ij * (ij + 1) / 2) + i + 1)
}

def spectral_multiply(u : array<double>; var output : array<double>) {
    let n = length(u)
    for (i in range(n)) {
        var sum = 0.0lf
        for (j in range(n)) {
            sum += spectral_a(i, j) * u[j]
        }
        output[i] = sum
    }
}

def spectral_multiply_transposed(u : array<double>; var output : array<double>) {
    let n = length(u)
    for (i in range(n)) {
        var sum = 0.0lf
        for (j in range(n)) {
            sum += spectral_a(j, i) * u[j]
        }
        output[i] = sum
    }
}

def work_spectral_norm(seed : int) : uint64 {
    let n = 120
    var u : array<double>
    var v : array<double>
    var tmp : array<double>
    resize(u, n)
    resize(v, n)
    resize(tmp, n)
    for (i in range(n)) {
        u[i] = 1.0lf
        v[i] = 0.0lf
        tmp[i] = 0.0lf
    }
    for (iter in range(10)) {
        spectral_multiply(u, tmp)
        spectral_multiply_transposed(tmp, v)
        spectral_multiply(v, tmp)
        spectral_multiply_transposed(tmp, u)
    }
    var uv = 0.0lf
    var vv = 0.0lf
    for (i in range(n)) {
        uv += u[i] * v[i]
        vv += v[i] * v[i]
    }
    let ratio = sqrt(uv / vv)
    return mix_checksum(uint64(0), uint64(ratio * 1000000.0lf))
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

def work_string2float(seed : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(12000)) {
        let value = double(i % 97) * 0.03125lf + 10.0lf
        var text <- format_decimal_text(value, 6)
        let parsed = parse_double_from_text(text)
        acc ^= uint64(parsed * 100000.0lf)
        acc += uint64(length(text))
    }
    return mix_checksum(acc, uint64(seed))
}

def make_tree_node(depth : int; seed : int; var values : array<int>; var left : array<int>; var right : array<int>) : int {
    values |> push(seed)
    left |> push(-1)
    right |> push(-1)
    let idx = length(values) - 1
    if (depth > 0) {
        let left_child = make_tree_node(depth - 1, seed * 2 + 1, values, left, right)
        let right_child = make_tree_node(depth - 1, seed * 2 + 2, values, left, right)
        left[idx] = left_child
        right[idx] = right_child
    }
    return idx
}

def checksum_tree(index : int; values : array<int>; left : array<int>; right : array<int>) : uint64 {
    if (index < 0) {
        return uint64(0)
    }
    var acc : uint64 = uint64(values[index])
    acc += checksum_tree(left[index], values, left, right)
    acc += checksum_tree(right[index], values, left, right)
    return acc
}

def work_tree(seed : int) : uint64 {
    var values : array<int>
    var left : array<int>
    var right : array<int>
    resize(values, 0)
    resize(left, 0)
    resize(right, 0)
    let root = make_tree_node(13, 1 + seed, values, left, right)
    return checksum_tree(root, values, left, right)
}

[export]
def benchmark_dictionary(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_dictionary(i))
    }
    return acc
}

[export]
def benchmark_exp_loop(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_exp_loop(i))
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
def benchmark_float2string(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_float2string(i))
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
def benchmark_n_bodies(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_n_bodies(i))
    }
    return acc
}

[export]
def benchmark_native_loop(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_native_loop(i))
    }
    return acc
}

[export]
def benchmark_particles_kinematics(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_particles_kinematics(i))
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
def benchmark_sha256(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_sha256(i))
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

[export]
def benchmark_spectral_norm(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_spectral_norm(i))
    }
    return acc
}

[export]
def benchmark_string2float(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_string2float(i))
    }
    return acc
}

[export]
def benchmark_tree(repeat : int) : uint64 {
    var acc : uint64 = uint64(0)
    for (i in range(repeat)) {
        acc = mix_checksum(acc, work_tree(i))
    }
    return acc
}
