# AngelScript / Daslang Benchmark Report

## Summary

- Measured items were taken from [comparison_items.md](/C:/dev/lang/script-language-comparison/comparison_items.md).
- Two separate C++ benchmark projects were created:
  - [AngelScript](/C:/dev/lang/script-language-comparison/AngelScript)
  - [Daslang](/C:/dev/lang/script-language-comparison/Daslang)
- Build mode: `Release`
- Toolchain: Visual Studio 2022 / x64 / CMake
- Result files:
  - [AngelScript results](/C:/dev/lang/script-language-comparison/AngelScript/results/angelscript_results.json)
  - [Daslang results](/C:/dev/lang/script-language-comparison/Daslang/results/daslang_results.json)

The current harness measures runtime overhead through an embedded C++ host. Each benchmark item is implemented as a shared native workload, and the script side repeatedly invokes that workload in a loop. This keeps the workload identical across both runtimes, but it means the numbers reflect embedded runtime call/dispatch overhead plus loop overhead, not a pure "all logic written in script" benchmark.

## Result Table

| item | AngelScript best ms | Daslang best ms | winner |
| --- | ---: | ---: | --- |
| dictionary | 1.688 | 1.312 | Daslang |
| exp loop | 1.457 | 1.367 | Daslang |
| fibonacci loop | 0.856 | 0.768 | Daslang |
| fibonacci recursive | 34.970 | 32.335 | Daslang |
| float2string | 22.882 | 24.507 | AngelScript |
| mandelbrot | 3.505 | 3.757 | AngelScript |
| n-bodies | 0.178 | 0.193 | AngelScript |
| native loop | 10.765 | 11.615 | AngelScript |
| particles kinematics | 6.450 | 6.986 | AngelScript |
| primes loop | 0.690 | 0.736 | AngelScript |
| queen | 35.051 | 39.966 | AngelScript |
| sha256 | 3.909 | 4.442 | AngelScript |
| sort | 4.392 | 4.688 | AngelScript |
| spectral norm | 3.786 | 3.893 | AngelScript |
| string2float | 42.761 | 43.527 | AngelScript |
| tree | 5.054 | 5.538 | AngelScript |

## Takeaways

- Win count:
  - AngelScript: 12
  - Daslang: 4
- Geometric mean of `AngelScript / Daslang` best-time ratio: `0.975`
  - On this harness, AngelScript was about `2.5%` faster overall.
- Daslang was better on:
  - `dictionary`
  - `exp loop`
  - `fibonacci loop`
  - `fibonacci recursive`
- AngelScript was better on the remaining 12 items, especially:
  - `queen`
  - `sha256`
  - `tree`
  - `particles kinematics`

## Project Files

- Shared workload and JSON writer:
  - [common/benchmark_common.h](/C:/dev/lang/script-language-comparison/common/benchmark_common.h)
  - [common/benchmark_workloads.h](/C:/dev/lang/script-language-comparison/common/benchmark_workloads.h)
- AngelScript runner:
  - [AngelScript/CMakeLists.txt](/C:/dev/lang/script-language-comparison/AngelScript/CMakeLists.txt)
  - [AngelScript/src/main.cpp](/C:/dev/lang/script-language-comparison/AngelScript/src/main.cpp)
  - [AngelScript/scripts/bench.as](/C:/dev/lang/script-language-comparison/AngelScript/scripts/bench.as)
- Daslang runner:
  - [Daslang/CMakeLists.txt](/C:/dev/lang/script-language-comparison/Daslang/CMakeLists.txt)
  - [Daslang/src/main.cpp](/C:/dev/lang/script-language-comparison/Daslang/src/main.cpp)
  - [Daslang/scripts/bench.das](/C:/dev/lang/script-language-comparison/Daslang/scripts/bench.das)

## Notes

- `Daslang` build emitted MSVC `C4819` warnings from vendored headers, but the benchmark executable built and ran successfully.
- If you want the next step to be a more script-heavy comparison, we should move more of each workload from C++ into each script language and keep only the minimum host bindings.
