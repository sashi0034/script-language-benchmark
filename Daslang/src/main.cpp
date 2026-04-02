#include "../../common/benchmark_common.h"
#include "../../common/benchmark_workloads.h"

#include "../vendor/daScript/include/daScript/ast/ast.h"
#include "../vendor/daScript/include/daScript/ast/ast_interop.h"
#include "../vendor/daScript/include/daScript/daScript.h"
#include "../vendor/daScript/include/daScript/simulate/aot.h"

#include <filesystem>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

using namespace das;

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
                const auto result = das_invoke_function_by_name<std::uint64_t>::invoke<int>(
                    &ctx, nullptr, fn_name.c_str(), repeat_count);
                if (const char *ex = ctx.getException()) {
                    throw std::runtime_error(std::string("daslang exception: ") + ex);
                }
                slc::consume(result);
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
