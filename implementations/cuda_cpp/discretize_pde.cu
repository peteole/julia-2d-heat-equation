#include <vector>
#include <iostream>
#include <memory>
#include <chrono>
#include <string>
#include <fstream>
// #include "discretize_pde.hpp"

#include "kernels.cu"

void write_solution(float *U_dev, int N, std::string path)
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
    // write to file
    std::cout << "writing to file: " << path << std::endl;
    std::ofstream file;
    file.open(path);
    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            file << U_host[i * N + j] << " ";
        }
        file << "\n";
    }
    file.close();
    free(U_host);
}

void discretize_heat_equation_cuda(int N, float dt, float t_end, int write_every)
{
    float h = 1.0 / (N - 1);

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


    dim3 threadsPerBlock(8, 8);
    dim3 numBlocks(N / threadsPerBlock.x + 1, (N / threadsPerBlock.y + 1));

    domain_setup<<<numBlocks, threadsPerBlock>>>(U, N);
    domain_setup<<<numBlocks, threadsPerBlock>>>(U_temp, N);
    cudaDeviceSynchronize();
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess)
    {
        std::cout << "CUDA Error after domain_setup: " << cudaGetErrorString(err) << std::endl;
    }

    int iteration = 1;
    for (double t = 0; t < t_end; t += dt)
    {
        heat_step<<<numBlocks, threadsPerBlock>>>(U, U_temp, N, dt, h);
        cudaDeviceSynchronize();
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            std::cout << "CUDA Error after heat_step: " << cudaGetErrorString(err) << std::endl;
        }
        if (iteration % write_every == 0 && write_every > 0)
        {
            write_solution(U, N, "output_raw/" + std::to_string(iteration)+","+std::to_string(t) + ".txt");
        }

        iteration++;

        float *temp = U_temp;
        U_temp = U;
        U = temp;
    }


    cudaFree(U);
    cudaFree(U_temp);
}