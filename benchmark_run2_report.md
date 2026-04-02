# Benchmark Run 2 Report

## Summary
- Winner counts by runtime: AngelScript 4, Daslang 10, Lua 2.
- Harness parity is enforced by C:\dev\lang\script-language-benchmarks\common\benchmark_common.h, which populates `slc::benchmark_items()` and the `run_benchmark_sample` timing loop, while C:\dev\lang\script-language-benchmarks\common\benchmark_workloads.h drives the identical native fallback list when a script-level function is missing.

## Measurement Environment
- Run timestamp: 2026-04-02 16:17:20 JST (UTC+9)
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
| dictionary | 1.320 | 1.087 | 3.954 | Daslang |
| exp_loop | 1.204 | 1.091 | 9.032 | Daslang |
| fibonacci_loop | 57.769 | 18.795 | 25.854 | Daslang |
| fibonacci_recursive | 777.254 | 263.701 | 578.521 | Daslang |
| float2string | 18.805 | 19.042 | 41.009 | AngelScript |
| mandelbrot | 58.785 | 32.103 | 47.228 | Daslang |
| n_bodies | 0.217 | 0.218 | 0.214 | Lua |
| native_loop | 8.767 | 8.555 | 299.893 | Daslang |
| particles_kinematics | 6.689 | 7.399 | 6.704 | AngelScript |
| primes_loop | 29.714 | 8.079 | 12.921 | Daslang |
| queen | 245.728 | 129.541 | 208.761 | Daslang |
| sha256 | 3.941 | 4.237 | 3.941 | AngelScript |
| sort | 338.213 | 103.294 | 4.058 | Lua |
| spectral_norm | 3.830 | 3.630 | 3.703 | Daslang |
| string2float | 34.216 | 34.754 | 47.456 | AngelScript |
| tree | 4.887 | 4.651 | 30.922 | Daslang |

## Notes
- Raw JSON snapshots for this pass live under C:\dev\lang\script-language-benchmarks\bench_runs\run2\*.json.
- When a runtime does not expose a script function for a workload (e.g., dictionary, exp_loop, float2string, n_bodies, native_loop, particles_kinematics, sha256, spectral_norm, string2float, and tree for AngelScript/Daslang, plus n_bodies/particles_kinematics/sha256/spectral_norm for Lua), `slc::run_named_native_workload` from the shared common harness executes the same native implementation every time.
