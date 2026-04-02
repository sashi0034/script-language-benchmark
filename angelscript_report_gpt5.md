# AngelScript VM 内部分析レポート（Lua / Daslang との比較）

## 1. ベンチマークで見える差分
- 16 個の workloads をすべて同一の harness で回した最新版リポートでは、AngelScript が `fibonacci_` 系、`queen`、`primes_loop`、`sort` 周りで Daslang や Lua に比べて 2〜10 倍の遅延を示している一方、`float2string` や `particles_kinematics` のような native に近いループでは優位に立てていることがわかる。[benchmark_report.md](C:\dev\lang\script-language-benchmarks\benchmark_report.md:23-40)
- たとえば `fibonacci_recursive` は 770ms 対 268ms/595ms、`queen` は 245ms 対 132ms/208ms、`sort` は 347ms 対 105ms/4ms という結果になっており、AngelScript のインタプリタベースの VM が深い再帰や多重ループで命令分岐やアクセスコストに引きずられていることを示唆している。[benchmark_report.md](C:\dev\lang\script-language-benchmarks\benchmark_report.md:23-40)

## 2. AngelScript VM 内部で時間がかかっているパス
### 2.1 `asIScriptContext` の準備・実行フロー
- ベンチマークの各関数呼び出しでは `execute_function` が `ctx->Prepare` → `ctx->SetArgDWord` → `ctx->Execute` を毎回実行し、実行が終わるとリターン値を取得している。この `Prepare` が呼び出しごとに bytecode を再設定しているため、ループや再帰が repeat されるたびにインタプリタのステートリセットとスイッチ文のセットアップが走ることになる。[AngelScript/src/main.cpp](C:\dev\lang\script-language-benchmarks\AngelScript\src\main.cpp:36-103)
- 一度 `asIScriptFunction` を取得していても `ctx` を継続的に再利用して `Prepare` を呼びっぱなしにしている設計になっており、Lua や Daslang のような「コンパイル済み関数を即呼び出す」パスと比べると、関数呼び出し周辺で大きな固定費が乗ってしまっている。[AngelScript/src/main.cpp](C:\dev\lang\script-language-benchmarks\AngelScript\src\main.cpp:36-103)

### 2.2 `array<int>` のアクセスコスト
- `bench.as` では `primes_loop` や `sort` で `array<int>` を使い、スクリプト内で `values[i]` に何度もアクセスしている。[AngelScript/scripts/bench.as](C:\dev\lang\script-language-benchmarks\AngelScript\scripts\bench.as:85-134)
- `array<T>` は `CScriptArray::At` や `SetValue` 経由で要素にアクセスするため、`At` で境界チェックと ScriptContext 例外の準備、`SetValue` での `At` 呼び出し・ハンドル参照カウント処理などが毎回入り、内側ループでは bytecode + 系列化されたチェックにより純粋な整数操作より大きなオーバーヘッドが積み重なる。[AngelScript/angelscript-2.38.0/sdk/add_on/scriptarray/scriptarray.h](C:\dev\lang\script-language-benchmarks\AngelScript\angelscript-2.38.0\sdk\add_on\scriptarray\scriptarray.h:63-91)
- `CScriptArray::At` は `buffer == 0 || index >= buffer->numElements` の分岐でアウトオブバウンドを探し、コンテキストが存在すれば例外をセットして 0 を返す実装になっているため、数千万回のループで branch misprediction が起きやすい。[AngelScript/angelscript-2.38.0/sdk/add_on/scriptarray/scriptarray.cpp](C:\dev\lang\script-language-benchmarks\AngelScript\angelscript-2.38.0\sdk\add_on\scriptarray\scriptarray.cpp:951-966)
- `CScriptArray::SetValue` も内部で `At` を呼び出しており、その戻り値が 0 でないか (and handling handles) をチェックしてから copy/assign するため、`values[j + 1] = values[j]` などの操作が、単に配列バッファを上書きするよりも多くのステップを踏む。[AngelScript/angelscript-2.38.0/sdk/add_on/scriptarray/scriptarray.cpp:589-596)

