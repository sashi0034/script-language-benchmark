cmake_minimum_required(VERSION 3.20)
project(angelscript_benchmark LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

set(ANGELSCRIPT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/angelscript-2.38.0/sdk")

add_subdirectory(
    "${ANGELSCRIPT_ROOT}/angelscript/projects/cmake"
    "${CMAKE_BINARY_DIR}/vendor/angelscript"
)

add_executable(angelscript_benchmark
    src/main.cpp
    "${ANGELSCRIPT_ROOT}/add_on/scriptbuilder/scriptbuilder.cpp"
)

target_include_directories(angelscript_benchmark PRIVATE
    "${ANGELSCRIPT_ROOT}/angelscript/include"
    "${ANGELSCRIPT_ROOT}/add_on/scriptbuilder"
    "${CMAKE_CURRENT_SOURCE_DIR}/.."
)

target_compile_definitions(angelscript_benchmark PRIVATE
    _CRT_SECURE_NO_WARNINGS
    SLC_PROJECT_ROOT="${CMAKE_CURRENT_SOURCE_DIR}"
)

target_link_libraries(angelscript_benchmark PRIVATE angelscript)

if(MSVC)
    target_compile_options(angelscript_benchmark PRIVATE /wd4005 /wd4267)
endif()
