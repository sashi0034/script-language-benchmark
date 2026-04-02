#include "../../common/benchmark_common.h"
#include "../../common/benchmark_workloads.h"

#include "../angelscript-2.38.0/sdk/add_on/scriptarray/scriptarray.h"
#include "../angelscript-2.38.0/sdk/add_on/scriptbuilder/scriptbuilder.h"
#include "../angelscript-2.38.0/sdk/add_on/scriptstdstring/scriptstdstring.h"
#include "../angelscript-2.38.0/sdk/add_on/scriptdictionary/scriptdictionary.h"
#include "../angelscript-2.38.0/sdk/add_on/scriptmath/scriptmath.h"
#include "../angelscript-2.38.0/sdk/angelscript/include/angelscript.h"

#include <cmath>
#include <filesystem>
#include <functional>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

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

std::uint64_t execute_function(asIScriptContext *ctx, asIScriptFunction *fn, int repeat_count) {
    require(ctx->Prepare(fn), "failed to prepare AngelScript function");
    require(ctx->SetArgDWord(0, static_cast<asDWORD>(repeat_count)), "failed to set AngelScript arg");
    const int exec = ctx->Execute();
    if (exec != asEXECUTION_FINISHED) {
        throw std::runtime_error("AngelScript execution failed with code " + std::to_string(exec));
    }
    return static_cast<std::uint64_t>(ctx->GetReturnQWord());
}

double exp_double(double value) {
    return std::exp(value);
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
    RegisterScriptArray(engine, true);
    RegisterStdString(engine);
    RegisterScriptDictionary(engine);
    RegisterScriptMath(engine);
    require(engine->RegisterGlobalFunction("double exp(double)", asFUNCTION(exp_double), asCALL_CDECL),
            "failed to register exp");

    try {
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
            const std::string decl = std::string("uint64 benchmark_") + item.name + "(int)";
            asIScriptFunction *fn = module->GetFunctionByDecl(decl.c_str());
            const bool missing_script_fn = (fn == nullptr);
            slc::BenchmarkSample sample;
            if (missing_script_fn) {
                std::cerr << "[AngelScript] missing script function '" << item.name << "', recording zero time\n";
                sample.name = item.name;
                sample.repeat_count = item.repeat_count;
            } else {
                sample = slc::run_benchmark_sample(item, [&](int repeat_count) {
                    slc::consume(execute_function(ctx.get(), fn, repeat_count));
                });
            }

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
