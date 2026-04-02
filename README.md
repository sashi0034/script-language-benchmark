# Script Language Benchmarks

> **Notice:** This project has primarily been developed using Codex.


A side-by-side benchmark suite that compares the runtime performance of three scripting engines—AngelScript, Daslang, and Lua—across sixteen workloads of varying compute and memory patterns. Each engine has its own CMake project and executable under `build-<engine>/Release`, and the benchmark reporting is kept alongside the binaries for easy reference.

## Workloads
The suite drives the workloads listed in `comparison_items.md`. They cover algorithmic, numeric, and string-heavy tasks:

- dictionary
- exp_loop
- fibonacci_loop
- fibonacci_recursive
- float2string
- mandelbrot
- n_bodies
- native_loop
- particles_kinematics
- primes_loop
- queen
- sha256
- sort
- spectral_norm
- string2float
- tree

## Workload Scripts
Each language bundles the workload implementations inside one script under `scripts/`. Open the path below to inspect how the tasks listed above are coded for each engine:

| Engine | Script file |
| --- | --- |
| AngelScript | [AngelScript/scripts/bench.as](AngelScript/scripts/bench.as) |
| Daslang | [Daslang/scripts/bench.das](Daslang/scripts/bench.das) |
| Lua | [Lua/scripts/bench.lua](Lua/scripts/bench.lua) |

## Latest Benchmarks (report dated April 2 2026)
| item | AngelScript | Daslang | Lua | winner |
| --- | ---: | ---: | ---: | --- |
| dictionary | 1.192 | 1.087 | 3.954 | Daslang |
| exp_loop | 1.114 | 1.091 | 9.032 | Daslang |
| fibonacci_loop | 52.941 | 18.536 | 25.854 | Daslang |
| fibonacci_recursive | 762.154 | 263.237 | 578.521 | Daslang |
| float2string | 17.775 | 18.944 | 41.009 | AngelScript |
| mandelbrot | 58.353 | 31.189 | 47.228 | Daslang |
| n_bodies | 0.213 | 0.213 | 0.213 | AngelScript / Daslang / Lua |
| native_loop | 8.615 | 8.555 | 295.265 | Daslang |
| particles_kinematics | 6.398 | 6.486 | 6.573 | AngelScript |
| primes_loop | 28.449 | 7.716 | 12.921 | Daslang |
| queen | 243.795 | 129.541 | 208.761 | Daslang |
| sha256 | 3.787 | 4.168 | 3.821 | AngelScript |
| sort | 338.213 | 103.294 | 3.949 | Lua |
| spectral_norm | 3.633 | 3.630 | 3.630 | Daslang / Lua |
| string2float | 34.216 | 34.754 | 47.020 | AngelScript |
| tree | 4.873 | 4.584 | 30.922 | Daslang |

## Measurement Environment
- Date: April 2, 2026
- Host OS: Windows 10.0.26200.8117
- Generator: Visual Studio 17 2022
- Configuration: `Release`
- Executables:
  - `build-angelscript/Release/angelscript_benchmark.exe`
  - `build-daslang/Release/daslang_benchmark.exe`
  - `build-lua/Release/lua_benchmark.exe`

## Building a Benchmark
Each language lives in its own top-level directory (`AngelScript`, `Daslang`, `Lua`). To build the release benchmark for a given engine, run CMake from the repository root:

```powershell
cmake -S AngelScript -B build-angelscript -G "Visual Studio 17 2022" -A x64
cmake --build build-angelscript --config Release --target angelscript_benchmark
```

Repeat the same pattern for `Daslang` (target `daslang_benchmark`) and `Lua` (target `lua_benchmark`).

## Running Benchmarks
Each built executable prints the timing results to `bench_runs/` and to a Markdown report such as `benchmark_run1_report.md`. Rerun the benchmark suite by invoking the desired executable directly:

```powershell
build-daslang/Release/daslang_benchmark.exe
```

After execution, compare the generated report with the previous run to track regressions or improvements.

## Adding or Updating Workloads
1. Update `comparison_items.md` with the new workload name.
2. Implement the workload logic in each scripting engine's source tree following the existing patterns.
3. Rebuild the engines and rerun the benchmarks.
4. Append the fresh report to `bench_runs/` and regenerate `benchmark_report.md` as needed.

## Reporting
Hand-curated reports such as `benchmark_report.md` and `benchmark_run*.md` capture the per-workload timings and winning engines. Reviewing these files after every benchmark run keeps observations consistent and reproducible.
