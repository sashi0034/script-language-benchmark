# Script Language Benchmark Report

## Summary

- Re-ran all 16 workloads listed in `comparison_items.md`.
- Measured three runtimes: AngelScript, Daslang, and Lua.
- Winner counts by best time: AngelScript 7, Daslang 6, Lua 3.
- Daslang led the recursive and numeric-heavy scripted workloads, AngelScript led several mixed/native cases, and Lua dominated `sort`.

## Measurement Environment

- Date: 2026-04-02
- OS: Windows 10.0.26200.8117
- Generator: Visual Studio 17 2022
- Configuration: `Release`
- Executed binaries:
  - `build-angelscript/Release/angelscript_benchmark.exe`
  - `build-daslang/Release/daslang_benchmark.exe`
  - `build-lua/Release/lua_benchmark.exe`

## Result Table (best ms)

| item | AngelScript | Daslang | Lua | winner |
| --- | ---: | ---: | ---: | --- |
| dictionary | 1.197 | 1.141 | 4.075 | Daslang |
| exp_loop | 1.091 | 1.116 | 9.299 | AngelScript |
| fibonacci_loop | 53.927 | 18.800 | 26.635 | Daslang |
| fibonacci_recursive | 770.252 | 267.801 | 594.760 | Daslang |
| float2string | 18.176 | 19.399 | 41.554 | AngelScript |
| mandelbrot | 57.921 | 32.655 | 47.323 | Daslang |
| n_bodies | 0.218 | 0.222 | 0.222 | AngelScript |
| native_loop | 8.805 | 8.898 | 299.273 | AngelScript |
| particles_kinematics | 6.529 | 6.746 | 6.579 | AngelScript |
| primes_loop | 28.205 | 8.299 | 13.688 | Daslang |
| queen | 245.499 | 131.942 | 208.232 | Daslang |
| sha256 | 4.191 | 4.311 | 4.134 | Lua |
| sort | 347.145 | 105.581 | 4.122 | Lua |
| spectral_norm | 3.785 | 3.781 | 3.779 | Lua |
| string2float | 35.100 | 35.647 | 48.801 | AngelScript |
| tree | 4.851 | 4.960 | 29.998 | AngelScript |

## Notes

- Result JSON files were refreshed at:
  - `AngelScript/results/angelscript_results.json`
  - `Daslang/results/daslang_results.json`
  - `Lua/results/lua_results.json`
- Some workloads still fall back to native C++ implementations when a runtime-specific script implementation is not present. That affects cross-language interpretation of `dictionary`, `exp_loop`, `float2string`, `n_bodies`, `native_loop`, `particles_kinematics`, `sha256`, `spectral_norm`, `string2float`, and `tree` for AngelScript and Daslang, and `n_bodies`, `particles_kinematics`, `sha256`, and `spectral_norm` for Lua.
- Lua required a Windows-specific CMake fix so that `m` is only linked on non-Windows platforms.
