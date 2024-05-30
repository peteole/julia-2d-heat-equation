#include "discretize_pde.cu"

int main(int argc, char *argv[])
{
    // Check if the correct number of arguments are provided
    if (argc != 5)
    {
        std::cerr << "Usage: " << argv[0] << " <N> <dt> <t_end> <write_every>" << std::endl;
        return 1;
    }

    // Parse the arguments
    int N = std::atoi(argv[1]);
    float dt = std::atof(argv[2]);
    float t_end = std::atof(argv[3]);
    int write_every = std::atoi(argv[4]);
    auto start = std::chrono::steady_clock::now();
    discretize_heat_equation_cuda(N, dt, t_end, write_every);

    auto end = std::chrono::steady_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
    std::cout << "completed operation in " << duration << "ms";
}