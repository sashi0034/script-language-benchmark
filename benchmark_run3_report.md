# Benchmark Run 3 Report

## Summary
- Winner counts by runtime: AngelScript 4, Daslang 10, Lua 2.
- Harness parity is enforced by C:\dev\lang\script-language-benchmarks\common\benchmark_common.h, which populates `slc::benchmark_items()` and the `run_benchmark_sample` timing loop, while C:\dev\lang\script-language-benchmarks\common\benchmark_workloads.h drives the identical native fallback list when a script-level function is missing.

## Measurement Environment
- Run timestamp: 2026-04-02 16:17:42 JST (UTC+9)
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
| dictionary | 1.192 | 1.127 | 4.081 | Daslang |
| exp_loop | 1.140 | 1.113 | 9.501 | Daslang |
| fibonacci_loop | 52.941 | 18.571 | 25.993 | Daslang |
| fibonacci_recursive | 767.039 | 263.237 | 582.485 | Daslang |
| float2string | 17.961 | 18.989 | 41.457 | AngelScript |
| mandelbrot | 58.493 | 32.415 | 47.735 | Daslang |
| n_bodies | 0.218 | 0.213 | 0.213 | Daslang |
| native_loop | 9.151 | 8.754 | 300.258 | Daslang |
| particles_kinematics | 6.548 | 6.569 | 6.573 | AngelScript |
| primes_loop | 28.756 | 7.779 | 12.954 | Daslang |
| queen | 247.075 | 131.771 | 210.060 | Daslang |
| sha256 | 3.787 | 4.168 | 3.821 | AngelScript |
| sort | 339.241 | 103.575 | 3.949 | Lua |
| spectral_norm | 3.633 | 3.631 | 3.630 | Lua |
| string2float | 34.399 | 35.829 | 47.597 | AngelScript |
| tree | 4.873 | 4.584 | 31.678 | Daslang |

## Notes
- Raw JSON snapshots for this pass live under C:\dev\lang\script-language-benchmarks\bench_runs\run3\*.json.
- When a runtime does not expose a script function for a workload (e.g., dictionary, exp_loop, float2string, n_bodies, native_loop, particles_kinematics, sha256, spectral_norm, string2float, and tree for AngelScript/Daslang, plus n_bodies/particles_kinematics/sha256/spectral_norm for Lua), `slc::run_named_native_workload` from the shared common harness executes the same native implementation every time.
