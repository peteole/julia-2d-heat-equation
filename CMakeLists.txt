cmake_minimum_required(VERSION 3.10)
project(CPPModernTrendsInHPC)


include_directories(implementations)
# Add executable targets
add_executable(naive implementations/cpp_naive/naive.cpp)

target_compile_options(naive PRIVATE -O3)

target_link_libraries(naive
    yaml-cpp
)