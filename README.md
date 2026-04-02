# Script Language Benchmarks

> **Notice:** This project has primarily been developed using Codex. Please don't take the generated AI code at face value, since I still haven't properly reviewed it.


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
| dictionary | 20.888 | 2.516 | 4.025 | Daslang |
| exp_loop | 12.008 | 4.109 | 9.458 | Daslang |
| fibonacci_loop | 52.867 | 19.191 | 26.914 | Daslang |
| fibonacci_recursive | 795.218 | 266.421 | 599.702 | Daslang |
| float2string | 44.533 | 43.780 | 61.268 | Daslang |
| mandelbrot | 58.432 | 32.085 | 78.444 | Daslang |
| n_bodies | 14.322 | 4.264 | 13.874 | Daslang |
| native_loop | 505.445 | 540.573 | 506.997 | AngelScript |
| particles_kinematics | 933.839 | 440.880 | 1156.507 | Daslang |
| primes_loop | 30.016 | 14.565 | 23.000 | Daslang |
| queen | 253.849 | 241.437 | 333.410 | Daslang |
| sha256 | 321.877 | 224.411 | 549.956 | Daslang |
| sort | 328.950 | 237.142 | 6.175 | Lua |
| spectral_norm | 188.622 | 185.926 | 259.634 | Daslang |
| string2float | 84.277 | 107.174 | 68.624 | Lua |
| tree | 62.949 | 17.496 | 59.757 | Daslang |

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
