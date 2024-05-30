#include <vector>
#include <iostream>
#include <memory>
#include <chrono>
// #include "discretize_pde.hpp"

#include "cuda_heat.cu"

std::unique_ptr<std::vector<std::vector<float>>> device_to_vector_of_vectors(float *U_dev, int N)
{
    float *U_host = (float *)malloc(N * N * sizeof(float));
    if (!U_host)
    {
        std::cout << "failed to allocate host memory\n";
    }
    cudaError err = cudaMemcpy(U_host, U_dev, N * N * sizeof(float), cudaMemcpyDeviceToHost);
    if (err != cudaSuccess)
    {
        std::cout << "Failed to copy memory to host: " << cudaGetErrorString(err);
    }

    std::unique_ptr<std::vector<std::vector<float>>> out = std::make_unique<std::vector<std::vector<float>>>(N, std::vector<float>(N, 0));

    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            (*out)[i][j] = U_host[i * N + j];
        }
    }
    free(U_host);
    return out;
}

void discretize_heat_equation_cuda()
{
    auto N = 2000;
    float h = 1.0 / (N - 1);
    float dt = 0.000002;

    float *U;
    float *U_temp;
    size_t size = N * N * sizeof(float);
    cudaError_t err1 = cudaMalloc(&U, size);
    cudaError_t err2 = cudaMalloc(&U_temp, size);

    if (err1 != cudaSuccess)
    {
        std::cout << "Failed to allocate memory on device: " << cudaGetErrorString(err1);
    }
    if (err2 != cudaSuccess)
    {
        std::cout << "Failed to allocate memory on device: " << cudaGetErrorString(err2);
    }

    auto start = std::chrono::steady_clock::now();

    dim3 threadsPerBlock(8, 8);
    dim3 numBlocks = ((int)std::ceil((float)N / threadsPerBlock.x), (int)std::ceil((float)N / threadsPerBlock.y));

    domain_setup<<<numBlocks, threadsPerBlock>>>(U, N);
    cudaDeviceSynchronize();
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess)
    {
        std::cout << "CUDA Error after domain_setup: " << cudaGetErrorString(err) << std::endl;
    }

    int iteration = 1;
    for (double t = 0; t < 0.01; t += dt)
    {
        heat_step<<<numBlocks, threadsPerBlock>>>(U, U_temp, N, dt, h);
        cudaDeviceSynchronize();
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            std::cout << "CUDA Error after heat_step: " << cudaGetErrorString(err) << std::endl;
        }

        iteration++;

        float *temp = U_temp;
        U_temp = U;
        U = temp;
    }

    auto host_vector_of_vectors = device_to_vector_of_vectors(U_temp, N);

    cudaFree(U);
    cudaFree(U_temp);

    auto end = std::chrono::steady_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
    std::cout << "U[10][10]" << (*host_vector_of_vectors)[10][10] << "\n";
    std::cout << "completed operation in " << duration << "ms";
    std::cout << "iterations: " << iteration << "\n";
}

int main(int argc, char **argv)
{
    discretize_heat_equation_cuda();
}