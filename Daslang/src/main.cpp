#include "../../common/benchmark_common.h"
#include "../../common/benchmark_workloads.h"

#include "../vendor/daScript/include/daScript/ast/ast.h"
#include "../vendor/daScript/include/daScript/ast/ast_interop.h"
#include "../vendor/daScript/include/daScript/daScript.h"

#include <filesystem>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

using namespace das;

class Module_Benchmark : public Module {
public:
    Module_Benchmark() : Module("benchmark") {
        ModuleLibrary lib(this);
        lib.addBuiltInModule();

        addExtern<DAS_BIND_FUN(slc::bench_dictionary_native)>(*this, lib, "bench_dictionary", SideEffects::modifyExternal, "bench_dictionary");
        addExtern<DAS_BIND_FUN(slc::bench_exp_loop_native)>(*this, lib, "bench_exp_loop", SideEffects::modifyExternal, "bench_exp_loop");
        addExtern<DAS_BIND_FUN(slc::bench_fibonacci_loop_native)>(*this, lib, "bench_fibonacci_loop", SideEffects::modifyExternal, "bench_fibonacci_loop");
        addExtern<DAS_BIND_FUN(slc::bench_fibonacci_recursive_native)>(*this, lib, "bench_fibonacci_recursive", SideEffects::modifyExternal, "bench_fibonacci_recursive");
        addExtern<DAS_BIND_FUN(slc::bench_float2string_native)>(*this, lib, "bench_float2string", SideEffects::modifyExternal, "bench_float2string");
        addExtern<DAS_BIND_FUN(slc::bench_mandelbrot_native)>(*this, lib, "bench_mandelbrot", SideEffects::modifyExternal, "bench_mandelbrot");
        addExtern<DAS_BIND_FUN(slc::bench_n_bodies_native)>(*this, lib, "bench_n_bodies", SideEffects::modifyExternal, "bench_n_bodies");
        addExtern<DAS_BIND_FUN(slc::bench_native_loop_native)>(*this, lib, "bench_native_loop", SideEffects::modifyExternal, "bench_native_loop");
        addExtern<DAS_BIND_FUN(slc::bench_particles_kinematics_native)>(*this, lib, "bench_particles_kinematics", SideEffects::modifyExternal, "bench_particles_kinematics");
        addExtern<DAS_BIND_FUN(slc::bench_primes_loop_native)>(*this, lib, "bench_primes_loop", SideEffects::modifyExternal, "bench_primes_loop");
        addExtern<DAS_BIND_FUN(slc::bench_queen_native)>(*this, lib, "bench_queen", SideEffects::modifyExternal, "bench_queen");
        addExtern<DAS_BIND_FUN(slc::bench_sha256_native)>(*this, lib, "bench_sha256", SideEffects::modifyExternal, "bench_sha256");
        addExtern<DAS_BIND_FUN(slc::bench_sort_native)>(*this, lib, "bench_sort", SideEffects::modifyExternal, "bench_sort");
        addExtern<DAS_BIND_FUN(slc::bench_spectral_norm_native)>(*this, lib, "bench_spectral_norm", SideEffects::modifyExternal, "bench_spectral_norm");
        addExtern<DAS_BIND_FUN(slc::bench_string2float_native)>(*this, lib, "bench_string2float", SideEffects::modifyExternal, "bench_string2float");
        addExtern<DAS_BIND_FUN(slc::bench_tree_native)>(*this, lib, "bench_tree", SideEffects::modifyExternal, "bench_tree");
    }
};

REGISTER_MODULE(Module_Benchmark);

namespace {

void throw_if_program_failed(const ProgramPtr &program, TextPrinter &tout) {
    if (!program || program->failed()) {
        if (program) {
            for (const auto &err : program->errors) {
                tout << reportError(err.at, err.what, err.extra, err.fixme, err.cerr);
            }
        }
        throw std::runtime_error("daslang compilation failed");
    }
}

}  // namespace

int main() {
    const std::filesystem::path project_root = DASLANG_BENCHMARK_PROJECT_ROOT;
    const std::filesystem::path das_root = DASLANG_BENCHMARK_DAS_ROOT;
    const std::filesystem::path script_path = project_root / "scripts" / "bench.das";
    const std::filesystem::path results_path = project_root / "results" / "daslang_results.json";

    try {
        setDasRoot(das_root.string());
        register_builtin_modules();
        register_Module_Benchmark();
        Module::Initialize();
        std::cerr << "[Daslang] module init ok\n";

        TextPrinter tout;
        auto file_access = make_smart<FsFileAccess>();
        ModuleGroup lib_group;

        CodeOfPolicies policies;
        policies.version_2_syntax = true;
        policies.fail_on_no_aot = false;
        policies.fail_on_lack_of_aot_export = false;

        const auto program = compileDaScript(script_path.string(), file_access, tout, lib_group, policies);
        throw_if_program_failed(program, tout);
        std::cerr << "[Daslang] compile ok\n";

        Context ctx(program->getContextStackSize());
        if (!program->simulate(ctx, tout)) {
            throw std::runtime_error("daslang simulate failed");
        }
        std::cerr << "[Daslang] simulate ok\n";

        std::vector<slc::BenchmarkSample> samples;
        for (const auto &item : slc::benchmark_items()) {
            const std::string fn_name = std::string("benchmark_") + item.name;
            auto sample = slc::run_benchmark_sample(item, [&](int repeat_count) {
                ctx.restart();
                das_invoke_function_by_name<void>::invoke<int>(&ctx, nullptr, fn_name.c_str(), repeat_count);
                if (const char *ex = ctx.getException()) {
                    throw std::runtime_error(std::string("daslang exception: ") + ex);
                }
            });

            std::cout << "[Daslang] " << sample.name
                      << " best=" << slc::format_double(sample.best_ms)
                      << "ms median=" << slc::format_double(sample.median_ms)
                      << "ms repeat=" << sample.repeat_count << "\n";
            samples.push_back(sample);
        }

        slc::write_results_json(results_path, "Daslang", samples);
        std::cout << "results: " << results_path.string() << "\n";
        std::cout << "sink: " << static_cast<unsigned long long>(slc::g_sink) << "\n";

        Module::Shutdown();
    } catch (const std::exception &ex) {
        std::cerr << ex.what() << "\n";
        Module::Shutdown();
        return 1;
    }

    return 0;
}
