# Script Language Benchmark Report

## Summary

- Best times are taken from the latest per-runtime JSON snapshots written on 2026-04-02 at 21:46:57 (Lua), 22:20:53 (AngelScript), and 22:09:35 (Daslang) JST.
- Winner counts by runtime are AngelScript 1, Daslang 13, and Lua 2; there were no ties in this pass.
- AngelScript now binds `exp(double)` from the host so `exp_loop` runs with the intended math function instead of a script-side approximation.

## Measurement Environment

- Run timestamps (JST): 2026-04-02 21:46:57 (Lua), 22:20:53 (AngelScript), 22:09:35 (Daslang).
- Date: 2026-04-02
- OS: Windows 10.0.26200.8117
- Generator: Visual Studio 17 2022
- Configuration: Release
- Executables:
  - build-angelscript/Release/angelscript_benchmark.exe
  - build-daslang/Release/daslang_benchmark.exe
  - build-lua/Release/lua_benchmark.exe

## Result Table (best ms)

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

## Notes

- Source JSON snapshots: AngelScript/results/angelscript_results.json, Daslang/results/daslang_results.json, Lua/results/lua_results.json.
