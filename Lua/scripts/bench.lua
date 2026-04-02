local function mix32(x)
  x = x ~ (x >> 16)
  x = (x * 0x7feb352d) & 0xffffffff
  x = x ~ (x >> 15)
  x = (x * 0x846ca68b) & 0xffffffff
  x = x ~ (x >> 16)
  return x & 0xffffffff
end

local function mix_checksum(acc, value)
  return (acc ~ (value + 0x9e3779b9 + ((acc << 6) & 0xffffffffffffffff) + (acc >> 2))) & 0xffffffffffffffff
end

local function fib_recursive_impl(n)
  if n < 2 then return n end
  return fib_recursive_impl(n - 1) + fib_recursive_impl(n - 2)
end

local function solve_queen_impl(row, n, cols, diag1, diag2)
  if row == n then return 1 end
  local available = ((1 << n) - 1) & (~(cols | diag1 | diag2))
  local solutions = 0
  while available ~= 0 do
    local bit = available & (-available)
    available = available - bit
    solutions = solutions + solve_queen_impl(row + 1, n, cols | bit, (diag1 | bit) << 1, (diag2 | bit) >> 1)
  end
  return solutions
end

local function work_dictionary(seed)
  local map = {}
  local acc = 0
  for i = 1, 3000 do
    local key = mix32(i + seed * 131) & 4095
    map[key] = (i ~ (key << 1))
  end
  for i = 1, 3000 do
    local key = mix32(i + seed * 131 + 7000) & 4095
    local v = map[key]
    if v ~= nil then acc = (acc + v) & 0xffffffffffffffff end
  end
  return acc ~ (#map)
end

local function work_exp_loop(seed)
  local sum = 0.0
  for i = 1, 40000 do
    local x = ((i + seed) % 2048 + 1) * 0.00075
    sum = sum + math.exp(x)
  end
  return math.floor(sum * 1000.0)
end

local function work_fibonacci_loop(seed)
  local a = seed
  local b = seed + 1
  local acc = 0
  for _ = 1, 250000 do
    local c = a + b
    a = b
    b = c
    acc = acc ~ c
  end
  return mix_checksum(acc, a ~ b)
end

local function work_fibonacci_recursive(seed)
  return fib_recursive_impl(31 + (seed & 1))
end

local function work_float2string(seed)
  local acc = 0
  for i = 1, 12000 do
    local value = math.sin((i + seed) * 0.01) * 10000.0
    local text = string.format("%.9f", value)
    acc = mix_checksum(acc, #text + string.byte(text, 1))
  end
  return acc
end

local function work_mandelbrot(seed)
  local size = 96
  local offset = (seed & 7) * 0.0001
  local acc = 0
  for y = 0, size - 1 do
    for x = 0, size - 1 do
      local cr = (x / size) * 3.0 - 2.0 + offset
      local ci = (y / size) * 2.0 - 1.0 - offset
      local zr, zi, iter = 0.0, 0.0, 0
      while ((zr * zr + zi * zi) <= 4.0 and iter < 80) do
        local next_r = zr * zr - zi * zi + cr
        zi = 2.0 * zr * zi + ci
        zr = next_r
        iter = iter + 1
      end
      acc = acc + iter
    end
  end
  return acc
end

local function work_native_loop(seed)
  local acc = seed
  for i = 0, 4000000 do
    acc = (acc + ((i * 3) ~ (i >> 2))) & 0xffffffffffffffff
  end
  return acc
end

local function work_primes_loop(seed)
  local limit = 50000 + (seed & 15)
  local is_prime = {}
  for i = 0, limit do is_prime[i] = true end
  is_prime[0] = false
  is_prime[1] = false
  local i = 2
  while i * i <= limit do
    if is_prime[i] then
      local j = i * i
      while j <= limit do
        is_prime[j] = false
        j = j + i
      end
    end
    i = i + 1
  end
  local acc = 0
  for n = 2, limit do
    if is_prime[n] then acc = acc + n end
  end
  return acc
end

local function work_queen(seed)
  return solve_queen_impl(0, 11 + (seed & 1), 0, 0, 0)
end

local function work_sort(seed)
  local values = {}
  for i = 1, 2048 do
    values[i] = mix32((i + seed * 17 + 1234) & 0xffffffff)
  end
  table.sort(values)
  local acc = 0
  for i = 1, #values, 31 do
    acc = mix_checksum(acc, values[i])
  end
  return acc
end

local function work_string2float(seed)
  local acc = 0
  for i = 1, 12000 do
    local text = tostring(((i + seed) % 97) * 0.03125 + 10.0)
    local value = tonumber(text) or 0.0
    acc = mix_checksum(acc, math.floor(value * 100000.0) + #text)
  end
  return acc
end

local function checksum_tree(node)
  if node == nil then return 0 end
  return node.value + checksum_tree(node.left) + checksum_tree(node.right)
end

local function make_tree(depth, seed)
  local node = { value = seed }
  if depth > 0 then
    node.left = make_tree(depth - 1, seed * 2 + 1)
    node.right = make_tree(depth - 1, seed * 2 + 2)
  end
  return node
end

local function work_tree(seed)
  local tree = make_tree(13, 1 + seed)
  return checksum_tree(tree)
end

local function run_repeat(repeat_count, work)
  local acc = 0
  for i = 0, repeat_count - 1 do
    acc = mix_checksum(acc, work(i))
  end
  return acc
end

function benchmark_dictionary(repeat_count) return run_repeat(repeat_count, work_dictionary) end
function benchmark_exp_loop(repeat_count) return run_repeat(repeat_count, work_exp_loop) end
function benchmark_fibonacci_loop(repeat_count) return run_repeat(repeat_count, work_fibonacci_loop) end
function benchmark_fibonacci_recursive(repeat_count) return run_repeat(repeat_count, work_fibonacci_recursive) end
function benchmark_float2string(repeat_count) return run_repeat(repeat_count, work_float2string) end
function benchmark_mandelbrot(repeat_count) return run_repeat(repeat_count, work_mandelbrot) end
function benchmark_native_loop(repeat_count) return run_repeat(repeat_count, work_native_loop) end
function benchmark_primes_loop(repeat_count) return run_repeat(repeat_count, work_primes_loop) end
function benchmark_queen(repeat_count) return run_repeat(repeat_count, work_queen) end
function benchmark_sort(repeat_count) return run_repeat(repeat_count, work_sort) end
function benchmark_string2float(repeat_count) return run_repeat(repeat_count, work_string2float) end
function benchmark_tree(repeat_count) return run_repeat(repeat_count, work_tree) end
