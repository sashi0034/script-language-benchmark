cmake_minimum_required(VERSION 3.20)
project(daslang_benchmark LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

find_package(Threads REQUIRED)

set(DASLANG_BENCHMARK_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
set(DASCRIPT_ROOT "${DASLANG_BENCHMARK_ROOT}/vendor/daScript")

if(NOT EXISTS "${DASCRIPT_ROOT}/CMakeLists.txt")
    message(FATAL_ERROR "vendor/daScript is missing.")
endif()

set(DAS_FLEX_BISON_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_CLANG_BIND_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_LLVM_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_HV_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_GLFW_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_AUDIO_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_STDDLG_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_STBIMAGE_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_PUGIXML_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_SQLITE_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_TOOLS_DISABLED OFF CACHE BOOL "" FORCE)
set(DAS_TREE_SITTER_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_AOT_EXAMPLES_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_TUTORIAL_DISABLED ON CACHE BOOL "" FORCE)
set(DAS_TESTS_DISABLED ON CACHE BOOL "" FORCE)

add_subdirectory("${DASCRIPT_ROOT}" "${CMAKE_BINARY_DIR}/vendor/daScript")

add_executable(daslang_benchmark
    src/main.cpp
)

target_compile_definitions(daslang_benchmark PRIVATE
    DAS_MOD_EXPORTS
    DASLANG_BENCHMARK_PROJECT_ROOT="${DASLANG_BENCHMARK_ROOT}"
    DASLANG_BENCHMARK_DAS_ROOT="${DASCRIPT_ROOT}"
)

target_include_directories(daslang_benchmark PRIVATE
    "${DASCRIPT_ROOT}/include"
    "${CMAKE_BINARY_DIR}/vendor/daScript/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/.."
)

target_link_libraries(daslang_benchmark PRIVATE
    libDaScript
    Threads::Threads
)

if(MSVC)
    target_compile_options(daslang_benchmark PRIVATE /wd4005 /wd4267)
endif()

set_target_properties(daslang_benchmark PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY "${DASLANG_BENCHMARK_ROOT}"
)
