#pragma once

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <sstream>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

namespace slc {

struct BenchmarkItem {
    const char *name;
    int repeat_count;
};

inline const std::vector<BenchmarkItem> &benchmark_items() {
    static const std::vector<BenchmarkItem> items = {
        {"dictionary", 10},
        {"exp_loop", 8},
        {"fibonacci_loop", 14},
        {"fibonacci_recursive", 8},
        {"float2string", 8},
        {"mandelbrot", 8},
        {"n_bodies", 12},
        {"native_loop", 8},
        {"particles_kinematics", 10},
        {"primes_loop", 10},
        {"queen", 8},
        {"sha256", 8},
        {"sort", 10},
        {"spectral_norm", 8},
        {"string2float", 8},
        {"tree", 8},
    };
    return items;
}

struct BenchmarkSample {
    std::string name;
    int repeat_count = 0;
    double best_ms = 0.0;
    double median_ms = 0.0;
    std::vector<double> runs_ms;
};

inline double median_of(std::vector<double> values) {
    if (values.empty()) {
        return 0.0;
    }
    std::sort(values.begin(), values.end());
    const std::size_t middle = values.size() / 2;
    if ((values.size() % 2U) == 0U) {
        return (values[middle - 1] + values[middle]) * 0.5;
    }
    return values[middle];
}

template <typename Callback>
inline BenchmarkSample run_benchmark_sample(const BenchmarkItem &item, Callback &&callback) {
    BenchmarkSample sample;
    sample.name = item.name;
    sample.repeat_count = item.repeat_count;

    callback(item.repeat_count);

    constexpr int kSamples = 5;
    sample.runs_ms.reserve(kSamples);
    for (int i = 0; i < kSamples; ++i) {
        const auto started = std::chrono::steady_clock::now();
        callback(item.repeat_count);
        const auto finished = std::chrono::steady_clock::now();
        const auto elapsed = std::chrono::duration<double, std::milli>(finished - started).count();
        sample.runs_ms.push_back(elapsed);
    }

    sample.best_ms = *std::min_element(sample.runs_ms.begin(), sample.runs_ms.end());
    sample.median_ms = median_of(sample.runs_ms);
    return sample;
}

inline std::string json_escape(std::string_view text) {
    std::string out;
    out.reserve(text.size() + 8);
    for (char ch : text) {
        switch (ch) {
        case '\\':
            out += "\\\\";
            break;
        case '"':
            out += "\\\"";
            break;
        case '\n':
            out += "\\n";
            break;
        case '\r':
            out += "\\r";
            break;
        case '\t':
            out += "\\t";
            break;
        default:
            out += ch;
            break;
        }
    }
    return out;
}

inline std::string format_double(double value) {
    std::ostringstream oss;
    oss << std::fixed << std::setprecision(3) << value;
    return oss.str();
}

inline void write_results_json(
    const std::filesystem::path &path,
    std::string_view runtime_name,
    const std::vector<BenchmarkSample> &samples) {
    std::filesystem::create_directories(path.parent_path());

    std::ofstream out(path, std::ios::binary);
    if (!out) {
        throw std::runtime_error("failed to open results file: " + path.string());
    }

    out << "{\n";
    out << "  \"runtime\": \"" << json_escape(runtime_name) << "\",\n";
    out << "  \"items\": [\n";
    for (std::size_t i = 0; i < samples.size(); ++i) {
        const auto &sample = samples[i];
        out << "    {\n";
        out << "      \"name\": \"" << json_escape(sample.name) << "\",\n";
        out << "      \"repeat_count\": " << sample.repeat_count << ",\n";
        out << "      \"best_ms\": " << format_double(sample.best_ms) << ",\n";
        out << "      \"median_ms\": " << format_double(sample.median_ms) << ",\n";
        out << "      \"runs_ms\": [";
        for (std::size_t j = 0; j < sample.runs_ms.size(); ++j) {
            if (j != 0U) {
                out << ", ";
            }
            out << format_double(sample.runs_ms[j]);
        }
        out << "]\n";
        out << "    }";
        if (i + 1U != samples.size()) {
            out << ",";
        }
        out << "\n";
    }
    out << "  ]\n";
    out << "}\n";
}

}  // namespace slc