### 2.3 深い再帰／再帰的関数呼び出し
- `solve_queen_impl` や `fib_recursive_impl` は再帰深度が 11〜31 と大きく、AngelScript のインタプリタ呼び出しごとに戻り値・引数の準備がまとめて行われる設計のため、再帰ごとに context の状態転送と call/return が発生しやすい。[AngelScript/scripts/bench.as](C:\dev\lang\script-language-benchmarks\AngelScript\scripts\bench.as:1-60)
- `ctx->Execute` は内部で一命令ずつスイッチをかける実装（Angelscript 本来の VM）なので、再帰呼び出しごとにスタックを走査したり命令ポインタを読み直すたびに分岐と同期が走り、再帰深度が増えるほど `fibonacci_recursive` や `queen` で顕著な時間差になる。

## 3. Lua / Daslang の実行モデルとの対比
### 3.1 Lua（登録ベースのインタプリタ）
- Lua は `luaV_execute` が register ベースのメインループで、C 側で `lua_pcall`/`lua_getglobal` して引数を置き `luaV_execute` を走らせるだけなので、関数のオーバーヘッドは基本的にスタック操作とジャンプのみで済む。[Lua/lua-5.5.0/lvm.c](C:\dev\lang\script-language-benchmarks\Lua\lua-5.5.0\lvm.c:1093-1098)
- `Lua/src/main.cpp` では `luaL_dofile` でスクリプトをロードし、各 workload の `benchmark_*` 関数をその都度 `lua_getglobal` → `lua_pcall` で呼び出すだけで、`Prepare` 相当のセットアップが入っていない。結果として Lua 側は `ctx->Prepare` を呼ばずに関数本体に着地でき、同じ repeat でも固定費が小さい。[Lua/src/main.cpp](C:\dev\lang\script-language-benchmarks\Lua\src\main.cpp:25-102)
- スクリプトでは `is_prime` や `values` に対してテーブルを素直に push/pop/`table.sort` しており、裏側の VM で多段階境界チェックなく既存の BCL と register の操作で処理される点も高速化に寄与している。[Lua/scripts/bench.lua](C:\dev\lang\script-language-benchmarks\Lua\scripts\bench.lua:111-168)

### 3.2 Daslang（AOT/コンパイル済み関数）
- Daslang は `compileDaScript` でスクリプトを一度コンパイルし、`program->simulate(ctx, tout)` で実行可能な Context を組み立てたうえで `ctx.restart()` + `das_invoke_function_by_name` というシンプルな呼び出しループを走らせている。これにより、ほぼコンパイル済み関数を何度でも連続呼び出しでき、AngelScript のような `Prepare` や bytecode スイッチのリセットを回避できる。[Daslang/src/main.cpp](C:\dev\lang\script-language-benchmarks\Daslang\src\main.cpp:33-108)
- `bench.das` は `array<int>` を `resize` して直接 `values[i]` をインデックスアクセスし、`work_sort`/`work_primes_loop` などのループを静的型で書いているため、コンパイル時に bounds チェックを最小限にでき、Daslang 側の VM/JIT が高度に最適化されたパスにジャンプできる。[Daslang/scripts/bench.das](C:\dev\lang\script-language-benchmarks\Daslang\scripts\bench.das:1-140)

## 4. まとめと提案
- AngelScript の遅延は `ctx->Prepare` の繰り返し、`CScriptArray` による必須の bounds/GC チェック、そして再帰による call/return branching の三つが主因で、Lua の register ベースな `lua_pcall` や Daslang のコンパイル済み関数と比較すると固定費が大きい。
- 対策候補:
  1. `asIScriptContext` を workload ごとに `Prepare` したら `run_benchmark_sample` 内では `ctx->Execute` だけを呼び、repeat ごとに `Prepare` をスキップして命令ポインタだけをワークロードに委ねる。
  2. `array<int>` を使うループでは `CScriptArray::GetBuffer`/`GetDataPointer` を使って生のポインタを取得し、Angelscript スクリプトからは `array` を避けてネイティブの整数キャッシュを手動でまわす。
  3. 再帰や深いループをネイティブ関数に置き換える（すでに存在する `slc::run_named_native_workload` を使う）か、`asIScriptGeneric` や AOT で事前コンパイルし `ctx->SetFunction` を呼ぶことで関数呼び出しのランタイム分岐を減らす。
- これらを踏まえて再ベンチマークすることで、AngelScript が Lua/Daslang に追いつくか、少なくとも再帰／配列アクセスパスでのボトルネックが改善できているかを確認する。

