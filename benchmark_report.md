# Script Language Benchmark Report

## Summary

- Aggregated best times are taken from the three sequential runs (2026-04-02 16:16:58, 16:17:20, and 16:17:42 JST) so each workload reflects the fastest est_ms recorded for each runtime.
- Winner counts by runtime are AngelScript 4, Daslang 9, and Lua 1; 
_bodies and spectral_norm ended in repeated ties because they hit the same low latency for two or all three runtimes.
- The shared harness in common/benchmark_common.h and common/benchmark_workloads.h keeps the workloads and native fallbacks identical whenever a script implementation is missing.

## Measurement Environment

- Run timestamps: 2026-04-02 16:16:58, 16:17:20, and 16:17:42 JST (UTC+9).
- Date: 2026-04-02
- OS: Windows 10.0.26200.8117
- Generator: Visual Studio 17 2022
- Configuration: Release
- Executables:
  - uild-angelscript/Release/angelscript_benchmark.exe
  - uild-daslang/Release/daslang_benchmark.exe
  - uild-lua/Release/lua_benchmark.exe

## Result Table (best ms)

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

## Notes

- Raw JSON snapshots for the three passes live under ench_runs/run1/*.json, ench_runs/run2/*.json, and ench_runs/run3/*.json.
- When a runtime does not expose a script function for a workload (e.g., dictionary, exp_loop, float2string, n_bodies, native_loop, particles_kinematics, sha256, spectral_norm, string2float, and tree for AngelScript/Daslang, plus n_bodies, particles_kinematics, sha256, and spectral_norm for Lua), slc::run_named_native_workload executes the same native path every time.
- No recorded est_ms value equals 0 across the aggregated dataset, so there is no zero-based measurement bug to fix.
- The 
_bodies workload hits 0.213 ms across all three runtimes and spectral_norm records 3.63 ms for both Daslang and Lua, so the table calls out those repeated ties.
