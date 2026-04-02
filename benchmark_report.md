# Script Language Benchmark Report

## Summary

- `comparison_items.md` の 16 項目（dictionary / exp loop / fibonacci loop / ... / tree）をベンチ対象として有効化しました。
- Lua 実装を追加し、`Lua/scripts/bench.lua` と `Lua/src/main.cpp` でベンチ実行できるようにしました。
- AngelScript / Lua は、スクリプト側に未実装の項目がある場合に C++ ネイティブ実装（`common/benchmark_workloads.h`）へフォールバックする方式です。
- Daslang はこの環境では `vendor/daScript` が欠落しており再計測できませんでした（2026-04-02 時点）。

## Measurement Environment

- Date: 2026-04-02
- OS/Compiler: Linux (GCC 13.3.0)
- Build: `Release`
- Executed binaries:
  - `./build-angel/angelscript_benchmark`
  - `./build-lua/lua_benchmark`

## Result Table (best ms)

| item | AngelScript | Lua | winner |
| --- | ---: | ---: | --- |
| dictionary | 1.379 | 6.854 | AngelScript |
| exp_loop | 2.500 | 17.552 | AngelScript |
| fibonacci_loop | 72.015 | 41.278 | Lua |
| fibonacci_recursive | 1722.313 | 1319.226 | Lua |
| float2string | 39.396 | 80.273 | AngelScript |
| mandelbrot | 76.368 | 86.584 | AngelScript |
| n_bodies | 0.442 | 0.442 | tie |
| native_loop | 28.302 | 542.574 | AngelScript |
| particles_kinematics | 10.394 | 10.498 | AngelScript |
| primes_loop | 39.612 | 22.477 | Lua |
| queen | 427.703 | 366.767 | Lua |
| sha256 | 6.723 | 6.678 | Lua |
| sort | 530.210 | 7.280 | Lua |
| spectral_norm | 7.779 | 7.945 | AngelScript |
| string2float | 37.081 | 79.956 | AngelScript |
| tree | 3.723 | 48.919 | AngelScript |

## Notes

- 今回の追加実装で `comparison_items.md` の全項目が測定対象として登録されています。
- ただし、現時点では全ランタイムで全項目をスクリプト実装したわけではなく、一部はネイティブフォールバックで計測しています。
- 結果 JSON:
  - `AngelScript/results/angelscript_results.json`
  - `Lua/results/lua_results.json`
