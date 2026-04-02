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

The current harness is script-centric. The benchmark logic now lives in [AngelScript/scripts/bench.as](/C:/dev/lang/script-language-comparison/AngelScript/scripts/bench.as) and [Daslang/scripts/bench.das](/C:/dev/lang/script-language-comparison/Daslang/scripts/bench.das), with the C++ host only compiling the script, invoking exported functions, timing them, and mixing each returned checksum into the shared sink. This makes the comparison much closer to "same algorithm written in each scripting language" rather than "script loop calling native C++ work."

## Result Table

| item | AngelScript best ms | Daslang best ms | winner |
| --- | ---: | ---: | --- |
| arithmetic mix | 216.667 | 125.436 | Daslang |
| fibonacci loop | 54.184 | 20.554 | Daslang |
| fibonacci recursive | 765.497 | 272.921 | Daslang |
| mandelbrot | 58.253 | 31.971 | Daslang |
| primes loop | 28.351 | 8.971 | Daslang |
| queen | 254.830 | 134.626 | Daslang |
| sort | 335.327 | 108.345 | Daslang |

## Takeaways

- Win count:
  - AngelScript: 0
  - Daslang: 7
- This revised harness is not directly comparable to the old report, because the workload has shifted from native C++ functions to script-authored algorithms.
- The new set focuses on script-executed control flow, recursion, array manipulation, sieve/sort logic, and numeric iteration.
- Both runtimes produced the same final sink value, which is a useful sanity check that the benchmarked logic is semantically aligned.

## Project Files

- Shared timing harness and JSON writer:
  - [common/benchmark_common.h](/C:/dev/lang/script-language-comparison/common/benchmark_common.h)
- AngelScript runner:
  - [AngelScript/CMakeLists.txt](/C:/dev/lang/script-language-comparison/AngelScript/CMakeLists.txt)
  - [AngelScript/src/main.cpp](/C:/dev/lang/script-language-comparison/AngelScript/src/main.cpp)
  - [AngelScript/scripts/bench.as](/C:/dev/lang/script-language-comparison/AngelScript/scripts/bench.as)
- Daslang runner:
  - [Daslang/CMakeLists.txt](/C:/dev/lang/script-language-comparison/Daslang/CMakeLists.txt)
  - [Daslang/src/main.cpp](/C:/dev/lang/script-language-comparison/Daslang/src/main.cpp)
  - [Daslang/scripts/bench.das](/C:/dev/lang/script-language-comparison/Daslang/scripts/bench.das)

## Notes

- `Daslang` build still emits MSVC `C4819` warnings from vendored headers, but the benchmark executable built and ran successfully.
- The script workloads intentionally take a runtime seed per repeat to avoid aggressive constant folding and to keep the measured work on the script side.
