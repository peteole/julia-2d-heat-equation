cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

# Project name
project(MyCudaProject LANGUAGES CXX CUDA)

# Find CUDA
find_package(CUDA REQUIRED)

# Find VTK
find_package(VTK REQUIRED COMPONENTS
    vtkCommonCore
    vtkIOXML
    vtkRenderingCore
)

include(${VTK_USE_FILE})

# Add include directories for headers
include_directories(
    ${CUDA_INCLUDE_DIRS}
    ${VTK_INCLUDE_DIRS}
)

set(CMAKE_CUDA_ARCHITECTURES 
    75
)

set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} -std=c++17)

# CUDA source files
set(CUDA_SOURCE_FILES
    cuda_heat.cu
    main.cu
)

# C++ source files
set(CPP_SOURCE_FILES
    
)

# CUDA executable
cuda_add_executable(main ${CUDA_SOURCE_FILES} ${CPP_SOURCE_FILES})

set_target_properties(main PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
    CUDA_STANDARD 17 # Adjust the C++ standard as needed
)
# Link libraries
target_link_libraries(main
    ${CUDA_LIBRARIES}
    ${VTK_LIBRARIES}
    yaml-cpp
)