cmake_minimum_required(VERSION 3.10)
project(CPPModernTrendsInHPC)
include(FetchContent)

FetchContent_Declare(
  yaml-cpp
  GIT_REPOSITORY https://github.com/jbeder/yaml-cpp.git
  GIT_TAG master # Can be a tag (yaml-cpp-x.x.x), a commit hash, or a branch name (master)
)
FetchContent_GetProperties(yaml-cpp)
if(NOT yaml-cpp_POPULATED)
  message(STATUS "Fetching yaml-cpp...")
  FetchContent_Populate(yaml-cpp)
  add_subdirectory(${yaml-cpp_SOURCE_DIR} ${yaml-cpp_BINARY_DIR})
endif()
# Add executable targets
add_executable(main main.cpp discretize_pde.hpp)
set_property(TARGET main PROPERTY CXX_STANDARD 17)
target_compile_options(main PRIVATE -O3)
target_link_libraries(main PUBLIC yaml-cpp::yaml-cpp)
add_executable(benchmark benchmark.cpp discretize_pde.hpp)
set_property(TARGET benchmark PROPERTY CXX_STANDARD 17)
target_compile_options(benchmark PRIVATE -O3)
target_link_libraries(benchmark PUBLIC yaml-cpp::yaml-cpp)