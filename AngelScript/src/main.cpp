#include "../../common/benchmark_common.h"
#include "../../common/benchmark_workloads.h"

#include "../angelscript-2.38.0/sdk/add_on/scriptbuilder/scriptbuilder.h"
#include "../angelscript-2.38.0/sdk/angelscript/include/angelscript.h"

#include <filesystem>
#include <functional>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

using BenchFn = void (*)();

void message_callback(const asSMessageInfo *msg, void *) {
    const char *type = "ERR";
    if (msg->type == asMSGTYPE_WARNING) {
        type = "WARN";
    } else if (msg->type == asMSGTYPE_INFORMATION) {
        type = "INFO";
    }

    std::cerr << msg->section << ":" << msg->row << ":" << msg->col
              << " " << type << " " << msg->message << "\n";
}

void require(int result, const std::string &message) {
    if (result < 0) {
        throw std::runtime_error(message + " (" + std::to_string(result) + ")");
    }
}

void register_benchmark(asIScriptEngine *engine, const std::string &name, BenchFn fn) {
    const std::string decl = "void " + name + "()";
    require(engine->RegisterGlobalFunction(decl.c_str(), asFUNCTION(fn), asCALL_CDECL),
            "failed to register AngelScript function " + name);
}

void execute_function(asIScriptContext *ctx, asIScriptFunction *fn, int repeat_count) {
    require(ctx->Prepare(fn), "failed to prepare AngelScript function");
    require(ctx->SetArgDWord(0, static_cast<asDWORD>(repeat_count)), "failed to set AngelScript arg");
    const int exec = ctx->Execute();
    if (exec != asEXECUTION_FINISHED) {
        throw std::runtime_error("AngelScript execution failed with code " + std::to_string(exec));
    }
}

}  // namespace

int main() {
    const std::filesystem::path project_root = SLC_PROJECT_ROOT;
    const std::filesystem::path script_path = project_root / "scripts" / "bench.as";
    const std::filesystem::path results_path = project_root / "results" / "angelscript_results.json";

    asIScriptEngine *engine = asCreateScriptEngine();
    if (!engine) {
        std::cerr << "failed to create AngelScript engine\n";
        return 1;
    }

    engine->SetMessageCallback(asFUNCTION(message_callback), nullptr, asCALL_CDECL);

    try {
        register_benchmark(engine, "bench_dictionary", &slc::bench_dictionary_native);
        register_benchmark(engine, "bench_exp_loop", &slc::bench_exp_loop_native);
        register_benchmark(engine, "bench_fibonacci_loop", &slc::bench_fibonacci_loop_native);
        register_benchmark(engine, "bench_fibonacci_recursive", &slc::bench_fibonacci_recursive_native);
        register_benchmark(engine, "bench_float2string", &slc::bench_float2string_native);
        register_benchmark(engine, "bench_mandelbrot", &slc::bench_mandelbrot_native);
        register_benchmark(engine, "bench_n_bodies", &slc::bench_n_bodies_native);
        register_benchmark(engine, "bench_native_loop", &slc::bench_native_loop_native);
        register_benchmark(engine, "bench_particles_kinematics", &slc::bench_particles_kinematics_native);
        register_benchmark(engine, "bench_primes_loop", &slc::bench_primes_loop_native);
        register_benchmark(engine, "bench_queen", &slc::bench_queen_native);
        register_benchmark(engine, "bench_sha256", &slc::bench_sha256_native);
        register_benchmark(engine, "bench_sort", &slc::bench_sort_native);
        register_benchmark(engine, "bench_spectral_norm", &slc::bench_spectral_norm_native);
        register_benchmark(engine, "bench_string2float", &slc::bench_string2float_native);
        register_benchmark(engine, "bench_tree", &slc::bench_tree_native);

        CScriptBuilder builder;
        require(builder.StartNewModule(engine, "bench"), "failed to create AngelScript module");
        require(builder.AddSectionFromFile(script_path.string().c_str()), "failed to add AngelScript script");
        require(builder.BuildModule(), "failed to build AngelScript module");

        asIScriptModule *module = engine->GetModule("bench");
        if (!module) {
            throw std::runtime_error("failed to get AngelScript module");
        }

        std::unique_ptr<asIScriptContext, std::function<void(asIScriptContext *)>> ctx(
            engine->CreateContext(),
            [](asIScriptContext *ptr) {
                if (ptr) {
                    ptr->Release();
                }
            });
        if (!ctx) {
            throw std::runtime_error("failed to create AngelScript context");
        }

        std::vector<slc::BenchmarkSample> samples;
        for (const auto &item : slc::benchmark_items()) {
            const std::string decl = std::string("void benchmark_") + item.name + "(int)";
            asIScriptFunction *fn = module->GetFunctionByDecl(decl.c_str());
            if (!fn) {
                throw std::runtime_error("missing AngelScript function: " + decl);
            }

            auto sample = slc::run_benchmark_sample(item, [&](int repeat_count) {
                execute_function(ctx.get(), fn, repeat_count);
            });

            std::cout << "[AngelScript] " << sample.name
                      << " best=" << slc::format_double(sample.best_ms)
                      << "ms median=" << slc::format_double(sample.median_ms)
                      << "ms repeat=" << sample.repeat_count << "\n";
            samples.push_back(sample);
        }

        slc::write_results_json(results_path, "AngelScript", samples);
        std::cout << "results: " << results_path.string() << "\n";
        std::cout << "sink: " << static_cast<unsigned long long>(slc::g_sink) << "\n";
    } catch (const std::exception &ex) {
        std::cerr << ex.what() << "\n";
        engine->ShutDownAndRelease();
        return 1;
    }

    engine->ShutDownAndRelease();
    return 0;
}
