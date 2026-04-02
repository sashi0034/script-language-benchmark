# Benchmark Run 1 Report

## Summary
- Winner counts by runtime: AngelScript 5, Daslang 10, Lua 1.
- Harness parity is enforced by C:\dev\lang\script-language-benchmarks\common\benchmark_common.h, which populates `slc::benchmark_items()` and the `run_benchmark_sample` timing loop, while C:\dev\lang\script-language-benchmarks\common\benchmark_workloads.h drives the identical native fallback list when a script-level function is missing.

## Measurement Environment
- Run timestamp: 2026-04-02 16:16:58 JST (UTC+9)
- Date: 2026-04-02
- OS: Windows 10.0.26200.8117
- Generator: Visual Studio 17 2022
- Configuration: Release
- Executables:
  - `build-angelscript/Release/angelscript_benchmark.exe`
  - `build-daslang/Release/daslang_benchmark.exe`
  - `build-lua/Release/lua_benchmark.exe`

## Result Table (best ms)
| item | AngelScript | Daslang | Lua | winner |
| --- | ---: | ---: | ---: | --- |
| dictionary | 1.241 | 1.139 | 5.487 | Daslang |
| exp_loop | 1.114 | 1.091 | 9.713 | Lua |
| fibonacci_loop | 53.216 | 18.536 | 27.077 | Daslang |
| fibonacci_recursive | 762.154 | 265.669 | 587.917 | Daslang |
| float2string | 17.775 | 18.944 | 42.852 | AngelScript |
| mandelbrot | 58.353 | 31.189 | 48.587 | Daslang |
| n_bodies | 0.213 | 0.223 | 0.222 | AngelScript |
| native_loop | 8.615 | 8.569 | 295.265 | Daslang |
| particles_kinematics | 6.398 | 6.486 | 7.416 | AngelScript |
| primes_loop | 28.449 | 7.716 | 13.645 | Daslang |
| queen | 243.795 | 131.724 | 216.132 | Daslang |
| sha256 | 3.934 | 4.184 | 4.189 | AngelScript |
| sort | 338.958 | 104.375 | 4.319 | Lua |
| spectral_norm | 3.940 | 3.631 | 3.865 | Daslang |
| string2float | 34.616 | 35.514 | 47.020 | AngelScript |
| tree | 4.965 | 4.913 | 34.006 | Daslang |

## Notes
- Raw JSON snapshots for this pass live under C:\dev\lang\script-language-benchmarks\bench_runs\run1\*.json.
- When a runtime does not expose a script function for a workload (e.g., dictionary, exp_loop, float2string, n_bodies, native_loop, particles_kinematics, sha256, spectral_norm, string2float, and tree for AngelScript/Daslang, plus n_bodies/particles_kinematics/sha256/spectral_norm for Lua), `slc::run_named_native_workload` from the shared common harness executes the same native implementation every time.
